# Go unit tests

Composite action: `kopexa-grc/github-actions/go/unit-test@<release-sha>`.

Sets up Go, installs go-junit-report and publishes JUnit results.
Inputs: `command` (default `make test`), `go-version`, `go-version-file`
(default `go.mod`) and `working-directory` (default repository root).
The caller needs `checks: write` to publish the report.
