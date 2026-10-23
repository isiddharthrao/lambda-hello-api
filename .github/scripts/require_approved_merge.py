"""Allow deployment only when the pushed commit comes from an approved, merged pull request."""

import json
import os
import subprocess
import sys


def github_json(path):
    raw = subprocess.check_output(
        [
            "gh",
            "api",
            "--paginate",
            "-H",
            "Accept: application/vnd.github+json",
            path,
        ],
        text=True,
    )
    pages = []
    decoder = json.JSONDecoder()
    index = 0
    text = raw.strip()
    while index < len(text):
        while index < len(text) and text[index].isspace():
            index += 1
        if index >= len(text):
            break
        page, index = decoder.raw_decode(text, index)
        pages.extend(page if isinstance(page, list) else [page])
    return pages


def latest_review_states(reviews):
    latest = {}
    for review in reviews:
        author = review["user"]["login"]
        previous = latest.get(author)
        submitted_at = review.get("submitted_at", "")
        if previous is None or submitted_at >= previous.get("submitted_at", ""):
            latest[author] = review
    return [review["state"] for review in latest.values()]


def main():
    repo = os.environ["GITHUB_REPOSITORY"]
    sha = os.environ["GITHUB_SHA"]
    pulls = github_json(f"repos/{repo}/commits/{sha}/pulls")

    if not pulls:
        print(
            f"No pull request is associated with {sha}. "
            "Deployment runs only after an approved pull request is merged."
        )
        return False

    for pull in pulls:
        number = pull["number"]
        if not pull.get("merged_at"):
            sys.exit(f"Pull request #{number} is not merged. Deployment did not start.")

        states = latest_review_states(
            github_json(f"repos/{repo}/pulls/{number}/reviews")
        )
        print(f"Pull request #{number} review states: {', '.join(states) or '(none)'}")
        if "APPROVED" not in states or "CHANGES_REQUESTED" in states:
            sys.exit(
                f"Pull request #{number} is not approved. "
                "Approve it before merging to start deployment."
            )

    print("Merged pull request is approved. Starting deployment.")
    return True


if __name__ == "__main__":
    deploy = main()
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as handle:
        handle.write(f"deploy={'true' if deploy else 'false'}\n")
