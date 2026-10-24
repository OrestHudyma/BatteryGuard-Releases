# Contribution, builds and Verified status

Anyone can fork the public BatteryGuard-Releases repository and propose a new directory under community/plugins through a pull request. Include source, manifest, README, hardware-free tests and sanitized model-specific evidence. Increment package versions; never replace a published version with different bytes.

Pull-request validation runs on a GitHub-hosted Windows runner with read-only repository permissions and no publishing credentials. Build/validate only; never invoke firmware. Do not use pull_request_target to build untrusted contributor source with write tokens or signing secrets. Application installer releases and plugin catalog publishing are separate operations.

The maintainer reviews source, recovery semantics, model claims and test results before merging. Publishing is a separate explicit workflow_dispatch action from reviewed main. It builds a selected plugin in a read-only job, then a separate write-permission job only validates archive metadata and uploads bytes. Publication appends to a prerelease named plugins-api-v1 and updates catalog.json. The catalog is not the application's latest stable installer release.

Status comes from the host, never a manifest flag:

- **Community**: downloaded/imported executable package; explicit approval and local testing are required. A passing build or settings roundtrip is not Verified status.
- **Verified**: reviewed source incorporated into an application build, with concrete model/BIOS evidence and recovery limitations. Promotion requires a source change and new app build. Updating a catalog entry cannot promote a DLL.
- **Local**: user-created model profile; not a developer verification claim.

When promoting a provider, register its reviewed implementation and descriptors in the app's built-in registry, include exact verified model JSON in the app build and rerun policy/recovery tests. The first API 1 app build includes only the existing HP provider as Verified. Prefer embedded Verified support by default unless the user explicitly selects Community.

The sample HP package is provided as Community to exercise the public contribution path. The underlying protocol has earlier machine-specific evidence, but the sample DLL has not been live-tested in the new session architecture. Do not remove this distinction from release notes.
