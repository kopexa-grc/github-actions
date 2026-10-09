# nextjs-checks

Installs the caller's pnpm dependencies and runs PR checks. No image is published.

Call `.github/workflows/nextjs-checks.yml` through `jobs.<job>.uses` at a release
SHA or full version tag. Inputs: `working-directory` (default `.`) and
`test-command` (default `pnpm test`). Requires `contents: read`.

Node.js 24 is used; pnpm comes from the caller's `packageManager` field.

See [configuration and examples](../nextjs.md).
