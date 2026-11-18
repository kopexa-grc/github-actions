# nextjs-image

Builds the application Dockerfile, publishes to GHCR and smoke-tests its digest.
With GITOPS_ENABLED=true it dispatches envs/websites.yml and waits for the result.
The sender no longer checks out envs or commits manifests.

Required inputs: environment, source-ref, dockerfile, image, image-tag.
Optional: application, next-cache-target, health-path, platforms. Legacy gitops-path
and image-alias remain accepted but are ignored. Returns the published digest.
Requires Contents read and Packages write; the envs dispatch uses a Kopexa Operator token (`KOPEXA_OPERATOR_PRIVATE_KEY` + `KOPEXA_OPERATOR_CLIENT_ID`), falling back to GITOPS_TOKEN with envs Actions read/write.

See [configuration and event contract](../nextjs.md).
