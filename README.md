# Kopexa GitHub Actions

Shared composite actions and reusable workflows for Kopexa repositories.

## Composite actions: steps inside your job

These follow `<category>/<action>/action.yml`, with a README beside each action.
Call them with `steps[].uses`; your workflow owns the runner and job permissions.

- [Go setup](go/setup/README.md)
- [Go build](go/build/README.md)
- [Go unit tests](go/unit-test/README.md)
- [PR auto-approval](github/auto-approve/README.md)

## Reusable workflows: complete jobs

GitHub requires reusable workflows in `.github/workflows/`. Call them using
`jobs.<job>.uses`; they can coordinate multiple jobs, environments and releases.
They complement the composite actions above.

- [Next.js PR checks](docs/workflows/nextjs-checks.md)
- [Next.js delivery with Release Please](docs/workflows/nextjs-delivery.md)
- [Next.js image build and GitOps handoff](docs/workflows/nextjs-image.md)
- [Full Next.js configuration contract](docs/nextjs.md)

## Releases and maintenance

[Release process](docs/releases.md) describes this repository's Release Please
workflow and version tags. Consumer applications keep their own release versions.
External actions are pinned to verified release SHAs; Dependabot checks them quarterly.
