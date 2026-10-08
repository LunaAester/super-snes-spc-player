# Super SNES SPC Player! Ver.1.1

Development version: **1.3.1-E**.

- Fix the UI sound driver's activation/release race and require its ready acknowledgement.
- Check both AA/BB IPL-ready bytes when acquiring the APU, including warm entry.
- Recover a known interrupted native IPL upload and retry once. Snapshot preparation happens only once.
- Preserve safe rejection of unsupported SPCs and navigation without RESET.
- Add Start+X credits, with B returning while music continues.
- Update the opening logo and HUD to Ver.1.1; credits show Dev Ver.1.3.1-E.
- Convert the supplied CHORD.WAV error cue to one 5,094-byte 8 kHz mono BRR sample.
- Publish game-level compatibility coverage from unchanged original SPCs.

Choose `SSPC11H.SMC` (HiROM FastROM) or `SSPC11L.SMC` (LoROM). The new
LoROM assets use the correct ROM mirrors rather than the WRAM banks.
See [validation](docs/VALIDATION.md) and [supported games](docs/SUPPORTED_GAMES.md).
Physical console validation of this release remains required.
