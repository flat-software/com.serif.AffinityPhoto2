import type {Version} from "./model.ts";

const headers = {
  "accept": "*/*",
  "origin": "https://store.serif.com/",
  "user-agent":
    "Mozilla/5.0 (X11; Linux) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.75 Safari/537.36",
  "accept-encoding": "gzip, deflate, br",
  "accept-language": "en-US,en;q=0.9",
  "authority": "store.serif.com",
  "referer": "https://store.serif.com/en-us/update/windows/photo/2/",
};

const versionRegex = /"(https:\/\/(?:.+)photo2\/([^\/]+)\/.+\.msix.+)"/;

export async function getLatestVersion(): Promise<Version | undefined> {
  const response = await fetch(
    `https://store.serif.com/en-us/update/windows/photo/2/`,
    {headers}
  );

  if (!response.ok) {
    return undefined;
  }

  const responseHtml = await response.text();
  const match = responseHtml.match(versionRegex);
  if (!match || match.length < 3) {
    return undefined;
  }

  return {
    version: match[2]!,
    downloadUrl: match[1]!,
  };
}

export async function getDownload(downloadUrl: string) {
  const downloadResponse = await fetch(downloadUrl, {headers});
  if (!downloadResponse.ok) {
    throw new Error("Download URL request failed.");
  }

  const downloadBody = downloadResponse.body as ReadableStream<Uint8Array>;
  if (!downloadResponse.ok || !downloadBody) {
    throw new Error("Download request failed.");
  }

  return downloadResponse;
}
