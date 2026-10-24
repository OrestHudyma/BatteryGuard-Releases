# API 1 contract

`BatteryGuard.PluginApi.dll` targets .NET Framework 4.8 and fixes assembly version 1.0.0.0. Binary-incompatible changes require a new API major. The app and packages are x64; the contract assembly itself is AnyCPU. The canonical source is sdk/Contract.cs.

| Member | Contract |
|---|---|
| Initialize(HardwareIdentity) | Check exact identity. No firmware writes or long-lived background work. |
| ReadStatus() | Return Automatic, Paused, Configured or Unknown; native providers also return Lower/Upper. Any query side effects must be documented. |
| CaptureRecovery() | Capture original recoverable state, at most 64 KiB. No control change. Another process must understand the result. |
| SetPaused(bool) | SoftwarePause only. Host manages hysteresis; unrelated hardware settings must be preserved. |
| SetThresholds(int?, int) | UpperLimit receives null lower; DualLimits receives both. Validate before writing. |
| Restore(string) | Idempotent recovery, including after partial writes and in a fresh guardian process. Throw on failure. |
| Dispose() | Release resources. No firmware writes. |

Manifest has exactly SchemaVersion, ApiVersion, Id, Version, Name, Author, EntryType, Control, Minimum, Maximum, Step, Notes, Profiles. Unknown fields/trust claims are rejected. SchemaVersion and ApiVersion are 1. Version is major.minor.patch. EntryType is the fully qualified public parameterless provider class. Id uses 3–64 lowercase letters/digits/hyphens and cannot be the reserved embedded HP ID. Profiles have the same schema as a loose model profile; their Provider and ProviderVersion must match package Id/API. Each profile matches manufacturer/model/board/BIOS exactly, case-insensitively.

Control is exactly MonitorOnly, SoftwarePause, UpperLimit or DualLimits. Thresholds follow `Minimum + n * Step` through Maximum; 1 <= Minimum < Maximum <= 100. Upper-only providers ignore the lower UI setting. MonitorOnly never permits charge-control activation.

ZIP is at most 20 MiB, with exactly manifest.json (<=256 KiB), provider.dll (<=16 MiB) and README.md (<=256 KiB), without directories, duplicate names or dependencies. The SHA-256 of the entire ZIP identifies an immutable package. Runtime extraction and inspection never execute the DLL. A local install is not authorization to execute.

Community execution happens in the elevated controller after exact-package approval and a local test (except the explicitly authorized test itself). The main UI never loads Community code. The recovery guardian runs the same pinned DLL from administrator-protected session storage. Plugin code has the process's privileges; this is not sandboxing. Adding code from an untrusted author can compromise the computer.

Session data under ProgramData/BatteryGuard/Sessions records profile, API, archive hash, original state and recovery string. The dirty marker is flushed before a write. Restoration readback must match the original control state before clearing dirty; native providers must also match original thresholds. Manual and guardian recovery share the controller lock. A guardian acknowledges the exact snapshot before writes, terminates a stalled controller before attempting recovery, and leaves a failed recovery pending. No timeout can guarantee that an outstanding firmware operation was physically cancelled.

Packages are installed side by side; no in-place replacement or automatic DLL unloading is used. Changing the selected package is permitted only after the UI's active controller has restored and exited. The active session snapshot survives source-package changes. There is intentionally no package/session deletion button in this version.

Catalog URL is the fixed GitHub release tag `plugins-api-v1` in OrestHudyma/BatteryGuard-Releases. catalog.json contains ApiVersion and Packages; each entry has Id, Version, AssetName and Sha256. AssetName is BatteryGuard-Plugin-<id>-<version>.zip. Catalog and package bytes are checked against GitHub release asset SHA-256 digests; the entry hash must agree too. Downloads are HTTPS from fixed GitHub hosts, bounded and anonymous. This is repository/TLS-based authenticity and integrity, not an independent publisher-signature scheme and not protection from a compromised repository owner.
