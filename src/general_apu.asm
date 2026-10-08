.include "general_fields.inc"

; General playback borrows inactive stack RAM for a single-use restoration.
; No driver replacement or permanent stop hook is installed in this mode.
GeneralValidate:
 lda #3
 sta $1860
 rep #$20
 .ACCU 16
 stz $1864
 stz $1866
 stz $1868
 lda #64
 sta $186c
 lda #$0100
 sta $1862
 sep #$20
 .ACCU 8
 ; A C700 snapshot uses page 1 for code, so reserve its known empty page 3.
 ldx #0
GeneralC700Signature:
 lda.l $7e8200,x
 cmp.w DriverSignature,x
 bne GeneralProfileLookup
 inx
 cpx #48
 bne GeneralC700Signature
 ldx #0
GeneralC700Space:
 lda.l $7e8400,x
 beq +
 jmp GeneralUnsupported
+:
 inx
 cpx #64
 bne GeneralC700Space
 rep #$20
 .ACCU 16
 lda #$0300
 sta $1862
 sep #$20
 .ACCU 8
 jmp GeneralCheckPC
GeneralProfileLookup:
 ; These verified drivers store tables in the stack page or use a low SP.
 ; Reserve a checked uniform gap outside that page instead.
 ldx #0
GeneralProfileNext:
 stx $1876
 rep #$20
 .ACCU 16
 lda.w GeneralProfileData,x
 clc
 adc #$8100
 sta $94
 sep #$20
 .ACCU 8
 lda #$7e
 adc #0
 sta $96
 inx
 inx
 inx
 inx
 inx
 inx
 ldy #0
GeneralProfileByte:
 lda [$94],y
 cmp.w GeneralProfileData,x
 bne GeneralProfileMismatch
 inx
 iny
 cpy #48
 bne GeneralProfileByte
 ldx $1876
 rep #$20
 .ACCU 16
 lda.w GeneralProfileData+2,x
 sta $1862
 lda.w GeneralProfileData+4,x
 sta $1878
 lda $1862
 clc
 adc #$8100
 sta $94
 sep #$20
 .ACCU 8
 lda #$7e
 adc #0
 sta $96
GeneralProfileTrySpace:
 ldy #0
 lda [$94],y
 sta $1870
 cmp #0
 beq GeneralProfileSpace
 cmp #$ff
 bne GeneralProfileNoSpace
GeneralProfileSpace:
 lda [$94],y
 cmp $1870
 bne GeneralProfileNoSpace
 iny
 cpy #64
 bne GeneralProfileSpace
 jmp GeneralCheckPC
GeneralProfileNoSpace:
 rep #$20
 .ACCU 16
 lda $1862
 cmp $1878
 beq GeneralProfileFallback
 inc $1862
 inc $94
 sep #$20
 .ACCU 8
 bra GeneralProfileTrySpace
GeneralProfileFallback:
 .ACCU 16
 lda #$0100
 sta $1862
 sep #$20
 .ACCU 8
 bra GeneralStack
GeneralProfileMismatch:
 rep #$20
 .ACCU 16
 lda $1876
 clc
 adc #54
 tax
 sep #$20
 .ACCU 8
 cpx #GENERAL_PROFILE_COUNT*54
 beq GeneralStack
 jmp GeneralProfileNext
GeneralStack:
 ; Reserve at least the restoration code and three bytes of interrupt frame.
 lda.l $7e802b
 cmp #67
 bcs +
 jmp GeneralUnsupported
+:
 ; Prefer a uniform unused portion below the saved stack pointer. Some game
 ; drivers also keep data at the bottom of page 1, so inspect the whole span.
 rep #$20
 .ACCU 16
 lda.l $7e802b
 and #$00ff
 sec
 sbc #67
 sta $1872
 ldx #0
 sep #$20
 .ACCU 8
GeneralFindStack:
 lda.l $7e8200,x
 cmp #0
 beq GeneralTryRun
 cmp #$ff
 bne GeneralNextStack
GeneralTryRun:
 sta $1870
 stx $1874
 ldy #64
GeneralRunByte:
 lda.l $7e8200,x
 cmp $1870
 bne GeneralRunFailed
 inx
 dey
 bne GeneralRunByte
 rep #$20
 .ACCU 16
 lda $1874
 clc
 adc #$0100
 sta $1862
 sep #$20
 .ACCU 8
 bra GeneralCheckPC
GeneralRunFailed:
 ldx $1874
GeneralNextStack:
 cpx $1872
 beq GeneralCheckPC
 inx
 bra GeneralFindStack
GeneralCheckPC:
 ; Reject execution inside the borrowed program area, before any APU upload.
 rep #$20
 .ACCU 16
 lda.l $7e8025
 sec
 sbc $1862
 cmp #64
 bcs +
 sep #$20
 .ACCU 8
 bra GeneralUnsupported
+:
 sep #$20
 .ACCU 8
 ; P=1 addresses page 1 as direct page, so this fallback would alter live data.
 lda $1863
 cmp #1
 bne GeneralAccepted
 lda.l $7e802a
 and #$20
 bne GeneralUnsupported
GeneralAccepted:
 rep #$20
 .ACCU 16
 lda $1862
 clc
 adc #$8100
 sta $94
 sep #$20
 .ACCU 8
 lda #$7e
 adc #0
 sta $96
 stz $4d
 clc
 rts
GeneralUnsupported:
 lda #$66
 jmp FSError

GeneralResumeFields:
 lda.l $7e8100
 sta $1a00+GENERAL_RAM0
 lda.l $7e8101
 sta $1a00+GENERAL_RAM1
 lda.l $7e81f4
 sta $1a00+GENERAL_PORT0
 lda.l $7e81f2
 sta $1a00+GENERAL_DSPADDR
 lda.l $7e81f1
 and #$cf
 sta $1a00+GENERAL_CONTROL
 lda.l $7f814c
 sta $1a00+GENERAL_KON
 lda.l $7f815c
 sta $1a00+GENERAL_KOFF
 lda.l $7f816c
 sta $1a00+GENERAL_FLG
 lda.l $7e8027
 sta $1a00+GENERAL_A
 lda.l $7e8028
 sta $1a00+GENERAL_X
 lda.l $7e8029
 sta $1a00+GENERAL_Y
 lda.l $7e802b
 sec
 sbc #3
 sta $1a00+GENERAL_SP
 rts

GeneralResumeData:
 .incbin "general_resume.bin"
.include "general_profiles.inc"
