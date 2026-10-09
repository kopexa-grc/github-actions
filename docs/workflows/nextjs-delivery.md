# nextjs-delivery

Coordinates Release Please and the image workflow after a main push.
Ordinary commits build staging; merging a release PR builds production only.

Required inputs: `dockerfile`, `image`, `staging-path`, `production-path`.
Optional: `next-cache-target`, `release-config`, `release-manifest`.
Optional secrets: `RELEASE_PLEASE_TOKEN`, `GITOPS_TOKEN`.
Requires write permissions for contents, pull requests, issues and packages.

Calls the image workflow at the same revision. The caller owns the `staging` and
`production` GitHub Environments and public build variables.

See [configuration and examples](../nextjs.md).
