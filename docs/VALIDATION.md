# Validation — public 1.0

This public edition uses the internal v1.3.E runtime. Each production ROM
differs from that build by exactly 21 bytes: the internal title, three native
HUD version labels and checksum fields. All other runtime and asset bytes are
identical. The version change adds no SPC driver support.

## Checks on the 1.0 binaries

- Both 4 MiB mappings build successfully with WLA-DX 10.7 and Python.
- Headers, mapping bytes, internal titles, complementary SNES checksums and
  SHA-256 are checked. All three native HUD screens display V1.0.
- Snes9x/libretro startup reaches expected error 10 without an emulated cartridge
  SD interface: 834 frames for HiROM, 877 for LoROM. B retries without replaying
  the introduction; the APU returns to IPL.
- Updated native screens are captured in a local virtual-filesystem fixture.
  The representative song plays and Select+A stops without RESET.
- Source from the final GitHub ZIP rebuilds the supplied ROMs byte-for-byte.
- Both ZIP archives pass CRC verification. No private paths, test snapshots,
  saved emulator states, tool binaries or commercial SPC collection are bundled.

Current binary observations are recorded in validation_1_0.json and
../manifest.json. Screenshots use a local test filesystem; it is not distributed.

## Inherited development regression

These are existing v1.3.E results, not a new full-library run for public 1.0:

- HiROM: 1,073 files, 677 accepted, 396 safely rejected, zero unexpected failures.
- LoROM: 516 additional files, 120 accepted, 396 safely rejected. The older
  collection was not completely rerun on LoROM.
- Accepted files play for three seconds and stop without RESET; additional
  accepted files also reload, play for one second and stop again. This is a
  transfer/control regression, not a complete-song audit of every track.
- Representative C700, Plok, Mega Man X, Mega Man 7 and Donkey Kong Country
  1/2/3 control checks cover volume silence/restoration, native tempo timers,
  MONO paths/stereo fallbacks, input chords, all views/pages and metadata.
- 36 ten-second audio comparisons cover C700, Plok and DKC2 in six views/pages
  and both mappings: envelope correlation >0.98, spectral correlation >0.99,
  RMS gain 0.98–1.02. DSP phase need not match bit-for-bit.
- Held-button repeat, first/last wrapping, PAL timing, metadata variants,
  one-frame button presses and safe rejection/recovery were tested.

Physical SNES/cartridge testing of the public 1.0 edition remains required.
The emulator fixture does not emulate the clone cartridge SD electrical interface.
The compatibility catalog is partial; original song files are never modified.
