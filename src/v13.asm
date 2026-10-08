; v1.3.E state: 1D80 clock,82 repeat deadline,84 repeat mask,86 old joy,
; 88 info page,89 view,8A trace head,8B DSP pair scan. Cache 1600..167F;
; eight signed OUTX rings 1700..17FF. ID666 saved at 7E5000..50FF.
; DSP fields are asynchronous register observations, never emulator internals.
V13Init:
 rep #$20
 .ACCU 16
 lda #60
 sta $1da8
 sep #$20
 .ACCU 8
 lda $213f
 and #$10
 beq +
 lda #50
 sta $1da8
+:
 jsr V13ClearAudio
 ldx #0
 lda #0
V13InitTags:
 sta.l $7e5000,x
 sta $1400,x
 inx
 cpx #256
 beq P5Long_v13_0
 jmp V13InitTags
P5Long_v13_0:
 rep #$20
 .ACCU 16
 ldx #0
V13InitInput:
 stz $1688,x
 inx
 inx
 cpx #120
 beq P5Long_v13_1
 jmp V13InitInput
P5Long_v13_1:
 sep #$20
 .ACCU 8
 lda #$80
 sta $4200
 rts
FrameNMI:
 php
 rep #$30
 .ACCU 16
 pha
 phx
 phy
 phb
 sep #$20
 .ACCU 8
 lda #0
 pha
 plb
 lda $16ce
 bne +
 jsr V13SampleJoy
+:
 rep #$20
 .ACCU 16
 lda.l $7e1d80
 inc a
 sta.l $7e1d80
 sep #$20
 .ACCU 8
 lda.l $004210
 lda.l $7e008f
 bne P5Long_v13_2
 jmp V13NMIDone
P5Long_v13_2:
 rep #$20
 .ACCU 16
 lda.l $7e1d96
 inc a
 cmp.l $7e1da8
 bcs P5Long_v13_3
 jmp V13NMIFrame
P5Long_v13_3:
 lda.l $7e1d94
 inc a
 sta.l $7e1d94
 lda #0
V13NMIFrame:
 sta.l $7e1d96
V13NMIDone:
 plb
 rep #$20
 .ACCU 16
 ply
 plx
 pla
 plp
 rti

V13Input:
 rep #$20
 .ACCU 16
 ; Accept a chord in either order: modifier first or direction first.
 lda $72
 bit #$4000
 beq +
 lda $70
 and #$0300
 ora $72
 sta $72
+:
 lda $72
 bit #$0040
 beq +
 lda $70
 and #$0c00
 ora $72
 sta $72
+:
 lda $72
 bit #$2000
 beq +
 lda $70
 and #$90b0
 ora $72
 sta $72
+:
 ; Browser repeat: 40 video frames initially (0.67 s NTSC, 0.8 s PAL).
 ; Subsequent steps every six frames. Modifiers cancel browser repeat.
 lda $70
 and #$6040
 beq P5Long_v13_4
 jmp V13RepeatClear
P5Long_v13_4:
 lda $70
 and #$0c00
 cmp #$0c00
 bne P5Long_v13_5
 jmp V13RepeatClear
P5Long_v13_5:
 cmp #0
 bne P5Long_v13_6
 jmp V13RepeatClear
P5Long_v13_6:
 cmp $1d84
 bne P5Long_v13_7
 jmp V13RepeatHeld
P5Long_v13_7:
 sta $1d84
 lda $1d80
 clc
 adc #40
 sta $1d82
 jmp V13InputDone
V13RepeatHeld:
 lda $1d80
 sec
 sbc $1d82
 bpl P5Long_v13_8
 jmp V13InputDone
P5Long_v13_8:
 lda $72
 ora $1d84
 sta $72
 lda $1d80
 clc
 adc #6
 sta $1d82
 jmp V13InputDone
V13RepeatClear:
 stz $1d84
V13InputDone:
 sep #$20
 .ACCU 8
 rts

V13ClearAudio:
 phx
 rep #$20
 .ACCU 16
 ldx #0
V13ClearCache:
 cpx #136
 bcc +
 cpx #256
 bcs P5Long_v13_9
 jmp V13ClearSkipInput
P5Long_v13_9:
+:
 stz $1600,x
V13ClearSkipInput:
 inx
 inx
 cpx #512
 beq P5Long_v13_10
 jmp V13ClearCache
P5Long_v13_10:
 sep #$20
 .ACCU 8
 stz $1d8a
 stz $1d8b
 plx
 rts
V13Song:
 rep #$20
 .ACCU 16
 stz $1d94
 stz $1d96
 sep #$20
 .ACCU 8
 jsr V13ClearAudio
 ldx #0
V13SaveHeader:
 lda.l $7e8000,x
 sta.l $7e5000,x
 inx
 cpx #256
 beq P5Long_v13_11
 jmp V13SaveHeader
P5Long_v13_11:
 ldx #0
V13SeedDSP:
 lda.l $7f8100,x
 sta $1600,x
 inx
 cpx #128
 beq P5Long_v13_12
 jmp V13SeedDSP
