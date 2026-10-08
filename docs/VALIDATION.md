# Validation — public 1.1 / Dev 1.3.1-E

Both production mappings were compiled with Python and WLA-DX 10.7 and checked
for their 4 MiB size, header, mapping, complementary checksum and SHA-256.
The public source rebuilt both supplied ROMs byte-for-byte.

## New regression checks

- 1,631 unmodified SPC load attempts in each mapping: 677 accepted, 954 safe
  error-67 rejections, zero unexpected failures. There are 1,610 distinct file
  hashes. Accepted files play for three seconds and stop without RESET.
- 77 startup/switch/credits checks in each mapping. These cover warm entry with
  a resident UI driver or controlled song, a missing UI ownership flag,
  Start+X credits/B return with music continuing, chained DKC1/EarthBound/
  Addams Family Values/Sparkster/Pac-in-Time/C700 switches, and all 21
  Sparkster plus all 20 Pac-in-Time files in the supplied test set.
- Two forced UI arming/release races per mapping. A pending nonzero cue holds
  the APU in its pre-activation loop; loading a song succeeds both with and
  without the CPU ownership flag. This exercises release before activation.
- Seven interrupted native-IPL transfer tests per mapping: DSP upload, low RAM
  and main RAM, including first-byte and counter/page-wrap boundaries. Each
  aborts, retries once, matches the prepared ARAM image and stops/reloads.
- 36 ten-second audio comparisons (C700, Plok, DKC2; six views/pages; both
  mappings) pass the existing envelope/spectral/gain thresholds. Actual metrics
  are in validation_1_1.json. These are short audio/control checks, not a
  complete-song audit for every file.
- Native introduction, fades, visible-logo/audio timing, idle navigation,
  rapid retrigger/token wrap, MONO/mute and suppression of navigation sounds
  during music pass the UI audio regression.
- Both production ROMs reach expected error 10 in an ordinary emulator without
  the SD interface. The compressed error cue is audible, diagnostics remain
  intact, and B retries without replaying the intro.
- Native screenshots/video show Ver.1.1 in the HUD/logo and Dev Ver.1.3.1-E in
  credits. LoROM credits/audio use $fe ROM rather than $7e WRAM.

## Practical limits

Tests use Snes9x/libretro and a private virtual filesystem. This does not
emulate the cartridge SD electrical interface. **Physical SNES/cart testing
of edition 1.1 is still required.** A known interrupted IPL stream can be
recovered; arbitrary uncooperative APU programs cannot be reset by the console
CPU. Recovery remains bounded and unsupported song drivers are rejected.

The eleven new Zophar collections were safely rejected. Compatibility is
partial; this release does not enable all games in the catalogue. See
[Supported games](SUPPORTED_GAMES.md) for observed game-level coverage.

## Console confirmation sequence

1. Copy SSPC11H.SMC or SSPC11L.SMC to the existing FAT32 card and boot through
   EverDrive's last-game shortcut; repeat after manually selecting the ROM.
2. Play DKC1, then switch directly to Sparkster, Pac-in-Time and a standalone
   C700 export while the previous song is playing.
3. Try a rejected EarthBound/Addams Family Values snapshot, press B and play
   the same C700 file again. No RESET should be required.
4. Check Select+A stop, MONO/tempo/volume, and Start+X credits/B return.
5. If 51/52 persists, preserve a full-screen photo including APU STEP/BYTE and
   the exact original filename; those fields identify the failing phase.
