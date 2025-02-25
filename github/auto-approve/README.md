# GitHub PR Auto-Approve Action

This action automatically approves pull requests based on user and label criteria. It is designed to streamline the PR
approval process by automatically approving PRs from trusted users or with specific labels.

The action works by taking a list of users and labels as inputs. It then checks the last actor of the PR and the labels
attached to the PR. If the last actor is in the list of users and the PR has any of the specified labels, the action
approves the PR. If either the user or label check fails, the action does not approve the PR and logs the reason for the
failure.

## Inputs

| Name         | Description                                                                                            | Required |
| ------------ | ------------------------------------------------------------------------------------------------------ | -------- |
| users        | Comma-separated list of GitHub users matched against the last actor. If empty, all users are matched.  | No       |
| labels       | Comma-separated list of GitHub labels matched against the PR labels. If empty, all labels are matched. | No       |
| github-token | GitHub token used to approve the Pull Request.                                                         | Yes      |

## Example Usage

```yaml
steps:
  - name: Auto-Approve PR
    uses: ./github/auto-approve
    with:
      users: 'juliankoehn,admin'
      labels: '🔨renovate, yolo'
      github-token: '${{ secrets.GITHUB_TOKEN }}'
```
