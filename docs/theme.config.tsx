import { DocsThemeConfig } from "nextra-theme-docs";

const config: DocsThemeConfig = {
  logo: <span>FVM</span>,
  project: {
    link: "https://github.com/leoafarias/fvm",
  },
  docsRepositoryBase: "https://github.com/leoafarias/fvm/tree/main/docs",
  footer: {
    text: "Copyright © 2023 Leo Farias.",
  },
  useNextSeoProps() {
    return {
      titleTemplate: "%s – FVM - Flutter Version Management",
    };
  },
};

export default config;
