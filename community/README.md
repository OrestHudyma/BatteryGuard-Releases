# Battery Guard provider SDK · API 1

This public SDK lets contributors implement a new laptop protocol without changing the Battery Guard UI. Runtime: Windows 11 x64, .NET Framework 4.8. A provider package does not add support for older operating systems or x86 hardware.

- [Manual authoring](docs/manual.md)
- [AI-assisted authoring and reusable prompt](docs/ai-assisted.md)
- [API and package contract](docs/api.md)
- [Publication and verification](docs/publication.md)
- `sdk/Contract.cs`: canonical public contract.
- `examples/template`: non-controlling starting point.
- `plugins/hp-8570w`: real Community example for one documented HP configuration. Its binary has not passed live plugin acceptance. Prefer the embedded Verified provider.

Verified implementations are compiled into Battery Guard; Community DLLs run in the same elevated controller process after explicit package approval. The independent recovery guardian loads the exact pinned package as well. Neither process is a sandbox. Listing, downloading, importing, or comparing model identifiers never executes plugin code.

Anyone may propose source through a pull request. A successful build does not confer Verified status or automatically publish executable code. Do not commit binaries, secrets, machine serials or Windows installation identifiers.