P5Long_v13_12:
 ; Text ID666 has an eleven-byte date and five-byte fade; binary has
 ; a four-byte date, three-byte playtime, four-byte fade and artist at B0.
 ; The format has no explicit text/binary marker. Prefer text for empty
 ; tags, use date separators and binary day/artist evidence when present.
 stz $1d9a
 lda.l $7e50a0
 cmp #$2f
 bne P5Long_v13_13
 jmp V13TextTags
P5Long_v13_13:
 cmp #$2e
 bne P5Long_v13_14
 jmp V13TextTags
P5Long_v13_14:
 lda.l $7e509e
 beq +
 cmp #32
 bcs P5Long_v13_15
 jmp V13TagsReady
P5Long_v13_15:
+:
 lda.l $7e50d2
 beq P5Long_v13_16
 jmp V13TextTags
P5Long_v13_16:
 lda.l $7e50b0
 bne P5Long_v13_17
 jmp V13TextTags
P5Long_v13_17:
 cmp #$30
 bcc +
 cmp #$3a
 bcs P5Long_v13_18
 jmp V13TextTags
P5Long_v13_18:
+:
 lda.l $7e50b0
 cmp #$20
 bcc P5Long_v13_19
 jmp V13TagsReady
P5Long_v13_19:
 lda.l $7e50a9
 cmp #$30
 bcs P5Long_v13_20
 jmp V13TagsReady
P5Long_v13_20:
 cmp #$3a
 bcc P5Long_v13_21
 jmp V13TagsReady
P5Long_v13_21:
V13TextTags:
 lda #1
 sta $1d9a
V13TagsReady:
 rts

; Called after command 68, before the magnitude calculation destroys its sign.
V13Trace:
 phx
 lda $1c6d
 sta $1d9c
 lda $1c6e
 sta $1d9d
 txa
 asl a
 asl a
 asl a
 asl a
 tax
 lda $1d9c
 sta $1600,x
 lda $1d9d
 sta $1601,x
 lda $1c6c
 sta $1609,x
 rep #$20
 .ACCU 16
 txa
 asl a
 clc
 adc $1d8a
 and #$00ff
 tax
 sep #$20
 .ACCU 8
 lda $1c6c
 sta $1700,x
 lda $1c48
 cmp #7
 bne +
 inc $1d8a
 lda $1d8a
 and #31
 sta $1d8a
+:
 plx
 rts

; Two DSP register pairs per rendered loop when a live information page is
; visible. Reuses the checked driver's read command; no driver writes added.
V13Poll:
 lda $8f
 bne P5Long_v13_22
 jmp V13PollDone
P5Long_v13_22:
 lda $1d89
 beq +
 lda $1d88
 bne +
 jsr ControlMeter
 bcc P5Long_v13_23
 jmp V13PollFailed
P5Long_v13_23:
+:
 lda $1d88
 bne P5Long_v13_24
 jmp V13PollDone
P5Long_v13_24:
 cmp #6
 bcc P5Long_v13_25
 jmp V13PollDone
P5Long_v13_25:
 lda #2
 sta $1d9e
V13PollNext:
 lda $1d8b
 sta $1c68
 lda #$69
 jsr ControlCommand
 bcc P5Long_v13_26
 jmp V13PollFailed
P5Long_v13_26:
 lda $1d8b
 rep #$20
 .ACCU 16
 and #127
 tax
 sep #$20
 .ACCU 8
 lda $1c6c
 sta $1600,x
 lda $1c6e
 sta $1601,x
 lda $1d8b
 clc
 adc #2
 and #127
 sta $1d8b
 dec $1d9e
 beq P5Long_v13_27
 jmp V13PollNext
P5Long_v13_27:
V13PollDone:
 clc
V13PollFailed:
 rts

V13Draw:
 jsr V13Time
 lda $1d88
 beq P5Long_v13_28
 jmp V13Panel
P5Long_v13_28:
 lda $1d89
 bne P5Long_v13_29
 jmp V13DrawDone
P5Long_v13_29:
V13Panel:
 rep #$20
 .ACCU 16
 ldx #256
V13PanelCopy:
 lda.l V13PanelData,x
 sta.l $7e3000,x
 inx
 inx
 cpx #1152
 beq P5Long_v13_30
 jmp V13PanelCopy
P5Long_v13_30:
 sep #$20
 .ACCU 8
 jsr V13Title
 lda $1d88
 bne P5Long_v13_31
 jmp V13Visual
P5Long_v13_31:
 cmp #1
 bne P5Long_v13_32
 jmp V13Global
P5Long_v13_32:
 cmp #6
 bne P5Long_v13_33
 jmp V13TagsMusic
P5Long_v13_33:
 cmp #7
 bne P5Long_v13_34
 jmp V13TagsFile
P5Long_v13_34:
 jsr V13Voices
 jmp V13Footer
V13Visual:
 lda $1d89
 cmp #1
 bne +
 jsr V13VoiceBars
 jmp V13Footer
+:
 jsr V13Scopes
 jmp V13Footer
