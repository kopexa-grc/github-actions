# Go build

Composite action: `kopexa-grc/github-actions/go/build@<release-sha>`.

Runs Go setup and the repository's build script. Inputs: `go-version`,
`go-version-file` (default `go.mod`), `working-directory` (default repository root),
and `force-semver`. See [main.sh](main.sh) for version metadata handling.
