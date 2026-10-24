# Create support manually

## Decide whether you need a profile or a provider

A **profile** declares exact manufacturer/model/board/BIOS identifiers and chooses a provider. A **provider** implements the hardware protocol. Copying identifiers into an HP profile cannot make ASUS hardware support HP commands. If no known protocol applies, a valid outcome is “monitoring only; charge control not established.”

## 1. Collect facts without changing hardware

In Hardware support choose **Collect diagnostics**. This exports model, board, BIOS, OS/process architecture, app version and basic battery status, without loading plugins. It omits serial numbers, account tokens and the Windows installation ID. Inspect any additional ACPI dumps or logs before sharing them; they may contain identifiers.

Identify documented vendor APIs or review model-specific firmware evidence. Distinguish a true read from a query that changes a bank selector. The HP example's initial mode query selects an EC bank and is therefore reserved for the approved control/test flow. Do not guess register addresses, WMI command numbers or modes from a similar model name. Never disable Windows security protections or install an unreviewed kernel driver to make a template work.

## 2. Use an existing provider where supported

Create profile offers the built-in HP provider on HP systems and installed Community providers that explicitly declare this exact machine. Enter exact identifiers; wildcard and family-name matching are not supported. Exported JSON does not carry approval or local test results. A new BIOS is a new compatibility claim.

For Community providers, supported identities live in the package manifest and should also be enforced by Initialize. To support another model, update the provider source/manifest as appropriate, increment the package version, rebuild and test. The package's hardware restrictions cannot be bypassed just by changing a loose JSON profile.

## 3. Implement a new provider

Copy `examples/template` to `plugins/<your-id>`. Edit its manifest and implement `sdk/Contract.cs`. Use a unique ID; the built-in HP ID is reserved. Keep `MonitorOnly` until a protocol and recovery procedure have been established. The template deliberately throws for every control operation.

Choose one capability: MonitorOnly, SoftwarePause, UpperLimit or DualLimits. Declare valid percentage minimum, maximum and step. Do not emulate an unsupported lower hardware threshold by silently passing it to firmware. Explain behavior across sleep, AC disconnection and restart, and whether recovery restores original settings or a documented automatic mode.

Constructors and Initialize must not write firmware. CaptureRecovery must return at most 64 KiB of data sufficient for another process to recover; it must not contain secrets or rely on static fields from the original process. Restore must be idempotent and tolerate a partially failed write. Dispose must not perform firmware writes. Bound every hardware call and avoid background threads that continue writing after the controller stops.

Community code is trusted executable code once approved: it can access the machine with the controller's rights. The host cannot prove that a provider honors the API contract. Audit the actual code, not just its manifest.

## 4. Build and inspect

From the repository's `community` directory:

```powershell
.\build-plugin.ps1 -PluginDirectory .\plugins\your-id -OutputDirectory .\artifacts\your-id
```

The script uses the installed .NET Framework compiler and creates `BatteryGuard-Plugin-<id>-<version>.zip`. API 1 accepts exactly three root files: manifest.json, provider.dll and README.md. It does not load arbitrary dependency DLLs or run install scripts. The host supplies BatteryGuard.PluginApi.dll; do not package another copy.

On a Battery Guard development build, validate without executing plugin code:

```powershell
BatteryGuard.exe --validate-plugin C:\path\BatteryGuard-Plugin-your-id-0.1.0.zip
```

Exit code 0 means package structure/metadata are accepted, not that its code is safe or its protocol works. Test failures and test reports are separate from hardware evidence. Do not run firmware methods on a CI runner.

## 5. Install and test locally

Disable charge control. Open **Community plugins**, import ZIP and choose **Use this version**. Read the source and README before **Approve code execution**. Approval applies to the whole archive hash, including the DLL, and API version. Import alone grants no approval. Select its model profile, then use **Test charge control** with explicit consent and normal UAC.

SoftwarePause tests require one valid battery, AC, active charging and 5–97% charge. The host observes pause and resumption using potentially cached Windows telemetry. Native threshold tests set the chosen thresholds, read them back, restore the original state and compare readback; they do not prove that physical charging stops at those thresholds. Invalid range/step choices are rejected before a threshold write.

Record initial state, actions, recovery result, exact model/BIOS, package hash and known untested cases. Do not mark a failed or inconclusive test as passed. A different package, profile, BIOS, machine or Windows installation invalidates prior approval evidence. Built-in provider tests also include the app/SDK binary fingerprints.

The host persists recovery data before writes and requires a guardian to acknowledge the pinned session before control starts. If recovery fails, a dirty journal remains and new control is blocked. Use **Recover previous session** to explicitly retry with the pinned package. Never delete session data to bypass pending recovery. Recovery cannot undo arbitrary malicious code or guarantee success during firmware/OS failure.

## 6. Share support

Submit source, manifest, README, tests and sanitized evidence through a pull request. See publication.md. Do not claim support for untested models. For an ASUS Eee PC 901 without established protocol evidence, contribute diagnostics or a clearly non-controlling research template, not guessed charge-control code.
