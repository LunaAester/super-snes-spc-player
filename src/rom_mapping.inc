; The existing 32 KiB data blocks occupy pairs of native 64 KiB HiROM banks.
; All data pointers, including the audio and SPC-control profiles, are remapped.
.MACRO ROMBLOCK ARGS number,offset
 .IFDEF HIROMBUILD
  .BANK (number/2) SLOT 0
  .ORG ((number&1)*$8000)+offset
 .ELSE
  .BANK number SLOT 0
  .ORG offset
 .ENDIF
.ENDM
