# Kopexa Operator app token

Mints a short-lived installation token of **Kopexa Operator**, the Kopexa CI GitHub App.
Use it wherever a workflow needs more than `GITHUB_TOKEN` can do, instead of a
personal access token:

- Pull requests opened with it (for example by Release Please) trigger the
  repository's PR workflows. PRs opened with `GITHUB_TOKEN` do not.
- Cross-repository calls, for example the workflow dispatch to `envs`.

The token is valid for one hour, limited to the repositories and permissions you
request, and revoked when the job ends. It is not tied to a person.

## Configuration

| Name | Kind | Scope |
| ---- | ---- | ----- |
| `KOPEXA_OPERATOR_CLIENT_ID` | Variable | Organization kopexa-grc, selected repositories |
| `KOPEXA_OPERATOR_PRIVATE_KEY` | Secret | Organization kopexa-grc, selected repositories |

The app itself needs these repository permissions: Actions, Contents, Issues and
Pull requests read and write, Metadata read. Request only what a job needs.

## Inputs

| Name | Description | Required |
| ---- | ----------- | -------- |
| client-id | Kopexa Operator client ID | Yes |
| private-key | Kopexa Operator private key | Yes |
| owner | Owner of the target repositories, defaults to the calling owner | No |
| repositories | Repository names, defaults to the calling repository | No |
| permission-contents | `read`, `write` or empty to omit | No |
| permission-pull-requests | `read`, `write` or empty to omit | No |
| permission-issues | `read`, `write` or empty to omit | No |
| permission-actions | `read`, `write` or empty to omit | No |

Leaving every permission empty grants all permissions of the installation.

## Outputs

| Name | Description |
| ---- | ----------- |
| token | Installation token |
| app-slug | `kopexaoperator` |
| git-user-name | `kopexaoperator[bot]` |
| git-user-email | Noreply address for bot commits |

## Example: Release Please

```yaml
steps:
  - id: operator
    uses: kopexa-grc/github-actions/github/app-token@<sha> # vX.Y.Z
    with:
      client-id: ${{ vars.KOPEXA_OPERATOR_CLIENT_ID }}
      private-key: ${{ secrets.KOPEXA_OPERATOR_PRIVATE_KEY }}
      permission-contents: write
      permission-pull-requests: write
      permission-issues: write
  - uses: googleapis/release-please-action@45996ed1f6d02564a971a2fa1b5860e934307cf7 # v5.0.0
    with:
      token: ${{ steps.operator.outputs.token }}
```

## Example: dispatch a workflow in another repository

```yaml
steps:
  - id: operator
    uses: kopexa-grc/github-actions/github/app-token@<sha> # vX.Y.Z
    with:
      client-id: ${{ vars.KOPEXA_OPERATOR_CLIENT_ID }}
      private-key: ${{ secrets.KOPEXA_OPERATOR_PRIVATE_KEY }}
      repositories: envs
      permission-actions: write
```
