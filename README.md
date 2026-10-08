# Super SNES SPC Player! 1.0

Luna's public 1.0 edition, based on the internal v1.3.E development build.

[Español](LEEME.md) · [Release notes](RELEASE_NOTES.md)

![Player views](media/Preview.png)

Copy **roms/SSPC10H.SMC** (HiROM FastROM) or **roms/SSPC10L.SMC** (LoROM fallback) to your FAT32 microSD and launch it from the cartridge menu. Both ROMs are 4 MiB. Keep your existing SPC folders; supported original files load directly without conversion or a companion index. The player never writes to the card.

Requires a cartridge with a Super EverDrive V1 compatible SD interface.
Not all flashcarts implement that interface.

## Features

- Tempo and volume chords work after switching to MONO, including when Select is still held or the direction is pressed before X/Y. Brief presses are latched during audio operations.
- Donkey Kong Country drivers retain tempo changes through their native timer updates.
- Holding Up/Down moves once, waits 40 video frames (about 0.67 seconds NTSC or 0.8 seconds PAL), then repeats every 6 frames. Navigation wraps between first and last entries.
- Three audio views: stereo LEDs, 20-segment bars for each of the eight voices, and eight sparse DSP OUTX traces.
- Eight pages including the player view, mixer/echo/FIR, voice volumes/pitch, ADSR/GAIN, voice flags, sample directory addresses, music tags, and file tags.
- Elapsed playback time appears in the header. The English opening, sounds, loading progress, scrolling titles without .spc, and Stop/Back behavior are retained.

## Controls

| Button | Action |
|---|---|
| Up / Down | Browse; hold to repeat; wrap at either end |
| A | Open a folder or play/replace a song |
| B | Parent folder; keep the song playing |
| L / R | Previous / next song |
| Y + Left / Right | Tempo, with pitch retained on supported drivers |
| X + Up / Down | Volume, 0–100% |
| Select + A | Stop |
| Select + B | MONO / STEREO, where supported |
| Select + Start | Stereo LEDs → eight voice bars → DSP traces; return to player view |
| Select + L / R | Previous / next information page; wrap through all pages |

RESET is not a playback or navigation command. STEREO* means the selected driver/layout retains stereo because MONO control is not supported there.

## Information and visualizations

DSP readings are asynchronous observations from the real audio processor. The traces use signed OUTX samples, amplified for visibility, at a much lower rate than PCM. They are not a full audio oscilloscope recording. Voice meters have a short display hold so sparse observations remain visible; their level is a voice estimate before master volume, not a calibrated output meter. ON indicates an observed nonzero ENVX, not the DSP's hidden envelope phase.

Sample START/LOOP addresses come from the original SPC directory, indexed by the observed source number. READ PTR displays -- because the DSP's internal BRR read position is not available to the console CPU.

Music/file pages read standard ID666 tags. Text/binary detection is best effort because ID666 has no unambiguous format flag. Binary dates are shown as raw HEX; text dates are preserved. Numeric values exceeding 65535 show 65535+. Tag play/fade durations are information, not automatic stop/fade scheduling. xid6 extensions and missing tags are not reconstructed. Filenames and tags are not translated.

## Compatibility

Compatibility remains partial. A valid SPC can use an unsupported driver, state, or memory layout. Error **67 / UNSUPPORTED SPC / LAYOUT** rejects it before playback; B returns to the browser. The checked development compatibility catalog is retained. See [compatibility.csv](docs/compatibility.csv) for the tested files, rather than assuming every track from a supported game works.

Fresh, self-contained C700 exports using the checked driver load directly. Oversized exports requiring a separate .700 stream remain unsupported. The player checks control storage, executable instructions, sample ranges, and echo memory before changing its temporary RAM copy; original SPCs stay unchanged.

Use uncompressed SPC files on FAT32. The browser supports 96 entries per folder and 15 folder levels. Split larger collections into folders. Songs from commercial games are not bundled.

## Validation and source

The development runtime was tested in Snes9x/libretro with a virtual filesystem, including real button input, PCM audio comparisons, volume mute/restore, tempo timers, MONO paths, stereo fallbacks, all views/pages, metadata variants, safe rejection, and Stop/reload without RESET. This does not emulate the clone cartridge's SD electrical interface. **Physical SNES/cart testing is still required.** See [VALIDATION.md](docs/VALIDATION.md) for the exact scope.

Rebuild the supplied production catalog using Python 3 and WLA-DX 10.7:

    python src/build.py --both --tool-dir "PATH_TO_WLA_DX"
    python tools/verify_release.py

Precompiled graphics, BRR sounds, and driver guards are supplied. Rebuilding does not require an SPC collection, Pillow, NumPy, or ffmpeg. Developing support for an additional driver requires separate analysis and validation. Artwork/audio credits are in [CREDITS.md](CREDITS.md).

## Documentation

- [Full error reference](docs/ERRORS.md)
- [Build instructions](docs/BUILD.md)
- [GitHub publication guide (Spanish)](docs/PUBLICAR_GITHUB.md)
- [Release notes](RELEASE_NOTES.md)

## License

No project-wide license has been selected. Credits for supplied assets
are preserved in [CREDITS.md](CREDITS.md).
