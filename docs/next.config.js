const withNextra = require("nextra")({
  theme: "nextra-theme-docs",
  themeConfig: "./theme.config.tsx",
});

const nextraConfig = withNextra({
  i18n: {
    locales: ["en"],
    defaultLocale: "en",
  },
});

module.exports = withNextra();
