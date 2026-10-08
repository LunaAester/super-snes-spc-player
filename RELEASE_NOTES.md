# Super SNES SPC Player! 1.0

First public edition of Luna's SNES SPC player, based on the internal v1.3.E
development build.

Copy `SSPC10H.SMC` (HiROM FastROM) or `SSPC10L.SMC` (LoROM alternative) to a
FAT32 microSD and launch it from a cartridge with a compatible Super EverDrive
V1 SD interface. Keep compatible, uncompressed SPC files in your own folders.
Both ROMs are 4 MiB, and the player never writes to the card.

Features include playback and folder controls without RESET, volume and tempo
controls, supported MONO/STEREO switching, three audio views, eight information
pages, an English HUD, animated opening and loading progress.

Compatibility is partial: error 67 rejects unsupported drivers or layouts.
Self-contained C700 exports using the checked driver load directly; exports
requiring a separate `.700` stream are unsupported. Folder limits are 96 entries
and 15 levels. No game music collection is included.

The 1.0 binaries have been rebuilt and checked for their version assets, headers,
checksums, startup and reproducibility. Runtime functionality and the compatibility
catalog come from the v1.3.E emulator regression. Physical testing of this renamed
edition on the SNES/cartridge remains required. A PC emulator without the
cartridge SD interface reaches expected error 10 after the opening.

See README.md / LEEME.md, docs/ERRORS.md / docs/ERRORES.md,
docs/compatibility.csv, docs/BUILD.md and CREDITS.md in the source package.
