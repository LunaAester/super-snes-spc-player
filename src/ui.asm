InitVideo:
 lda #$8f
 sta $2100
 lda #0
 ldx #1
UIReset:
 sta $2100,x
 inx
 cpx #$0034
 beq LongBranch_ui_0
 jmp UIReset
LongBranch_ui_0:
 stz $210d
 stz $210d
 stz $210e
 stz $210e
 lda #$20
 sta $2107
 lda #1
 sta $212c
 lda #$80
 sta $2115
 stz $2121
 ldx #0
UIPalette:
 lda.w PaletteData,x
 sta $2122
 inx
 cpx #64
 beq P5Long_ui_0
 jmp UIPalette
P5Long_ui_0:
 rep #$20
 .ACCU 16
 ldx #0
 stx $2116
UIFont:
 lda.l FontData,x
 sta $2118
 inx
 inx
 cpx #(FontEnd-FontData)
 beq LongBranch_ui_1
 jmp UIFont
LongBranch_ui_1:
 sep #$20
 .ACCU 8
 rts
DrawLoading:
 jsr HUDClearMeters
 stz $1caa
 lda #1
 sta $1cd0
 stz $1cd1
 lda #$8f
 sta $2100
 rep #$20
 .ACCU 16
 ldx #$2000
 stx $2116
 ldx #0
UILoading:
 lda.l LoadingScreen,x
 sta.l $7e3000,x
 sta $2118
 inx
 inx
 cpx #2048
 beq LongBranch_ui_2
 jmp UILoading
LongBranch_ui_2:
 sep #$20
 .ACCU 8
 lda #$0f
 sta $2100
 rts
DrawBrowser:
 stz $1cd0
 lda #1
 sta $1caa
 rep #$20
 .ACCU 16
 jsr HUDTitleTick
 rep #$20
 .ACCU 16
 lda $46
 cmp $48
 bcc P5Long_ui_1
 jmp HUDWithinTop
P5Long_ui_1:
 sta $48
HUDWithinTop:
 lda $48
 clc
 adc #10
 cmp $46
 bcs P5Long_ui_2
 jmp HUDScrollDown
P5Long_ui_2:
 bne P5Long_ui_3
 jmp HUDScrollDown
P5Long_ui_3:
 jmp HUDScrollReady
HUDScrollDown:
 lda $46
 sec
 sbc #9
 sta $48
HUDScrollReady:
 ldx #0
HUDCopy:
 lda.l ScreenData,x
 sta.l $7e3000,x
 inx
 inx
 cpx #2048
 beq P5Long_ui_4
 jmp HUDCopy
P5Long_ui_4:
 lda #2*(4*32+11)
 sta $1ca0
 sep #$20
 .ACCU 8
 stz $1ca2
 rep #$20
 .ACCU 16
 lda $4a
 bne P5Long_ui_5
 jmp HUDFolderDone16
P5Long_ui_5:
 asl a
 asl a
 asl a
 asl a
 tax
 sep #$20
 .ACCU 8
 ldy #8
HUDFolder:
 lda $0604,x
 jsr PutChar
 inx
 dey
 beq P5Long_ui_6
 jmp HUDFolder
P5Long_ui_6:
 jmp HUDFolderDone
HUDFolderDone16:
 sep #$20
 .ACCU 8
HUDFolderDone:
 rep #$20
 .ACCU 16
 lda $48
 sta $76
 lda #2*(7*32+2)
 sta $78
 sep #$20
 .ACCU 8
 lda #10
 sta $7d
HUDRows:
 rep #$20
 .ACCU 16
 lda $76
 cmp $44
 bcc P5Long_ui_7
 jmp HUDRowsDone16
P5Long_ui_7:
 lda $78
 sta $1ca0
 lda $76
 cmp $46
 sep #$20
 .ACCU 8
 beq P5Long_ui_8
 jmp HUDUnselected
P5Long_ui_8:
 lda #12
 sta $1ca2
 lda #$3e
 jmp HUDMarker
HUDUnselected:
 stz $1ca2
 lda #$20
HUDMarker:
 pha
 ; Only the selected row needs a background fill; the static map clears others.
 lda $1ca2
 cmp #12
 beq P5Long_ui_21
 jmp HUDMarkerReady
P5Long_ui_21:
 rep #$20
 .ACCU 16
 lda $1ca0
 sta $1cad
 sep #$20
 .ACCU 8
 ldy #21
HUDRowFill:
 lda #0
 jsr HUDTile
 dey
 beq P5Long_ui_19
 jmp HUDRowFill
P5Long_ui_19:
 rep #$20
 .ACCU 16
 lda $1cad
 sta $1ca0
 sep #$20
 .ACCU 8
