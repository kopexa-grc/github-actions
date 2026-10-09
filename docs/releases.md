# Releasing the shared actions and workflows

This repository uses Release Please with the `simple` strategy. It updates
`version.txt`, `CHANGELOG.md` and `.release-please-manifest.json` in a release PR.
The existing latest version is `0.0.2`; existing tags are retained. New releases
use full `vX.Y.Z` tags without a component prefix. No moving major tag is created.

1. Merge conventional commits (`fix:`, `feat:`, `chore(deps):`, or `feat!:`).
2. Release Please opens or updates a release PR on main pushes.
3. Review and merge the release PR after required validation passes.
4. The next main run creates the GitHub release and version tag.
5. Update consumers explicitly to the release SHA, optionally with the version as
   a comment, or to its full version tag. Existing SHA-pinned consumers do not move.

The workflow uses `GITHUB_TOKEN`; no new credential is needed. Because bot-created
PRs do not trigger PR workflows, it explicitly dispatches Workflow validation on
the release branch. That provides the required `actionlint` check without bypassing
branch protection. Release PRs are not automatically approved or merged.

The dependency upgrade uses Node.js 24 actions. Self-hosted runners must support
that runtime (at least v2.327.1; authenticated Git inside Docker with checkout v7
requires v2.329.0). The workflows here use GitHub-hosted ubuntu-latest. Checkout v7
rejects unsafe fork checkouts in privileged triggers by default. GitHub Script v9
is ESM-based; the scripts here use its injected client, not require('@actions/github').
