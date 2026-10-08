; Display strings are separate from the original FAT entries and SPC snapshots.
; 96 * 256 bytes at $7F9000; temporary LFN at $0700; active title at $1400.
; $1D20 active LFN, $1D21 expected ordinal, $1D22 checksum, $1D23 ordinal.
TitleReset:
 stz $1d20
 stz $1d21
 rts
TitleDirectoryReset:
 jsr TitleReset
 rep #$20
 .ACCU 16
 lda #$ffff
 sta $1d42
 sep #$20
 .ACCU 8
 stz $1d40
 stz $1d41
 rts

LFNEntry:
 .ACCU 8
 lda $020c,y
 beq P5Long_titles_0
 jmp LFNInvalid
P5Long_titles_0:
 lda $021a,y
 ora $021b,y
 beq P5Long_titles_1
 jmp LFNInvalid
P5Long_titles_1:
 lda $0200,y
 and #$a0
 beq P5Long_titles_2
 jmp LFNInvalid
P5Long_titles_2:
 lda $0200,y
 and #$1f
 bne P5Long_titles_3
 jmp LFNInvalid
P5Long_titles_3:
 cmp #21
 bcc P5Long_titles_4
 jmp LFNInvalid
P5Long_titles_4:
 sta $1d23
 lda $0200,y
 and #$40
 bne P5Long_titles_5
 jmp LFNContinue
P5Long_titles_5:
 lda #1
 sta $1d20
 lda $1d23
 sta $1d21
 lda $020d,y
 sta $1d22
 ldx #255
LFNClear:
 stz $0700,x
 dex
 bmi P5Long_titles_6
 jmp LFNClear
P5Long_titles_6:
LFNContinue:
 lda $1d20
 bne P5Long_titles_7
 jmp LFNInvalid
P5Long_titles_7:
 lda $1d23
 cmp $1d21
 beq P5Long_titles_8
 jmp LFNInvalid
P5Long_titles_8:
 lda $020d,y
 cmp $1d22
 beq P5Long_titles_9
 jmp LFNInvalid
P5Long_titles_9:
 rep #$20
 .ACCU 16
 lda $1d23
 and #255
 dec a
 sta $1d24
 asl a
 asl a
 sta $1d26
 asl a
 clc
 adc $1d26
 adc $1d24
 tax
 sep #$20
 .ACCU 8
 stz $1d2a
LFNCharacter:
 phy
 rep #$20
 .ACCU 16
 lda $1d2a
 and #255
 tay
 lda.w LFNOffsets,y
 and #255
 clc
 adc $56
 tay
 lda $0200,y
 jsr TitleUnicode
 sep #$20
 .ACCU 8
 ply
 cpx #255
 bcc P5Long_titles_10
 jmp LFNCharacterSkip
P5Long_titles_10:
 sta $0700,x
LFNCharacterSkip:
 inx
 inc $1d2a
 lda $1d2a
 cmp #13
 beq P5Long_titles_11
 jmp LFNCharacter
P5Long_titles_11:
 dec $1d21
 rts
LFNInvalid:
 jmp TitleReset
LFNOffsets:
 .db 1,3,5,7,9,14,16,18,20,22,24,28,30

; Latin accents use their closest glyph in the supplied font; unknown UTF-16 is '?'.
TitleUnicode:
 .ACCU 16
 cmp #$ffff
 bne P5Long_titles_12
 jmp TitleNull16
P5Long_titles_12:
 cmp #0
 bne P5Long_titles_13
 jmp TitleNull16
P5Long_titles_13:
 cmp #32
 bcs P5Long_titles_14
 jmp TitleUnknown16
P5Long_titles_14:
 cmp #127
 bcs P5Long_titles_15
 jmp TitleCharacter16
P5Long_titles_15:
 phx
 ldx #0
TitleAccentLoop:
 cmp.w TitleAccents,x
 bne P5Long_titles_16
 jmp TitleAccentFound
P5Long_titles_16:
 inx
 inx
 cpx #52
 beq P5Long_titles_17
 jmp TitleAccentLoop
