import { Follow } from "react-twitter-widgets";

export default function TwitterButton() {
  return (
    <Follow
      username="leoafarias"
      options={{
        dnt: true,
        size: "small",
        showCount: false,
        showScreenName: false,
      }}
    />
  );
}
