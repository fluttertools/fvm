import "../styles.css";

import type { AppProps } from "next/app";

export default function DocApp({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