P5Long_titles_17:
 plx
TitleUnknown16:
 lda #63
 rts
TitleAccentFound:
 txa
 lsr a
 tax
 lda.w TitleAccentLetters,x
 and #255
 plx
 rts
TitleNull16:
 lda #0
TitleCharacter16:
 rts
TitleAccents:
 .dw $c0,$c1,$c2,$c4,$c7,$c8,$c9,$ca,$cb,$cd,$ce,$cf,$d1,$d3,$d4,$d6,$da,$dc,$e1,$e9,$ed,$f1,$f3,$fa,$fc,$e7
TitleAccentLetters:
 .db "AAAACEEEEIIINOOOUUaeinouuc"

TitleSaveEntry:
 phx
 phy
 .ACCU 8
 lda $1d20
 bne P5Long_titles_18
 jmp TitleShortName
P5Long_titles_18:
 lda $1d21
 beq P5Long_titles_19
 jmp TitleShortName
P5Long_titles_19:
 stz $1d2b
 ldx #0
TitleChecksum:
 lda $1d2b
 lsr a
 bcc +
 ora #$80
+:
 clc
 adc $0200,y
 sta $1d2b
 iny
 inx
 cpx #11
 beq P5Long_titles_20
 jmp TitleChecksum
P5Long_titles_20:
 cmp $1d22
 beq P5Long_titles_21
 jmp TitleShortName
P5Long_titles_21:
 lda $0700
 beq P5Long_titles_22
 jmp TitleCopy
P5Long_titles_22:
TitleShortName:
 ldy $56
 ldx #0
TitleShortCopy:
 lda $0200,y
 sta $0700,x
 iny
 inx
 cpx #8
 beq P5Long_titles_23
 jmp TitleShortCopy
P5Long_titles_23:
 stz $0708
 ldy $56
 lda $020b,y
 and #$10
 beq P5Long_titles_24
 jmp TitleCopy
P5Long_titles_24:
 jsr TitleHeader
TitleCopy:
 rep #$20
 .ACCU 16
 lda $44
 xba
 tax
 stx $1d28
 ldy #0
 sep #$20
 .ACCU 8
TitleCopyLoop:
 lda $0700,y
 bne P5Long_titles_25
 jmp TitleCopied
P5Long_titles_25:
 jsr TitleASCII
 sta.l $7f9000,x
 iny
 inx
 cpy #255
 beq P5Long_titles_26
 jmp TitleCopyLoop
P5Long_titles_26:
TitleCopied:
 rep #$20
 .ACCU 16
 tya
 sta $1d2c
 sep #$20
 .ACCU 8
 ; Strip the filename suffix only; the short FAT entry is never edited.
 ldy $56
 lda $020b,y
 and #$10
 beq P5Long_titles_27
 jmp TitleTrim
P5Long_titles_27:
 ldy $1d2c
 cpy #4
 bcs P5Long_titles_28
 jmp TitleTrim
P5Long_titles_28:
 lda.l $7f8ffc,x
 cmp #'.'
 beq P5Long_titles_29
 jmp TitleTrim
P5Long_titles_29:
 lda.l $7f8ffd,x
 and #$df
 cmp #'S'
 beq P5Long_titles_30
 jmp TitleTrim
P5Long_titles_30:
 lda.l $7f8ffe,x
 and #$df
 cmp #'P'
 beq P5Long_titles_31
 jmp TitleTrim
P5Long_titles_31:
 lda.l $7f8fff,x
 and #$df
 cmp #'C'
 beq P5Long_titles_32
 jmp TitleTrim
P5Long_titles_32:
 dex
 dex
 dex
 dex
TitleTrim:
 cpx $1d28
 bne P5Long_titles_33
 jmp TitleTerminate
P5Long_titles_33:
 lda.l $7f8fff,x
 cmp #32
 beq P5Long_titles_34
 jmp TitleTerminate
P5Long_titles_34:
 dex
 jmp TitleTrim
