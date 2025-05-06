import {serve} from "@hono/node-server";
import {Hono} from "hono";
import {HTTPException} from "hono/http-exception";
import {logger} from "hono/logger";
import {getDownload, getLatestVersion} from "./fetch.ts";

const app = new Hono();
app.use(logger());

app.get("/info", c => {
  return c.text("Server is running!\n");
});

app.get("/latestversion", async c => {
  const latestVersion = await getLatestVersion();
  if (!latestVersion) {
    throw new HTTPException(404, {message: "Version not found."});
  }

  return c.json({
    url: `http://localhost:5173/download/${latestVersion.version}`,
  });
});

app.get("/download/:version", async c => {
  const {version} = c.req.param();
  const latestVersion = await getLatestVersion();
  if (!latestVersion) {
    throw new HTTPException(500, {message: "Latest version not found"});
  }

  if (version !== latestVersion.version) {
    throw new HTTPException(400, {message: "Outdated version."});
  }

  const response = await getDownload(latestVersion.downloadUrl);
  if (!response) {
    throw new HTTPException(404, {message: "Download not found."});
  }

  const headers = new Headers(response.headers);
  headers.set("content-disposition", 'attachment; filename="affinity.zip"');

  return new Response(response.body, {headers});
});

serve({
  fetch: app.fetch,
  port: 5173,
});