V13Global:
 jsr V13GlobalData
 jmp V13Footer
V13TagsMusic:
 jsr V13MusicTags
 jmp V13Footer
V13TagsFile:
 jsr V13FileTags
V13Footer:

 rep #$20
 .ACCU 16
 lda #1092
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String0
 jsr V13Text
 lda $1d88
 cmp #5
 bcc P5Long_v13_35
 jmp V13FootSnapshot
P5Long_v13_35:
 lda $8f
 beq P5Long_v13_36
 jmp V13FootNumber
P5Long_v13_36:
 rep #$20
 .ACCU 16
 lda #1092
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String1
 jsr V13Text
 jmp V13FootNumber
V13FootSnapshot:
 rep #$20
 .ACCU 16
 lda #1092
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String2
 jsr V13Text
V13FootNumber:
 rep #$20
 .ACCU 16
 lda #1140
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 lda $1d88
 clc
 adc #$30
 jsr V13Char
 lda #$2f
 jsr V13Char
 lda #$37
 jsr V13Char
V13DrawDone:
 rts
V13Text:
 lda.w $0000,x
 beq +
 jsr V13Char
 inx
 jmp V13Text
+:
 rts
; Five decimal digits, A16. No wrap or fake time for long metadata values.
V13Decimal5:
 sta $1da0
 phx
 ldx #0
V13DigitNext:
 rep #$20
 .ACCU 16
 stz $1da2
V13DigitSubtract:
 lda $1da0
 cmp.w V13Places,x
 bcs P5Long_v13_37
 jmp V13DigitReady
P5Long_v13_37:
 sec
 sbc.w V13Places,x
 sta $1da0
 inc $1da2
 jmp V13DigitSubtract
V13DigitReady:
 sep #$20
 .ACCU 8
 lda $1da2
 clc
 adc #$30
 jsr V13Char
 inx
 inx
 cpx #10
 beq P5Long_v13_38
 jmp V13DigitNext
P5Long_v13_38:
 plx
 rts
V13Places:
 .dw 10000,1000,100,10,1

; The NMI producer counts each rising button edge. The main loop keeps
; separate consumer counts, so no clear/read race can lose a short press.
; Modifier snapshots preserve chords that are released during an APU wait.
V13SampleJoy:
 .ACCU 8
 lda #1
 sta $4016
 stz $4016
 rep #$20
 .ACCU 16
 stz $1690
 sep #$20
 .ACCU 8
 ldx #16
V13JoyBit:
 lda $4016
 and #1
 lsr a
 rep #$20
 .ACCU 16
 rol $1690
 sep #$20
 .ACCU 8
 dex
 beq P5Long_v13_39
 jmp V13JoyBit
P5Long_v13_39:
 rep #$20
 .ACCU 16
 lda $1696
 eor #$ffff
 and $1690
 sta $1694
 lda $1690
 sta $1696
 sep #$20
 .ACCU 8
 lda $1697
 and #$60
 sta $1698
 lda $1696
 and #$40
 lsr a
 lsr a
 lsr a
 lsr a
 lsr a
 lsr a
 ora $1698
 sta $1698
 ldx #0
V13JoyEdges:
 rep #$20
 .ACCU 16
 lsr $1694
 sep #$20
 .ACCU 8
 bcs P5Long_v13_40
 jmp V13JoyNoEdge
P5Long_v13_40:
 lda $1698
 sta $16ba,x
 inc $169a,x
V13JoyNoEdge:
 inx
 cpx #16
 beq P5Long_v13_41
 jmp V13JoyEdges
P5Long_v13_41:
 rts
V13Joy:
 rep #$20
 .ACCU 16
 lda $6e
 sta $1d86
 lda $1696
 sta $70
 stz $72
 sep #$20
 .ACCU 8
 stz $16ca
 ldx #0
V13JoyConsume:
 lda $169a,x
 cmp $16aa,x
 bne P5Long_v13_42
 jmp V13JoyUnchanged
P5Long_v13_42:
 sta $16aa,x
 lda $16ba,x
 ora $16ca
 sta $16ca
 phx
 rep #$20
 .ACCU 16
 txa
 asl a
 tax
 lda $72
 ora.w V13JoyMasks,x
 sta $72
 sep #$20
 .ACCU 8
 plx
V13JoyUnchanged:
 inx
 cpx #16
 beq P5Long_v13_43
 jmp V13JoyConsume
P5Long_v13_43:
 rep #$20
 .ACCU 16
 lda $16ca
 and #$60
 xba
 ora $70
 sta $70
 lda $16ca
 and #1
 beq +
 lda $70
 ora #$40
 sta $70
+:
 lda $70
 sta $6e
 sep #$20
 .ACCU 8
 rts
V13JoyMasks:
 .dw 1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768

; Rare's native loop writes FA from EC (DKC) or E4 (DKC2/3) before every
; timer tick. Route command 65 to that variable, instead of a transient FA.
; Check both the native ten-byte loop and the installed command instruction.
V13DriverTimer:
 stz $1dad
 lda $1c3b
 and #7
 cmp #1
 beq P5Long_v13_44
 jmp V13DriverTimerDone