TitleTerminate:
 lda #0
 sta.l $7f9000,x
 jsr TitleReset
 ply
 plx
 rts

TitleASCII:
 .ACCU 8
 cmp #32
 bcs P5Long_titles_35
 jmp TitleUnknown8
P5Long_titles_35:
 cmp #127
 bcc P5Long_titles_36
 jmp TitleUnknown8
P5Long_titles_36:
 rts
TitleUnknown8:
 lda #'?'
 rts

; Only aliases without a valid LFN need a single header-sector read for ID666.
; Keep the current directory sector/LBA/cluster intact across this read.
TitleHeader:
 lda $4d
 pha
 rep #$20
 .ACCU 16
 lda $20
 sta $1d30
 lda $22
 sta $1d32
 lda $38
 sta $1d34
 lda $3a
 sta $1d36
 lda $021a,y
 sta $38
 lda $0214,y
 and #$0fff
 sta $3a
 ldx #0
TitleBackupSector:
 lda $0200,x
 ; Directory-sector backup stays outside the live DSP/input state.
 sta.l $7e5200,x
 inx
 inx
 cpx #512
 beq P5Long_titles_37
 jmp TitleBackupSector
P5Long_titles_37:
 sep #$20
 .ACCU 8
 jsr ClusterSector
 bcc P5Long_titles_38
 jmp TitleHeaderRestore
P5Long_titles_38:
 jsr ReadSector
 bcc P5Long_titles_39
 jmp TitleHeaderRestore
P5Long_titles_39:
 lda $0223
 cmp #$1a
 beq P5Long_titles_40
 jmp TitleHeaderRestore
P5Long_titles_40:
 ldx #0
TitleHeaderSignature:
 lda $0200,x
 cmp.w Signature,x
 beq P5Long_titles_41
 jmp TitleHeaderRestore
P5Long_titles_41:
 inx
 cpx #26
 beq P5Long_titles_42
 jmp TitleHeaderSignature
P5Long_titles_42:
 lda $022e
 cmp #32
 bcs P5Long_titles_43
 jmp TitleHeaderRestore
P5Long_titles_43:
 ldx #0
TitleHeaderCopy:
 lda $022e,x
 sta $0700,x
 inx
 cpx #32
 beq P5Long_titles_44
 jmp TitleHeaderCopy
P5Long_titles_44:
 stz $0720
TitleHeaderRestore:
 rep #$20
 .ACCU 16
 ldx #0
TitleRestoreSector:
 lda.l $7e5200,x
 sta $0200,x
 inx
 inx
 cpx #512
 beq P5Long_titles_45
 jmp TitleRestoreSector
P5Long_titles_45:
 lda $1d30
 sta $20
 lda $1d32
 sta $22
 lda $1d34
 sta $38
 lda $1d36
 sta $3a
 sep #$20
 .ACCU 8
 pla
 sta $4d
 rts

TitleSavePlaying:
 phx
 phy
 rep #$20
 .ACCU 16
 lda $46
 xba
 tax
 ldy #0
 sep #$20
 .ACCU 8
TitlePlayingCopy:
 lda.l $7f9000,x
 sta $1400,y
 inx
 iny
 cpy #256
 beq P5Long_titles_46
 jmp TitlePlayingCopy
P5Long_titles_46:
 stz $1d44
 lda #36
 sta $1d45
 ply
 plx
 rts

; Selected and playing titles scroll independently without altering selection.
HUDTitleTick:
 .ACCU 16
 lda $46
 cmp $1d42
 bne P5Long_titles_47
 jmp HUDTitleSame
P5Long_titles_47:
 sta $1d42
 sep #$20
 .ACCU 8
 lda #36
 sta $1d40
 stz $1d41
 jmp HUDTitlePlayingTick
HUDTitleSame:
 sep #$20
 .ACCU 8
 lda $1d40
 bne P5Long_titles_48
 jmp HUDTitleAdvance
P5Long_titles_48:
 dec $1d40
 jmp HUDTitlePlayingTick
HUDTitleAdvance:
 lda #6
 sta $1d40
 inc $1d41
