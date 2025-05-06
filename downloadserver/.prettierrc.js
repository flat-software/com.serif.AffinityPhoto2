/** @type {import("prettier").Config} */
const config = {
  printWidth: 80,
  bracketSpacing: false,
  arrowParens: "avoid",
  trailingComma: "es5",
  plugins: ["prettier-plugin-organize-imports"],
  quoteProps: "consistent",
};

export default config;