P5Long_v13_44:
 rep #$20
 .ACCU 16
 lda $1c00
 cmp #$064f
 beq P5Long_v13_45
 jmp V13TryDKC23
P5Long_v13_45:
 sep #$20
 .ACCU 8
 lda #$ec
 jmp V13TimerFound
V13TryDKC23:
 .ACCU 16
 cmp #$0792
 beq P5Long_v13_46
 jmp V13DriverTimerDone16
P5Long_v13_46:
 sep #$20
 .ACCU 8
 lda #$e4
V13TimerFound:
 sta $1dad
 rep #$20
 .ACCU 16
 lda $1c00
 sec
 sbc #10
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 ldy #0
 lda [$94],y
 cmp #$fa
 beq P5Long_v13_47
 jmp V13DriverTimerReject
P5Long_v13_47:
 iny
 lda [$94],y
 cmp $1dad
 beq P5Long_v13_48
 jmp V13DriverTimerReject
P5Long_v13_48:
 ldx #0
V13CheckNativeLoop:
 iny
 lda [$94],y
 cmp.w V13NativeLoop,x
 beq P5Long_v13_49
 jmp V13DriverTimerReject
P5Long_v13_49:
 inx
 cpx #8
 beq P5Long_v13_50
 jmp V13CheckNativeLoop
P5Long_v13_50:
 rep #$20
 .ACCU 16
 lda $1c3b
 and #$0080
 bne P5Long_v13_51
 jmp V13LegacyTimerCode
P5Long_v13_51:
 lda $1c04
 clc
 adc #50
 jmp V13TimerCodePointer
V13LegacyTimerCode:
 lda $1c04
 clc
 adc #49
V13TimerCodePointer:
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 ldy #0
V13CheckTimerCode:
 lda [$94],y
 cmp.w V13TimerCode,y
 beq P5Long_v13_52
 jmp V13DriverTimerReject
P5Long_v13_52:
 iny
 cpy #7
 beq P5Long_v13_53
 jmp V13CheckTimerCode
P5Long_v13_53:
 ldy #2
 lda $1dad
 sec
 sbc #$65
 sta [$94],y
 rts
V13DriverTimerDone16:
 sep #$20
 .ACCU 8
V13DriverTimerDone:
 rts
V13DriverTimerReject:
 stz $1dad
 rts
V13NativeLoop:
 .db $fa,$8f,$01,$f1,$e4,$fd,$f0,$fc
V13TimerCode:
 .db $60,$88,$95,$5d,$e4,$f6,$c6

V13Time:
 rep #$20
 .ACCU 16
 lda #152
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String3
 jsr V13Text
 rep #$20
 .ACCU 16
 lda $1d94
 jsr V13Decimal5
 sep #$20
 .ACCU 8
 sep #$20
 .ACCU 8
 lda #$53
 jsr V13Char
 rts
V13Title:
 rep #$20
 .ACCU 16
 lda #324
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #12
 sta $1ca2
 lda $1d88
 cmp #6
 bcc P5Long_v13_54
 jmp V13TitleDone
P5Long_v13_54:
 lda.l $7e5023
 cmp #$1a
 beq P5Long_v13_55
 jmp V13TitleFallback
P5Long_v13_55:
 lda.l $7e502e
 bne P5Long_v13_56
 jmp V13TitleFallback
P5Long_v13_56:
 rep #$20
 .ACCU 16
 lda #28
 sta $1da6
 sep #$20
 .ACCU 8
 ldx #$2e
 stz $1dac
 jsr V13TagField
 rts
V13TitleFallback:
 ldx #0
V13TitleFile:
 lda $1400,x
 bne P5Long_v13_57
 jmp V13TitleDone
P5Long_v13_57:
 jsr V13Char
 inx
 cpx #28
 beq P5Long_v13_58
 jmp V13TitleFile
P5Long_v13_58:
V13TitleDone:
 rts

V13GlobalData:
 rep #$20
 .ACCU 16
 lda #260
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String4
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String5
 jsr V13Text
 lda $160c
 jsr PutHex
 lda #$2f
 jsr V13Char
 lda $161c
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #452
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String6
 jsr V13Text
 lda $162c
 jsr PutHex
 lda #$2f
 jsr V13Char
 lda $163c
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #516
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String7
 jsr V13Text
 lda $160d
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #546
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String8
 jsr V13Text
 lda $167d
 and #15
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #580
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String9
 jsr V13Text
 lda $165d
 jsr PutHex
 lda #$30
 jsr V13Char
 jsr V13Char
 rep #$20
 .ACCU 16
 lda #610
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String10
 jsr V13Text
 lda $166d
 jsr PutHex
 lda #$30
 jsr V13Char
 jsr V13Char
 rep #$20
 .ACCU 16
 lda #644
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String11
 jsr V13Text
 lda $166c
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #666
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String12
 jsr V13Text
 lda $166c
 and #31
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #708
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String13
 jsr V13Text
 lda $164c
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #730
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String14
 jsr V13Text
 lda $165c
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #772
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String15
 jsr V13Text
 lda $167c
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #836
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String16
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #902
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $160f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #914
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $161f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #926
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $162f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #938
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $163f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #966
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $164f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #978
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $165f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #990
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $166f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #1002
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda $167f
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #1028
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String17
 jsr V13Text
 rep #$20
 .ACCU 16
 lda $1d94
 jsr V13Decimal5
 sep #$20
 .ACCU 8
 lda #$53
 jsr V13Char
 rts
