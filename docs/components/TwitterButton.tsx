import Link from "next/link";
import { useEffect, useState } from "react";
import { canUseDOM } from "../lib/helpers";

export default function TwitterButton() {
  const [mounted, setMounted] = useState(false);
  useEffect(() => {
    if (!canUseDOM) return;
    // const s = document.createElement("script");
    // s.setAttribute("src", "https://platform.twitter.com/widgets.js");
    // s.setAttribute("async", "true");
    // document.head.appendChild(s);
    setMounted(true);
  }, []);

  if (!mounted) {
    return null;
  }

  return (
    <Link href="https://twitter.com/leoafarias">
      <img
        alt="X (formerly Twitter) Follow"
        src="https://img.shields.io/badge/Follow-blue?style=for-the-badge&logo=twitter&logoColor=white"
      />
    </Link>
  );
}
