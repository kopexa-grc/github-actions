# Next.js delivery contract

This repository shares workflow implementation; application repositories own their
Dockerfiles, release versions, tests and deployment targets. `envs` owns manifests.
The workflows are prepared locally. Publish and validate them before enabling callers. If this repository is private,
allow reuse by the organization in its Actions access settings.

## Workflows

- `nextjs-checks.yml`: dependency install and caller-supplied PR checks. No environment,
  registry write or GitOps credentials. pnpm version comes from `packageManager`.
- `nextjs-delivery.yml`: main push -> Release Please; ordinary commits -> staging;
  newly created release -> production. Merged Release Please PRs never deploy to
  staging, including reruns. Nested calls use the same central workflow revision.
- `nextjs-image.yml`: environment-specific Docker build, GHCR push, health/noindex
  smoke test, optional digest update in `envs`.

Consumers should pin calls to a reviewed commit SHA or immutable workflow tag.
`hello` temporarily references `main` for bootstrap. Do not enable production until
that reference has been pinned. Updating central workflows then becomes an explicit
consumer PR. Existing Go actions and workflows remain unchanged.

## GitHub Environments (in each calling repo)

Create `staging` and `production`, not in this shared repo. Environment restrictions
apply to the caller's main workflow ref; production is built from the Release Please
tag through an explicit checkout. Both jobs originate from main. Optional required
reviewers apply before the build and GitOps handoff.

Variables for both environments:

- `DEPLOYMENT_URL`: public URL recorded in GitHub's environment view.
- `NEXT_PUBLIC_CONFIG_JSON`: a compact, single-line JSON object of public build values.
  It must include `NEXT_PUBLIC_BASE_URL`. These values are bundled into the image;
  never put server credentials here. `NEXT_PUBLIC_DEPLOYMENT_ENV` is controlled by
  the workflow and must not be included in this object.
- `GITOPS_ENABLED`: leave unset/false for image-only bootstrap. Enable after the
  Argo application, TLS, pull credentials and runtime secrets are ready.

Example staging JSON:

```json
{"NEXT_PUBLIC_BASE_URL":"https://hello.staging.kopexa.dev"}
```

Production JSON: same key with `https://kopexa.com`, plus required public integration
configuration copied from the actual current deployment. Do not guess production values.

Secrets:

- `GITOPS_TOKEN`: fine-grained token or GitHub App token scoped to `kopexa-grc/envs`
  Contents write. Store as an environment secret (passed secrets may be empty; the
  called job resolves its environment secret). Direct main pushes require compatible
  envs branch protections; otherwise change handoff to PRs before enabling it.
- `RELEASE_PLEASE_TOKEN`: optional repository secret with Contents, Issues and Pull
  requests write. Needed if generated Release Please PRs must trigger required CI
  checks. GITHUB_TOKEN fallback works for release creation and the in-workflow
  production job, but its generated PRs/releases do not trigger other workflows.

Enable "Allow GitHub Actions to create and approve pull requests" if using the
GITHUB_TOKEN fallback. Releases do not rely on tag/release event triggers.

## Application image contract

Dockerfile receives `DEPLOYMENT_ENV`, `NEXT_PUBLIC_DEPLOYMENT_ENV` and
`NEXT_PUBLIC_CONFIG_JSON`. It must compile public configuration into Next.js and
bake noindex headers into staging builds. Container listens on 0.0.0.0:3000 and has
`/api/health` by default. `nextjs-image.yml` accepts a custom `health-path` for direct
callers; adapt the delivery wrapper before onboarding a different health contract.
Runtime server credentials belong to cluster Secrets, never the public JSON.
Current smoke tests assume the app starts without live integration credentials.
Additional private-registry/build-secret inputs are intentionally not implemented;
add explicit BuildKit secret support when an app requires them, not build arguments.

Default platform is linux/amd64 (matches the current deployment plan). Multi-platform
images require adding QEMU setup or a matching native builder before changing this.
GitHub success confirms image and GitOps handoff; it does not confirm Argo Health.

## Recovery

If production build/handoff fails after release creation, rerun **failed jobs** so
Release Please outputs from the successful job are retained. Rerunning all jobs
will find no new release and deliberately does not redeploy a release merge.
For an intentional redeploy, add a reviewed workflow_dispatch caller to
`nextjs-image.yml` with the exact existing release tag and target environment.
Rollbacks restore a previous digest in envs (with matching runtime configuration).

Staging and production are separate builds of their respective commits, because
NEXT_PUBLIC values are baked in. Builds use a frozen lockfile. To preserve runtime
behavior, keep integration credentials and dependency endpoints environment-specific.

## References

- https://github.com/googleapis/release-please-action#other-actions-on-release-please-prs
- https://docs.github.com/en/actions/sharing-automations/reusing-workflows
- https://nextjs.org/docs/app/api-reference/config/next-config-js/output

## Fast builds

Target: 2–3 minutes for a warm build/publish/GitOps handoff, to be measured on the
actual CI runner. Argo sync latency is separate; configure envs GitHub webhooks
instead of relying on periodic repository polling for prompt rollout.

The image workflow keeps Docker layers in the GHA backend and persists the Next.js/TypeScript
cache mount through actions/cache + buildkit-cache-dance. The caller supplies
next-cache-target (default /app/.next/cache; hello uses /app/apps/client/.next/cache).
pnpm dependencies remain cached as a Docker layer; its unchanged store is not
exported on every commit, avoiding a large upload.
The external cache key includes environment, public config, Dockerfile, lockfile,
runner architecture and commit. Restoration falls back within the same config and
lockfile scope, preserving warm incremental builds after source changes.

hello keeps TypeScript incremental metadata in .next/cache. Turbopack stays enabled,
but its experimental build filesystem cache is opt-in via TURBOPACK_BUILD_CACHE=true.
Local tests of that experimental option repeatedly ended in SIGKILL; it is disabled
by default until validated on the actual CI runner or a separately reviewed Next upgrade. Tests and TypeScript validation
remain enabled. Dependency layers and incremental type-check caches are persisted; the final
standalone image excludes build cache mounts. The mount cache is stored outside
Docker's source context to avoid copying it into image layers.

Next.js 16.1 still labels build filesystem caching experimental; disable the flag
and bump the cache namespace if incorrect cache behavior is observed. Compare
cache-cold and cache-warm source changes, not just a fully cached identical build.
GitHub queue time, environment approvals and registry bandwidth are not covered by
a guaranteed SLA. Use the workflow timeline and Next logs to measure each phase.

References:
- https://nextjs.org/docs/app/api-reference/config/next-config-js/turbopackFileSystemCache
- https://docs.docker.com/build/ci/github-actions/cache/#cache-mounts

The caller can tune builder-only `BUILD_NODE_OPTIONS` and `TURBOPACK_MEMORY_LIMIT`
environment variables. Defaults: Node heap 1536 MiB and Turbopack target 1 GiB.
The latter is a cache memory target, not a total process RSS limit. Local Docker
shares memory with unrelated containers, so local failures are not CI benchmarks.
Turbopack remains the bundler; no webpack migration is included.

hello's Docker build generates Velite content and Next route types, runs `tsc
--noEmit`, then compiles with Turbopack and generates the sitemap. The checked
sources and public environment match the compilation. Only after a successful
check does the script set NEXT_TYPECHECK_COMPLETED for Next to avoid repeating
the type check while the compiler graph is resident. Normal pnpm build retains
Next's type check. This is a sequential memory optimization, not removal of validation.