V13Voices:
 rep #$20
 .ACCU 16
 lda #260
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String18
 jsr V13Text
 lda $1d88
 cmp #2
 beq P5Long_v13_59
 jmp V13HeaderEnvelope
P5Long_v13_59:
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String19
 jsr V13Text
 jmp V13VoiceBegin
V13HeaderEnvelope:
 cmp #3
 beq P5Long_v13_60
 jmp V13HeaderFlags
P5Long_v13_60:
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String20
 jsr V13Text
 jmp V13VoiceBegin
V13HeaderFlags:
 cmp #4
 beq P5Long_v13_61
 jmp V13HeaderDIR
P5Long_v13_61:
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String21
 jsr V13Text
 jmp V13VoiceBegin
V13HeaderDIR:
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String22
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #1028
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String23
 jsr V13Text
V13VoiceBegin:
 stz $1d8c
V13VoiceRow:
 rep #$20
 .ACCU 16
 lda $1d8c
 and #255
 asl a
 asl a
 asl a
 asl a
 tax
 lda $1d8c
 and #255
 asl a
 asl a
 asl a
 asl a
 asl a
 asl a
 clc
 adc #2*(7*32+2)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #16
 sta $1ca2
 lda $1d8c
 clc
 adc #$31
 jsr V13Char
 lda #0
 sta $1ca2
 lda #$20
 jsr V13Char
 lda $1604,x
 jsr PutHex
 lda #$20
 jsr V13Char
 jsr V13Char
 lda $1d88
 cmp #2
 bne P5Long_v13_62
 jmp V13VoiceMix
P5Long_v13_62:
 cmp #3
 bne P5Long_v13_63
 jmp V13VoiceEnvelope
P5Long_v13_63:
 cmp #4
 bne P5Long_v13_64
 jmp V13VoiceFlags
P5Long_v13_64:
 jsr V13Directory
 jmp V13VoiceEnd
V13VoiceMix:
 lda $1600,x
 jsr PutHex
 lda #$20
 jsr V13Char
 lda $1601,x
 jsr PutHex
 lda #$20
 jsr V13Char
 lda $1603,x
 and #$3f
 jsr PutHex
 lda $1602,x
 jsr PutHex
 lda #$20
 jsr V13Char
 lda $1608,x
 jsr PutHex
 lda #$20
 jsr V13Char
 lda $1609,x
 jsr PutHex
 jmp V13VoiceEnd
V13VoiceEnvelope:
 lda $1605,x
 jsr PutHex
 lda #$20
 jsr V13Char
 jsr V13Char
 jsr V13Char
 lda $1606,x
 jsr PutHex
 lda #$20
 jsr V13Char
 jsr V13Char
 jsr V13Char
 lda $1607,x
 jsr PutHex
 lda #$20
 jsr V13Char
 jsr V13Char
 jsr V13Char
 lda $1608,x
 jsr PutHex
 jmp V13VoiceEnd
V13VoiceFlags:
 lda $1608,x
 bne P5Long_v13_65
 jmp V13VoiceInactive
P5Long_v13_65:
 lda #$2b
 jmp V13VoiceActivePut
V13VoiceInactive:
 lda #$2d
V13VoiceActivePut:
 jsr V13Char
 lda #$20
 jsr V13Char
 phx
 lda $1d8c
 rep #$20
 .ACCU 16
 and #7
 tax
 sep #$20
 .ACCU 8
 lda.w V13VoiceBits,x
 sta $1da4
 plx
 lda $163d
 jsr V13FlagChar
 lda $164d
 jsr V13FlagChar
 lda $162d
 jsr V13FlagChar
 lda #$20
 jsr V13Char
 lda $167c
 jsr V13FlagChar
V13VoiceEnd:
 inc $1d8c
 lda $1d8c
 cmp #8
 beq P5Long_v13_66
 jmp V13VoiceRow
P5Long_v13_66:
 rts
V13VoiceBits:
 .db 1,2,4,8,16,32,64,128
V13FlagChar:
 and $1da4
 beq +
 lda #$2b
 bra ++
+:
 lda #$2d
++: 
 jsr V13Char
 lda #$20
 jmp V13Char
