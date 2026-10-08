# Building 1.0

Production ROMs need Python 3.9 or later and WLA-DX 10.7 (`wla-65816` and
`wlalink`). No SPC library, Pillow, NumPy or ffmpeg is required for the normal
build. Graphics, BRR sounds and checked compatibility records are supplied.

From the repository root:

```sh
python src/build.py --both --tool-dir "PATH_TO_WLA_DX"
python tools/verify_release.py
```

If both WLA-DX tools are already on PATH:

```sh
python src/build.py --both
```

Output: `roms/SSPC10H.SMC` (HiROM FastROM) and `roms/SSPC10L.SMC` (LoROM).
Use `--hirom` to build only HiROM; no mapping option builds only LoROM.
`--output-dir PATH` places builds elsewhere. Assembly and branch expansion run
in temporary storage, so builds do not modify the checked-in source files.

`tools/verify_release.py` checks the supplied release against `manifest.json`,
including SHA-256, internal title, mapping, size and SNES checksum. Modified
development builds will intentionally fail the published SHA-256 comparison.

## Source layout

- `main.asm`: startup, input dispatch, ROM header and include layout.
- `sd.asm`, `sd_init.asm`, `spi_crc.asm`: cartridge SD communication.
- `fat.asm`: read-only FAT32 browser and file loading.
- `controls.asm`, `auto_drivers.asm`: checked SPC recognition and controls.
- `apu.asm`, `game_apu.asm`, `general_apu.asm`: audio upload/restoration routines,
  including retained routines from earlier development versions.
- `ui.asm`, `titles.asm`, `hud_meters.asm`, `v13.asm`: HUD and information views.
- `intro.asm`, `present.asm`, `ui_sounds.asm`: presentation and interface audio.
- `*.bin`, `*.BRR`, `*.inc`: native assets, templates and compatibility records.

The `v13` identifiers are retained internally to avoid unrelated code changes.
The public version is 1.0.

## Optional asset editing

`src/build_hud_assets.py` regenerates the font and HUD assets from the included
font sheet. It requires Pillow. `src/generate_v13.py` regenerates the information
view assembly and panel. Run these only when editing those assets, before the
normal ROM build. Presentation and sound data are supplied precompiled; the
normal build uses those bytes directly.

New SPC driver support requires its own code, memory, sample and echo checks,
then audio/control validation. Adding a game's name to the catalog does not add
support for its driver.
