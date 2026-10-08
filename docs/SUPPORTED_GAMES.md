# Supported games — Ver.1.1

This list records **tested samples**, not a guarantee for every release, region,
driver variant or track of a game. Both HiROM and LoROM produced identical
accept/reject results. Accepted snapshots were transferred, played for three
seconds and stopped without RESET. Rejected files returned error 67 before
playback, and B returned to the browser. Original SPC files were unchanged.

The ROM recognizes driver code, timers and safe memory layouts automatically;
it does not use game names or this document as an allow-list. Users do not need
to convert supported SPCs or ask the developer to prepare individual tracks.

Totals: **1,631 load tests per mapping**, **677 accepted**, **954 safely
rejected**, **zero unexpected failures**. The set contains 1,610 distinct file
hashes; duplicate files in different collections account for the difference.

Sources: the supplied library and [Zophar's SNES SPC catalogue](https://www.zophar.net/music/nintendo-snes-spc).
Eleven additional original Zophar collections (558 snapshots) were checked;
their tested drivers are not yet supported. This release does not add a new
driver family. Adding a title to a document cannot enable its driver.

## Games with compatible tested snapshots

“Tested samples accepted” means every snapshot in this particular test set
passed. It does not mean that the complete game soundtrack has been audited.

| Game | Accepted / tested unique snapshots | Coverage |
|---|---:|---|
| ActRaiser | 19 / 19 | tested samples accepted |
| Aero the Acro-Bat | 23 / 23 | tested samples accepted |
| Aero the Acro-Bat 2 | 18 / 18 | tested samples accepted |
| Battle Cars | 10 / 10 | tested samples accepted |
| Donkey Kong Country | 25 / 29 | partial |
| Donkey Kong Country 2 - Diddy's Kong Quest | 44 / 109 | partial |
| Donkey Kong Country 3 - Dixie Kong's Double Trouble | 48 / 77 | partial |
| Faceball 2000 | 11 / 11 | tested samples accepted |
| Jissen Pachi Slot Hisshouhou! Classic | 18 / 18 | tested samples accepted |
| Kirby's Avalanche  [Kirby's Ghost Trap] | 35 / 35 | tested samples accepted |
| Mega Man 7 | 2 / 45 | partial |
| Mega Man X | 35 / 35 | tested samples accepted |
| Mickey Mania - The Timeless Adventures of Mickey Mouse | 23 / 23 | tested samples accepted |
| Nosferatu | 15 / 15 | tested samples accepted |
| Pac-Man 2 - The New Adventures | 72 / 72 | tested samples accepted |
| Pac-in-Time | 20 / 20 | tested samples accepted |
| Plok | 20 / 20 | tested samples accepted |
| Rock n' Roll Racing | 5 / 5 | tested samples accepted |
| Romancing SaGa 2 | 42 / 42 | tested samples accepted |
| Side Pocket | 1 / 1 | tested samples accepted |
| Sparkster | 21 / 21 | tested samples accepted |
| Super Puyo Puyo Tsuu | 16 / 16 | tested samples accepted |
| Super Tetris 3 | 33 / 33 | tested samples accepted |
| Tetris Attack | 52 / 52 | tested samples accepted |
| Toy Story | 21 / 21 | tested samples accepted |
| Zero - The Kamikaze Squirrel | 18 / 18 | tested samples accepted |

## Unsupported in the tested samples

| Game | Accepted / tested unique snapshots | Coverage |
|---|---:|---|
| Addams Family Values | 0 / 16 | unsupported in tested samples |
| Chrono Trigger | 0 / 92 | unsupported in tested samples |
| Contra III - The Alien Wars | 0 / 15 | unsupported in tested samples |
| EarthBound | 0 / 206 | unsupported in tested samples |
| Equinox | 0 / 16 | unsupported in tested samples |
| F-Zero | 0 / 17 | unsupported in tested samples |
| Final Fantasy VI | 0 / 82 | unsupported in tested samples |
| Jurassic Park Part 2 - The Chaos Continues | 0 / 16 | unsupported in tested samples |
| Kirby Super Star  [Kirby's Fun Pak] | 0 / 70 | unsupported in tested samples |
| Secret of Mana | 0 / 69 | unsupported in tested samples |
| Super Castlevania IV | 0 / 36 | unsupported in tested samples |
| Super Ghouls'n Ghosts | 0 / 23 | unsupported in tested samples |
| Super Mario Kart | 0 / 52 | unsupported in tested samples |
| Super Mario World | 0 / 66 | unsupported in tested samples |
| Super Metroid | 0 / 36 | unsupported in tested samples |

## C700 exports

9 of 10 distinct exports passed. Self-contained exports with a checked driver can load directly. Oversized
exports requiring a separate .700 stream remain unsupported.

## Scope

These are Snes9x/libretro tests with a private virtual filesystem. They do not
emulate the cartridge SD electrical interface and do not establish physical
console compatibility. No commercial song files are distributed. Additional
controls and longer audio comparisons are described in [VALIDATION.md](VALIDATION.md).