V13Directory:
 ; START/LOOP are the source file's directory entries, not live ARAM.
 lda.l $7f815d
 rep #$20
 .ACCU 16
 and #255
 xba
 sta $1da4
 sep #$20
 .ACCU 8
 lda $1604,x
 rep #$20
 .ACCU 16
 and #255
 asl a
 asl a
 clc
 adc $1da4
 sta $1da4
 phx
 clc
 adc #$8100
 sta $94
 lda #$7e
 adc #0
 sta $96
 sep #$20
 .ACCU 8
 ldy #1
 lda [$94],y
 jsr PutHex
 dey
 lda [$94],y
 jsr PutHex
 lda #$20
 jsr V13Char
 ldy #3
 lda [$94],y
 jsr PutHex
 dey
 lda [$94],y
 jsr PutHex
 lda #$20
 jsr V13Char
 lda #$2d
 jsr V13Char
 jsr V13Char
 plx
 rts

V13VoiceBars:
 rep #$20
 .ACCU 16
 lda #260
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String24
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String25
 jsr V13Text
 stz $1d8c
V13BarsRow:
 rep #$20
 .ACCU 16
 lda $1d8c
 and #255
 asl a
 asl a
 asl a
 asl a
 asl a
 asl a
 clc
 adc #2*(7*32+2)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #16
 sta $1ca2
 lda $1d8c
 clc
 adc #$31
 jsr V13Char
 lda #$20
 jsr V13Char
 lda $1d8c
 rep #$20
 .ACCU 16
 and #7
 tax
 sep #$20
 .ACCU 8
 lda $1c50,x
 cmp $1c58,x
 bcs +
 lda $1c58,x
+:
 ; Per-voice hold avoids sparse OUTX samples making the bars disappear.
 cmp $1680,x
 bcs +
 lda $1680,x
 beq +
 dec a
+:
 sta $1680,x
 sta $1da4
 stz $1d8d
V13BarCell:
 lda #28
 sta $1ca2
 ldx $1d8d
 lda $1da4
 cmp.w V13BarThresholds,x
 bcs P5Long_v13_67
 jmp V13BarEmpty
P5Long_v13_67:
 lda #16
 cpx #15
 bcc +
 lda #20
 cpx #18
 bcc +
 lda #24
+:
 sta $1ca2
 lda #109
 jmp V13BarPut
V13BarEmpty:
 lda #110
V13BarPut:
 jsr HUDTile
 inc $1d8d
 lda $1d8d
 cmp #20
 beq P5Long_v13_68
 jmp V13BarCell
P5Long_v13_68:
 inc $1d8c
 lda $1d8c
 cmp #8
 beq P5Long_v13_69
 jmp V13BarsRow
P5Long_v13_69:

 rep #$20
 .ACCU 16
 lda #964
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String26
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #1028
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String27
 jsr V13Text
 rts
V13BarThresholds:
 .db 1,2,3,4,5,6,8,10,12,15,18,22,27,33,40,48,58,70,84,100
V13Scopes:
 rep #$20
 .ACCU 16
 lda #260
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String28
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String29
 jsr V13Text
 stz $1d8c
V13ScopeRow:
 rep #$20
 .ACCU 16
 lda $1d8c
 and #255
 asl a
 asl a
 asl a
 asl a
 asl a
 asl a
 clc
 adc #2*(7*32+2)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #16
 sta $1ca2
 lda $1d8c
 clc
 adc #$31
 jsr V13Char
 lda #$20
 jsr V13Char
 stz $1d8d
V13ScopeCell:
 rep #$20
 .ACCU 16
 lda $1d8a
 and #31
 clc
 adc #8
 adc $1d8d
 and #31
 sta $1da4
 lda $1d8c
 and #7
 asl a
 asl a
 asl a
 asl a
 asl a
 clc
 adc $1da4
 tax
 sep #$20
 .ACCU 8
 lda $1700,x
 eor #$80
 cmp #96
 bcs P5Long_v13_70
 jmp V13TraceLow
P5Long_v13_70:
 cmp #160
 bcc P5Long_v13_71
 jmp V13TraceHigh
P5Long_v13_71:
 sec
 sbc #96
 lsr a
 lsr a
 lsr a
 jmp V13TraceLevel
V13TraceLow:
 lda #0
 jmp V13TraceLevel
V13TraceHigh:
 lda #7
V13TraceLevel:
 eor #7
 clc
 adc #128
 jsr HUDTile
 inc $1d8d
 lda $1d8d
 cmp #24
 beq P5Long_v13_72
 jmp V13ScopeCell
P5Long_v13_72:
 inc $1d8c
 lda $1d8c
 cmp #8
 beq P5Long_v13_73
 jmp V13ScopeRow
P5Long_v13_73:

 rep #$20
 .ACCU 16
 lda #964
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String30
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #1028
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String31
 jsr V13Text
 rts
V13TagField:
 ldy #0
V13TagNext:
 lda $1dac
 beq P5Long_v13_74
 jmp V13TagBlank
P5Long_v13_74:
 lda.l $7e5000,x
 bne +
 inc $1dac
 jmp V13TagBlank
+:
 cmp #$20
 bcc P5Long_v13_75
 jmp V13TagPut
P5Long_v13_75:
V13TagBlank:
 lda #$20
V13TagPut:
 jsr V13Char
 inx
 iny
 cpy $1da6
 beq P5Long_v13_76
 jmp V13TagNext
P5Long_v13_76:
 rts

