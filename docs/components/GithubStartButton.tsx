import GitHubButton from "react-github-btn";

export default function GithubStartButton() {
  return (
    <div className="github-button">
      <GitHubButton
        href="https://github.com/leoafarias/fvm"
        data-show-count="true"
        // data-size="large"
        aria-label="Star leoafarias/fvm on GitHub"
      >
        Star
      </GitHubButton>
    </div>
  );
}
