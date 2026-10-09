# nextjs-image

Builds the application Dockerfile, publishes to GHCR and smoke-tests its digest.
With GITOPS_ENABLED=true it dispatches envs/websites.yml and waits for the result.
The sender no longer checks out envs or commits manifests.

Required inputs: environment, source-ref, dockerfile, image, image-tag.
Optional: application, next-cache-target, health-path, platforms. Legacy gitops-path
and image-alias remain accepted but are ignored. Returns the published digest.
Requires Contents read and Packages write; GITOPS_TOKEN needs envs Actions read/write.

See [configuration and event contract](../nextjs.md).