V13MusicTags:
 rep #$20
 .ACCU 16
 lda #260
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String32
 jsr V13Text
 lda.l $7e5023
 cmp #$1a
 bne P5Long_v13_77
 jmp V13MusicHasTags
P5Long_v13_77:
 rep #$20
 .ACCU 16
 lda #644
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String33
 jsr V13Text
 rts
V13MusicHasTags:
 rep #$20
 .ACCU 16
 lda #324
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String34
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #28
 sta $1da6
 sep #$20
 .ACCU 8
 stz $1dac
 ldx #46
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #452
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #4
 sta $1da6
 sep #$20
 .ACCU 8
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #516
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String35
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #580
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #28
 sta $1da6
 sep #$20
 .ACCU 8
 stz $1dac
 ldx #78
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #644
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #4
 sta $1da6
 sep #$20
 .ACCU 8
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #708
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String36
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #772
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #28
 sta $1da6
 sep #$20
 .ACCU 8
 stz $1dac
 ldx #176
 lda $1d9a
 beq +
 inx
+:
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #836
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #4
 sta $1da6
 sep #$20
 .ACCU 8
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #900
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String37
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #964
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #28
 sta $1da6
 sep #$20
 .ACCU 8
 stz $1dac
 ldx #126
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #1028
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #4
 sta $1da6
 sep #$20
 .ACCU 8
 jsr V13TagField
 rts
V13FileTags:
 rep #$20
 .ACCU 16
 lda #260
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String38
 jsr V13Text
 lda.l $7e5023
 cmp #$1a
 bne P5Long_v13_78
 jmp V13FileHasTags
P5Long_v13_78:
 rep #$20
 .ACCU 16
 lda #644
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String39
 jsr V13Text
 rts
V13FileHasTags:
 rep #$20
 .ACCU 16
 lda #388
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String40
 jsr V13Text
 rep #$20
 .ACCU 16
 lda #452
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #16
 sta $1da6
 sep #$20
 .ACCU 8
 stz $1dac
 ldx #$6e
 jsr V13TagField
 rep #$20
 .ACCU 16
 lda #580
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String41
 jsr V13Text
 lda $1d9a
 bne P5Long_v13_79
 jmp V13DateBinary
P5Long_v13_79:
 rep #$20
 .ACCU 16
 lda #644
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 rep #$20
 .ACCU 16
 lda #11
 sta $1da6
 sep #$20
 .ACCU 8
 stz $1dac
 ldx #$9e
 jsr V13TagField
 jmp V13LengthTag
V13DateBinary:
 rep #$20
 .ACCU 16
 lda #644
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 lda.l $7e50a1
 jsr PutHex
 lda.l $7e50a0
 jsr PutHex
 lda.l $7e509f
 jsr PutHex
 lda.l $7e509e
 jsr PutHex
 rep #$20
 .ACCU 16
 lda #664
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String42
 jsr V13Text
V13LengthTag:
 rep #$20
 .ACCU 16
 lda #772
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String43
 jsr V13Text
 ldx #$a9
 ldy #3
 jsr V13TagNumber
 rep #$20
 .ACCU 16
 lda $1da4
 jsr V13Decimal5
 sep #$20
 .ACCU 8
 sep #$20
 .ACCU 8
 jsr V13CapMark
 lda #$53
 jsr V13Char
 rep #$20
 .ACCU 16
 lda #836
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String44
 jsr V13Text
 ldx #$ac
 ldy #5
 lda $1d9a
 bne +
 ldy #4
+:
 jsr V13TagNumber
 rep #$20
 .ACCU 16
 lda $1da4
 jsr V13Decimal5
 sep #$20
 .ACCU 8
 sep #$20
 .ACCU 8
 jsr V13CapMark
 lda #$20
 jsr V13Char
 lda #$4d
 jsr V13Char
 lda #$53
 jsr V13Char
 rep #$20
 .ACCU 16
 lda #964
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #4
 sta $1ca2
 ldx #V13String45
 jsr V13Text
 lda $1d9a
 bne P5Long_v13_80
 jmp V13TagBinaryLabel
P5Long_v13_80:
 rep #$20
 .ACCU 16
 lda #980
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String46
 jsr V13Text
 jmp V13TagFileEnd
V13TagBinaryLabel:
 rep #$20
 .ACCU 16
 lda #980
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #0
 sta $1ca2
 ldx #V13String47
 jsr V13Text
V13TagFileEnd:
 rep #$20
 .ACCU 16
 lda #1028
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #8
 sta $1ca2
 ldx #V13String48
 jsr V13Text
 rts
; Text decimal or little-endian binary. Cap at 65535; append + when
; the tag exceeds the five-digit display range. Missing/invalid => zero.
V13TagNumber:
 stz $1daa
 rep #$20
 .ACCU 16
 stz $1da4
 stz $1da6
 sep #$20
 .ACCU 8
 lda $1d9a
 beq P5Long_v13_81
 jmp V13NumberText
P5Long_v13_81:
 lda.l $7e5000,x
 sta $1da4
 lda.l $7e5001,x
 sta $1da5
 lda.l $7e5002,x
 beq P5Long_v13_82
 jmp V13NumberCap
