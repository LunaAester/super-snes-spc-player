# Error reference — 1.1

Codes are displayed in hexadecimal. 00 means no error. APU, CFG/STATUS,
SD CMD/R1, LBA and ARG/CRC are diagnostic fields; the failure code is
the value next to ERROR.

## microSD / SPI

| Code | Meaning |
|---|---|
| **03** | Sector data failed the CRC16 integrity check. |
| **10** | Cartridge SPI interface timeout; also expected in emulators without that SD interface. |
| **11** | No SD command response (R1) within the polling limit. |
| **12** | The SD rejected CMD58 (READ_OCR). |
| **13** | The SD reports that initialization is incomplete. |
| **14** | The SD rejected CMD17 (READ_SINGLE_BLOCK). |
| **15** | The expected sector-data start token did not arrive. |
| **16** | An unexpected/error data token arrived while waiting for a sector. |
| **18** | CMD0 did not place the SD in its idle state after the reset attempts. |
| **19** | Unexpected or malformed CMD8 identification response. |
| **1A** | CMD55 or ACMD41 initialization was rejected. |
| **1B** | The SD stayed idle after all initialization retries. |
| **1C** | The SD declares no supported voltage window; this is not a console power measurement. |
| **1D** | An SDSC card rejected CMD16 for 512-byte blocks. |

## FAT32 / files

| Code | Meaning |
|---|---|
| **20** | Missing 55AA signature in the boot/partition sector. |
| **21** | No recognized FAT32 partition was found. |
| **22** | Invalid or unsupported FAT32 BPB parameters. |
| **23** | Invalid FAT32 volume geometry or cluster count. |
| **31** | Invalid cluster number or cluster outside the volume. |
| **32** | Directory traversal exceeded 1024 sectors; the directory may be very large or its FAT chain circular. |
| **33** | The 15-level subfolder limit was reached. |
| **41** | The file is smaller than the required 66048 bytes. |
| **42** | The file cluster chain ended before the required SPC data was read. |

## Audio / compatibility

| Code | Meaning |
|---|---|
| **51** | The APU was not ready in its IPL upload state. |
| **52** | APU upload/preparation handshake timed out. |
| **53** | The APU did not return to IPL after Stop or release of menu audio. |
| **54** | The driver did not acknowledge the final playback start. |
| **67** | SPC validation failed: invalid format, unsupported driver/variant or unsafe playback/control state/layout. |
| **68** | The driver did not acknowledge a runtime control or DSP-data command. |

**67 does not necessarily mean a damaged SPC.** A valid file may need
additional driver, state or memory-layout support to keep controls and
track changes available without RESET.

## Legacy codes

These belong to earlier loaders. Normal 1.1 compatibility validation
reports these rejections as 67.

| Code | Original meaning |
|---|---|
| **61** | Old header/C700 loader validation failed. |
| **62** | P3 did not recognize an admitted game driver. |
| **63** | The old Stop-hook storage was occupied or unsuitable. |
| **64** | The saved communication port conflicted with the old Stop-request value. |
| **66** | The saved state was unsuitable for the old general resume loader. |

**7E** is test-ROM-only: a sector is missing from the simulated filesystem.
It is not active in production ROMs.

## APU transfer diagnostics in 1.1

`APU STEP/BYTE` displays the upload phase and last native-IPL byte offset.
Phases: 00 before upload; 01 IPL-ready wait; 02 DSP program upload; 03 DSP
start; 04 echo settling; 05 DSP release; 06 low RAM; 07 main RAM; 08 resume
bootstrap; 09 input-port restore; 0A final controlled-driver acknowledgement.

A known interrupted native-IPL transfer is retried once. Error 52 still reports
a failure after that bounded retry, or a handshake that cannot safely be
retried. Error 51 can still occur if the actual APU cannot return to IPL.
The error cue plays once when the APU can be recovered; an unresponsive APU
cannot play it. The on-screen diagnostics are drawn before the cue upload.
