# Release Please with Kopexa Operator

Runs [Release Please](https://github.com/googleapis/release-please-action) with a
short-lived token of the Kopexa Operator GitHub App. Release PRs opened with it
trigger the repository's PR workflows, so they carry the required checks. PRs
opened with `GITHUB_TOKEN` do not.

Use it as a drop-in replacement for the `googleapis/release-please-action` step.
Steps after it in the same job keep working with the same outputs.

Without `client-id` and `private-key` the action falls back to `github-token`
(default: `GITHUB_TOKEN`), so it also works where the app is not configured.

## Inputs

| Name | Description | Default |
| ---- | ----------- | ------- |
| client-id | `vars.KOPEXA_OPERATOR_CLIENT_ID` | empty |
| private-key | `secrets.KOPEXA_OPERATOR_PRIVATE_KEY` | empty |
| github-token | Fallback token | `github.token` |
| config-file | Release Please config, ignored with release-type | `.release-please-config.json` |
| manifest-file | Release Please manifest, ignored with release-type | `.release-please-manifest.json` |
| release-type | Single-package mode, for example `node`, `go`, `simple` | empty |
| target-branch | Branch to release from | default branch |

## Outputs

The usual Release Please outputs: `release_created`, `releases_created`,
`tag_name`, `version`, `major`, `minor`, `patch`, `sha`, `upload_url`,
`prs_created`, `pr`, `prs`, `paths_released`.

Monorepo outputs per path are in `outputs-json`:

```yaml
${{ fromJSON(steps.release.outputs.outputs-json)['apps/web--tag_name'] }}
```

## Example

```yaml
permissions:
  contents: read
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - id: release
        uses: kopexa-grc/github-actions/github/release-please@<sha> # vX.Y.Z
        with:
          client-id: ${{ vars.KOPEXA_OPERATOR_CLIENT_ID }}
          private-key: ${{ secrets.KOPEXA_OPERATOR_PRIVATE_KEY }}
      - if: steps.release.outputs.release_created == 'true'
        run: echo "Released ${{ steps.release.outputs.tag_name }}"
```

With the app token the job itself needs no write permissions. Only the
`GITHUB_TOKEN` fallback needs `contents`, `pull-requests` and `issues: write`.