P5Long_v13_82:
 cpy #4
 beq P5Long_v13_83
 jmp V13NumberDone
P5Long_v13_83:
 lda.l $7e5003,x
 beq P5Long_v13_84
 jmp V13NumberCap
P5Long_v13_84:
 jmp V13NumberDone
V13NumberText:
 lda.l $7e5000,x
 cmp #$20
 bne +
 inx
 dey
 bne P5Long_v13_85
 jmp V13NumberDone
P5Long_v13_85:
 jmp V13NumberText
+:
 cmp #$30
 bcs P5Long_v13_86
 jmp V13NumberDone
P5Long_v13_86:
 cmp #$3a
 bcc P5Long_v13_87
 jmp V13NumberDone
P5Long_v13_87:
 sec
 sbc #$30
 rep #$20
 .ACCU 16
 and #255
 sta $1da6
 lda $1da4
 cmp #6553
 bcc +
 beq P5Long_v13_88
 jmp V13NumberCap16
P5Long_v13_88:
 lda $1da6
 cmp #6
 bcc P5Long_v13_89
 jmp V13NumberCap16
P5Long_v13_89:
+:
 lda $1da4
 asl a
 sta $1da4
 asl a
 asl a
 clc
 adc $1da4
 adc $1da6
 sta $1da4
 sep #$20
 .ACCU 8
 inx
 dey
 beq P5Long_v13_90
 jmp V13NumberText
P5Long_v13_90:
 jmp V13NumberDone
V13NumberCap16:
 sep #$20
 .ACCU 8
V13NumberCap:
 lda #1
 sta $1daa
 rep #$20
 .ACCU 16
 lda #65535
 sta $1da4
 sep #$20
 .ACCU 8
V13NumberDone:
 rts
V13CapMark:
 lda $1daa
 beq +
 lda #$2b
 jsr V13Char
+:
 rts

V13String0:
 .db "LIVE DSP / ASYNC",0
V13String1:
 .db "IDLE / NO LIVE AUDIO",0
V13String2:
 .db "SPC FILE / SNAPSHOT",0
V13String3:
 .db "TIME:",0
V13String4:
 .db "DSP STATUS / MIXER",0
V13String5:
 .db "MVOL L/R:",0
V13String6:
 .db "EVOL L/R:",0
V13String7:
 .db "ECHO FB:",0
V13String8:
 .db "DELAY:",0
V13String9:
 .db "DIR:",0
V13String10:
 .db "ESA:",0
V13String11:
 .db "FLG:",0
V13String12:
 .db "NOISE RATE:",0
V13String13:
 .db "KON:",0
V13String14:
 .db "KOFF:",0
V13String15:
 .db "ENDX:",0
V13String16:
 .db "FIR:",0
V13String17:
 .db "ELAPSED:",0
V13String18:
 .db "VOICE DATA / REAL-TIME",0
V13String19:
 .db "# SRC  VL VR PITCH ENV OUT",0
V13String20:
 .db "# SRC  ADSR1 ADSR2 GAIN ENV",0
V13String21:
 .db "# SRC  ON N E P  ENDX",0
V13String22:
 .db "# SRC  START LOOP  READ PTR",0
V13String23:
 .db "READ PTR NOT EXPOSED BY DSP",0
V13String24:
 .db "EIGHT VOICES / AUDIO LEDS",0
V13String25:
 .db "#  20 SEGMENTS PER VOICE",0
V13String26:
 .db "VOICE LEVEL: OUTX X VOLUME",0
V13String27:
 .db "20 LEDS / PEAK HOLD",0
V13String28:
 .db "EIGHT VOICES / OSCILLOSCOPE",0
V13String29:
 .db "#  -       OUTX       +",0
V13String30:
 .db "SIGNED OUTX / 4X VIEW GAIN",0
V13String31:
 .db "LOW-RATE / NOT FULL PCM",0
V13String32:
 .db "INFO AND MEDIA DATA / MUSIC",0
V13String33:
 .db "NO ID666 TAGS IN THIS SPC",0
V13String34:
 .db "TITLE",0
V13String35:
 .db "GAME",0
V13String36:
 .db "ARTIST",0
V13String37:
 .db "COMMENT",0
V13String38:
 .db "INFO AND MEDIA DATA / FILE",0
V13String39:
 .db "NO ID666 TAGS IN THIS SPC",0
V13String40:
 .db "DUMPER:",0
V13String41:
 .db "DUMP DATE:",0
V13String42:
 .db "RAW DATE (HEX)",0
V13String43:
 .db "PLAYTIME:",0
V13String44:
 .db "FADE:",0
V13String45:
 .db "FORMAT:",0
V13String46:
 .db "ID666 TEXT",0
V13String47:
 .db "ID666 BINARY",0
V13String48:
 .db "LENGTH/FADE: TAGS ONLY",0

; Character helper preserves A, including when writing several blanks.
V13Char:
 .ACCU 8
 pha
 jsr PutChar
 pla
 rts