HUDTitlePlayingTick:
 lda $1d45
 bne P5Long_titles_49
 jmp HUDTitlePlayingAdvance
P5Long_titles_49:
 dec $1d45
 rts
HUDTitlePlayingAdvance:
 lda #6
 sta $1d45
 inc $1d44
 rts

HUDListTitle:
 .ACCU 8
 phx
 phy
 rep #$20
 .ACCU 16
 lda $76
 xba
 tax
 sep #$20
 .ACCU 8
 ldy #0
HUDListLength:
 lda.l $7f9000,x
 bne P5Long_titles_50
 jmp HUDListLengthDone
P5Long_titles_50:
 inx
 iny
 cpy #255
 beq P5Long_titles_51
 jmp HUDListLength
P5Long_titles_51:
HUDListLengthDone:
 rep #$20
 .ACCU 16
 sty $1d48
 lda $76
 xba
 sta $1d4a
 cmp #$6000
 bcc P5Long_titles_52
 jmp HUDListFinished16
P5Long_titles_52:
 lda $76
 cmp $46
 beq P5Long_titles_53
 jmp HUDListPlain
P5Long_titles_53:
 lda $1d48
 cmp #19
 bcs P5Long_titles_54
 jmp HUDListPlain
P5Long_titles_54:
 sep #$20
 .ACCU 8
 lda $1d41
 rep #$20
 .ACCU 16
 and #255
 cmp $1d48
 bcs P5Long_titles_55
 jmp HUDListOffset
P5Long_titles_55:
 sep #$20
 .ACCU 8
 stz $1d41
 lda #36
 sta $1d40
 rep #$20
 .ACCU 16
 lda #0
HUDListOffset:
 sta $1d4c
 jmp HUDListDraw
HUDListPlain:
 stz $1d4c
HUDListDraw:
 .ACCU 16
 ldy #18
HUDListChar:
 lda $1d4c
 cmp $1d48
 bcc P5Long_titles_56
 jmp HUDListSpace16
P5Long_titles_56:
 clc
 adc $1d4a
 tax
 sep #$20
 .ACCU 8
 lda.l $7f9000,x
 jmp HUDListPut
HUDListSpace16:
 sep #$20
 .ACCU 8
 lda #32
HUDListPut:
 jsr PutChar
 rep #$20
 .ACCU 16
 inc $1d4c
 dey
 beq P5Long_titles_57
 jmp HUDListChar
P5Long_titles_57:
HUDListFinished16:
 sep #$20
 .ACCU 8
 ply
 plx
 rts

HUDPlayingTitle:
 .ACCU 8
 ldx #0
HUDPlayingLength:
 lda $1400,x
 bne P5Long_titles_58
 jmp HUDPlayingLengthDone
P5Long_titles_58:
 inx
 cpx #255
 beq P5Long_titles_59
 jmp HUDPlayingLength
P5Long_titles_59:
HUDPlayingLengthDone:
 stx $1d48
 cpx #20
 bcs P5Long_titles_60
 jmp HUDPlayingNoScroll
P5Long_titles_60:
 lda $1d44
 rep #$20
 .ACCU 16
 and #255
 cmp $1d48
 bcs P5Long_titles_61
 jmp HUDPlayingOffset
P5Long_titles_61:
 sep #$20
 .ACCU 8
 stz $1d44
 lda #36
 sta $1d45
HUDPlayingNoScroll:
 rep #$20
 .ACCU 16
 lda #0
HUDPlayingOffset:
 tax
 sep #$20
 .ACCU 8
 ldy #19
HUDPlayingChar:
 cpx $1d48
 bcc P5Long_titles_62
 jmp HUDPlayingSpace
P5Long_titles_62:
 lda $1400,x
 jmp HUDPlayingPut
HUDPlayingSpace:
 lda #32
HUDPlayingPut:
 jsr PutChar
 inx
 dey
 beq P5Long_titles_63
 jmp HUDPlayingChar
P5Long_titles_63:
 rts
