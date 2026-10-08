; The existing 32 KiB data blocks occupy pairs of native 64 KiB HiROM banks.
; All data pointers, including the audio and SPC-control profiles, are remapped.
.MACRO ROMBLOCK ARGS number,offset
 .IFDEF HIROMBUILD
  .BANK (number/2) SLOT 0
  .ORG ((number&1)*$8000)+offset
 .ELSE
  .BANK number SLOT 0
  ; Banks $7e/$7f are WRAM: the last LoROM blocks use their $fe/$ff mirrors.
  .IF number >= 126
   .BASE $80
  .ELSE
   .BASE 0
  .ENDIF
  .ORG offset
 .ENDIF
.ENDM
