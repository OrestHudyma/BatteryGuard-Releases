# HP 8570w Community example

This package demonstrates the public API using the existing HP EliteBook 8570w / board 176B / BIOS 68IAV Ver. F.70 protocol. Prefer the embedded Verified implementation when available. This particular DLL has not passed live hardware acceptance and is Community, regardless of whether its build succeeds.

The constructor and Initialize do not invoke firmware. ReadStatus and CaptureRecovery query HP WMI command type 0x2B, command 1, battery 0. This query selects an EC bank and is not strictly a read-only hardware operation. SetPaused(true) sends mode 5; Restore sends mode 0. Only PASS/return-code-zero responses count as command success. Recovery restores automatic charging, not a complete saved image of EC registers. Initialize restricts the exact machine independently of JSON.

The underlying protocol was observed on 2026-10-22: mode 5 stopped charging with AC online, mode 0 resumed charging. Immediate mode readback after restore sometimes returned 255; battery telemetry later showed charging. That observation is not acceptance of this plugin binary, and does not establish sleep/resume or crash recovery safety. Never change model identifiers to apply it to ASUS or another HP model.

Build from source; import ZIP in Hardware support > Community plugins. Download/import does not run the code. Explicit approval is required before its local test can start. The test and actual control require administrator rights. A guardian uses the same pinned package and recovery data; faulty provider code can still prevent recovery.
