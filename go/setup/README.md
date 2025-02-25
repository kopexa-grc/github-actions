# Go Setup Action

This GitHub Action sets up a Go environment for builds against dependencies within the kopexa-grc GitHub organisation.

Go dependencies are cached to speed up subsequent runs. All `go.sum` files in the repository are used for caching.



## Example Usage

### Fetch GitHub token from Vault

```yaml
- name: Setup Go
  uses: github.com/kopexa-grc/github-actions/go/setup
  with:
    go-mod-file: "./my-go.mod"
    display-install-info: "true"
```