HUDMarkerReady:
 pla
 jsr PutChar
 rep #$20
 .ACCU 16
 lda $76
 asl a
 asl a
 asl a
 asl a
 asl a
 tax
 sep #$20
 .ACCU 8
 lda $080b,x
 and #$10
 bne P5Long_ui_9
 jmp HUDFileIcon
P5Long_ui_9:
 lda #104
 jmp HUDIcon
HUDFileIcon:
 lda #105
HUDIcon:
 jsr HUDTile
 lda #$20
 jsr PutChar
 jsr HUDListTitle
HUDNext:
 rep #$20
 .ACCU 16
 inc $76
 lda $78
 clc
 adc #64
 sta $78
 sep #$20
 .ACCU 8
 dec $7d
 beq P5Long_ui_13
 jmp HUDRows
P5Long_ui_13:
 jmp HUDRowsDone
HUDRowsDone16:
 sep #$20
 .ACCU 8
HUDRowsDone:
 stz $1ca2
 lda $8f
 bne P5Long_ui_14
 jmp HUDStatusDone
P5Long_ui_14:
 rep #$20
 .ACCU 16
 lda #2*(18*32+2)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 lda #106
 jsr HUDTile
 jsr HUDPlayingTitle
 rep #$20
 .ACCU 16
 lda #2*(18*32+23)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #16
 sta $1ca2
 ldx #0
HUDPlayLabel:
 lda.w HUDPlayText,x
 jsr PutChar
 inx
 cpx #5
 beq P5Long_ui_20
 jmp HUDPlayLabel
P5Long_ui_20:
HUDStatusDone:
 rep #$20
 .ACCU 16
 lda #2*(4*32+22)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 rep #$20
 .ACCU 16
 lda $44
 bne P5Long_ui_22
 jmp HUDCountReady
P5Long_ui_22:
 lda $46
 inc a
HUDCountReady:
 jsr HUDDecimal
 sep #$20
 .ACCU 8
 lda #$2f
 jsr PutChar
 rep #$20
 .ACCU 16
 lda $44
 jsr HUDDecimal
 rep #$20
 .ACCU 16
 lda #2*(20*32+11)
 sta $1ca0
 sep #$20
 .ACCU 8
 stz $1ca2
 lda $1c40
 rep #$20
 .ACCU 16
 and #255
 jsr HUDDecimal
 sep #$20
 .ACCU 8
 lda #$25
 jsr PutChar
 rep #$20
 .ACCU 16
 lda #2*(22*32+11)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #16
 sta $1ca2
 ldx #0
HUDAudioMode:
 lda $1c81
 bne P5Long_ui_23
 jmp HUDAudioStereo
P5Long_ui_23:
 lda.w HUDMonoText,x
 jmp HUDAudioChar
HUDAudioStereo:
 lda $8f
 bne P5Long_ui_30
 jmp HUDAudioStereoAvailable
P5Long_ui_30:
 lda $1c3b
 and #$80
 beq P5Long_ui_31
 jmp HUDAudioStereoAvailable
P5Long_ui_31:
 lda.w HUDStereoOnlyText,x
 jmp HUDAudioChar
HUDAudioStereoAvailable:
 lda.w HUDStereoText,x
HUDAudioChar:
 jsr PutChar
 inx
 cpx #7
 beq P5Long_ui_24
 jmp HUDAudioMode
P5Long_ui_24:
 rep #$20
 .ACCU 16
 lda #2*(21*32+11)
 sta $1ca0
 lda $1c42
 jsr HUDDecimal
 sep #$20
 .ACCU 8
 lda #$25
 jsr PutChar
 jsr HUDSliders
 jsr HUDMeters
 jsr V13Draw
 ; Upload the buffered map during blanking, avoiding a forced blank each frame.
 jsr WaitFrame
 lda #$80
 sta $2115
 ldx #$2000
 stx $2116
 lda #1
 sta $4300
 lda #$18
 sta $4301
 ldx #$3000
 stx $4302
 lda #$7e
 sta $4304
 ldx #2048
 stx $4305
 lda #1
 sta $420b
 lda #$0f
 sta $2100
 stz $1caa
 clc
 rts
HUDDecimal:
 .ACCU 16
 sta $1ca4
 lda #0
 sta $1ca6
HUDHundreds:
 lda $1ca4
 cmp #100
 bcs P5Long_ui_17
 jmp HUDHundredsDone
P5Long_ui_17:
 sec
 sbc #100
 sta $1ca4
 inc $1ca6
 jmp HUDHundreds
HUDHundredsDone:
 lda $1ca6
 sep #$20
 .ACCU 8
 clc
 adc #$30
 jsr PutChar
 rep #$20
 .ACCU 16
 stz $1ca6
HUDTens:
 lda $1ca4
 cmp #10
 bcs P5Long_ui_18
 jmp HUDTensDone
