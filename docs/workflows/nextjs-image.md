# nextjs-image

Builds an application-owned Dockerfile, publishes to GHCR and smoke-tests the
published digest. GitOps writes are disabled unless `GITOPS_ENABLED=true`.

Required inputs: `environment`, `source-ref`, `dockerfile`, `image`, `image-tag`,
`gitops-path`. Optional: `image-alias`, `next-cache-target`, `health-path`, `platforms`.
Returns the published `digest`. Requires contents read and packages write.
`GITOPS_TOKEN` is required only when GitOps is enabled.

See [configuration and examples](../nextjs.md).