P5Long_ui_18:
 sec
 sbc #10
 sta $1ca4
 inc $1ca6
 jmp HUDTens
HUDTensDone:
 sep #$20
 .ACCU 8
 lda $1ca6
 clc
 adc #$30
 jsr PutChar
 lda $1ca4
 clc
 adc #$30
 jsr PutChar
 rep #$20
 .ACCU 16
 rts
.include "hud_meters.asm"
HUDTile:
 phx
 ldx $1ca0
 sta.l $7e3000,x
 lda $1ca2
 sta.l $7e3001,x
 inx
 inx
 stx $1ca0
 plx
 rts
DrawError:
 stz $1cd0
 stz $1caa
 ; Snapshot output ports before drawing; song status alone is not a handshake.
 ldx #0
UIAPUSnapshot:
 lda.l $002140,x
 sta $1820,x
 inx
 cpx #4
 beq P5Long_ui_25
 jmp UIAPUSnapshot
P5Long_ui_25:
 lda #$8f
 sta $2100
 rep #$20
 .ACCU 16
 ldx #$2000
 stx $2116
 ldx #0
UIErrorMap:
 lda.l ErrorScreen,x
 sta $2118
 inx
 inx
 cpx #2048
 beq P5Long_ui_26
 jmp UIErrorMap
P5Long_ui_26:
 sep #$20
 .ACCU 8
 lda $4d
 cmp #$67
 beq P5Long_ui_10
 jmp UIErrorCommon
P5Long_ui_10:
 ldx #$20a3
 stx $2116
 ldx #0
UIUnsupportedText:
 lda.w UnsupportedSPCText,x
 bne P5Long_ui_11
 jmp UIErrorCommon
P5Long_ui_11:
 jsr PutChar
 inx
 jmp UIUnsupportedText
UIErrorCommon:
 ldx #$20e6
 stx $2116
 ldx #0
UIErrorText:
 lda.w ErrorText,x
 bne LongBranch_ui_17
 jmp UIErrorHex
LongBranch_ui_17:
 jsr PutChar
 inx
 jmp UIErrorText
UIErrorHex:
 lda $4d
 jsr PutHex
 ldx #$2147
 stx $2116
 ldx #0
UIAPUPorts:
 lda $1820,x
 jsr PutHex
 inx
 cpx #4
 beq P5Long_ui_27
 jmp UIAPUPorts
P5Long_ui_27:
 ldx #$218d
 stx $2116
 lda $1800
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1825
 jsr PutHex
 ldx #$21a7
 stx $2116
 lda $23
 jsr PutHex
 lda $22
 jsr PutHex
 lda $21
 jsr PutHex
 lda $20
 jsr PutHex
 ldx #$212f
 stx $2116
 lda $1844
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1845
 jsr PutHex
 ldx #$21cf
 stx $2116
 lda $1840
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1841
 jsr PutHex
 ldx #$21ed
 stx $2116
 ldx #1
UICommandArgument:
 lda $1800,x
 jsr PutHex
 inx
 cpx #5
 beq P5Long_ui_28
 jmp UICommandArgument
P5Long_ui_28:
 lda #$20
 jsr PutChar
 lda $1805
 jsr PutHex
 ldx #$220f
 stx $2116
 lda $1cec
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1cef
 jsr PutHex
 lda $1cee
 jsr PutHex
 lda #$0f
 sta $2100
 rts
ErrorText:
 .db "ERROR ",0
UnsupportedSPCText:
 .db "UNSUPPORTED SPC / LAYOUT",0
PutChar:
UICharUpper:
 cmp #$20
 bcs LongBranch_ui_20
 jmp UICharUnknown
LongBranch_ui_20:
 cmp #$7f
 bcs LongBranch_ui_21
 jmp UICharValid
LongBranch_ui_21:
UICharUnknown:
 lda #$3f
UICharValid:
 sec
 sbc #$20
 pha
 lda $1caa
 bne P5Long_ui_29
 jmp UICharVRAM
P5Long_ui_29:
 pla
 jmp HUDTile
UICharVRAM:
 pla
 sta $2118
 stz $2119
 rts
PutHex:
 sta $00
 lsr a
 lsr a
 lsr a
 lsr a
 jsr PutNibble
 lda $00
 and #$0f
PutNibble:
 clc
 adc #$30
 cmp #$3a
 bcc +
 clc
 adc #7
+:
 jmp PutChar
WaitFrame:
UIWaitEnd:
 lda $4212
 bpl LongBranch_ui_22
 jmp UIWaitEnd
LongBranch_ui_22:
UIWaitStart:
 lda $4212
 bmi LongBranch_ui_23
 jmp UIWaitStart
LongBranch_ui_23:
 rts
ReadJoy:
 jsr V13Joy
 rts

PaletteData:
 .incbin "palette.bin"
