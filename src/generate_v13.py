from pathlib import Path
import struct
B=Path(__file__).resolve().parent
code=[];strings=[]
def emit(s):code.append(s)
def pos(r,c=2,a=0):emit(f' rep #$20\n .ACCU 16\n lda #{2*(r*32+c)}\n sta $1ca0\n sep #$20\n .ACCU 8\n lda #{a*4}\n sta $1ca2')
def text(r,c,s,a=0):
 pos(r,c,a);n=len(strings);strings.append(f'V13String{n}:\n .db "{s}",0');emit(f' ldx #V13String{n}\n jsr V13Text')
emit('''; 1.0 state: 1D80 clock,82 repeat deadline,84 repeat mask,86 old joy,
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
 bne V13InitTags
 rep #$20
 .ACCU 16
 ldx #0
V13InitInput:
 stz $1688,x
 inx
 inx
 cpx #120
 bne V13InitInput
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
 beq V13NMIDone
 rep #$20
 .ACCU 16
 lda.l $7e1d96
 inc a
 cmp.l $7e1da8
 bcc V13NMIFrame
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
 bne V13RepeatClear
 lda $70
 and #$0c00
 cmp #$0c00
 beq V13RepeatClear
 cmp #0
 beq V13RepeatClear
 cmp $1d84
 beq V13RepeatHeld
 sta $1d84
 lda $1d80
 clc
 adc #40
 sta $1d82
 bra V13InputDone
V13RepeatHeld:
 lda $1d80
 sec
 sbc $1d82
 bmi V13InputDone
 lda $72
 ora $1d84
 sta $72
 lda $1d80
 clc
 adc #6
 sta $1d82
 bra V13InputDone
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
 bcc V13ClearSkipInput
+:
 stz $1600,x
V13ClearSkipInput:
 inx
 inx
 cpx #512
 bne V13ClearCache
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
 bne V13SaveHeader
 ldx #0
V13SeedDSP:
 lda.l $7f8100,x
 sta $1600,x
 inx
 cpx #128
 bne V13SeedDSP
 ; Text ID666 has an eleven-byte date and five-byte fade; binary has
 ; a four-byte date, three-byte playtime, four-byte fade and artist at B0.
 ; The format has no explicit text/binary marker. Prefer text for empty
 ; tags, use date separators and binary day/artist evidence when present.
 stz $1d9a
 lda.l $7e50a0
 cmp #$2f
 beq V13TextTags
 cmp #$2e
 beq V13TextTags
 lda.l $7e509e
 beq +
 cmp #32
 bcc V13TagsReady
+:
 lda.l $7e50d2
 bne V13TextTags
 lda.l $7e50b0
 beq V13TextTags
 cmp #$30
 bcc +
 cmp #$3a
 bcc V13TextTags
+:
 lda.l $7e50b0
 cmp #$20
 bcs V13TagsReady
 lda.l $7e50a9
 cmp #$30
 bcc V13TagsReady
 cmp #$3a
 bcs V13TagsReady
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
 beq V13PollDone
 lda $1d89
 beq +
 lda $1d88
 bne +
 jsr ControlMeter
 bcs V13PollFailed
+:
 lda $1d88
 beq V13PollDone
 cmp #6
 bcs V13PollDone
 lda #2
 sta $1d9e
V13PollNext:
 lda $1d8b
 sta $1c68
 lda #$69
 jsr ControlCommand
 bcs V13PollFailed
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
 bne V13PollNext
V13PollDone:
 clc
V13PollFailed:
 rts

V13Draw:
 jsr V13Time
 lda $1d88
 bne V13Panel
 lda $1d89
 beq V13DrawDone
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
 bne V13PanelCopy
 sep #$20
 .ACCU 8
 jsr V13Title
 lda $1d88
 beq V13Visual
 cmp #1
 beq V13Global
 cmp #6
 beq V13TagsMusic
 cmp #7
 beq V13TagsFile
 jsr V13Voices
 bra V13Footer
V13Visual:
 lda $1d89
 cmp #1
 bne +
 jsr V13VoiceBars
 bra V13Footer
+:
 jsr V13Scopes
 bra V13Footer
V13Global:
 jsr V13GlobalData
 bra V13Footer
V13TagsMusic:
 jsr V13MusicTags
 bra V13Footer
V13TagsFile:
 jsr V13FileTags
V13Footer:
''')
text(17,2,'LIVE DSP / ASYNC',2)
emit(' lda $1d88\n cmp #5\n bcs V13FootSnapshot\n lda $8f\n bne V13FootNumber')
text(17,2,'IDLE / NO LIVE AUDIO',2)
emit(' bra V13FootNumber\nV13FootSnapshot:')
text(17,2,'SPC FILE / SNAPSHOT',2)
emit('V13FootNumber:')
pos(17,26,1);emit(' lda $1d88\n clc\n adc #$30\n jsr PutChar\n lda #$2f\n jsr PutChar\n lda #$37\n jsr PutChar\nV13DrawDone:\n rts')
emit('''V13Text:
 lda.w $0000,x
 beq +
 jsr PutChar
 inx
 bra V13Text
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
 bcc V13DigitReady
 sec
 sbc.w V13Places,x
 sta $1da0
 inc $1da2
 bra V13DigitSubtract
V13DigitReady:
 sep #$20
 .ACCU 8
 lda $1da2
 clc
 adc #$30
 jsr PutChar
 inx
 inx
 cpx #10
 bne V13DigitNext
 plx
 rts
V13Places:
 .dw 10000,1000,100,10,1
''')
emit('''; The NMI producer counts each rising button edge. The main loop keeps
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
 bne V13JoyBit
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
 bcc V13JoyNoEdge
 lda $1698
 sta $16ba,x
 inc $169a,x
V13JoyNoEdge:
 inx
 cpx #16
 bne V13JoyEdges
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
 beq V13JoyUnchanged
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
 bne V13JoyConsume
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
 bne V13DriverTimerDone
 rep #$20
 .ACCU 16
 lda $1c00
 cmp #$064f
 bne V13TryDKC23
 sep #$20
 .ACCU 8
 lda #$ec
 bra V13TimerFound
V13TryDKC23:
 .ACCU 16
 cmp #$0792
 bne V13DriverTimerDone16
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
 bne V13DriverTimerReject
 iny
 lda [$94],y
 cmp $1dad
 bne V13DriverTimerReject
 ldx #0
V13CheckNativeLoop:
 iny
 lda [$94],y
 cmp.w V13NativeLoop,x
 bne V13DriverTimerReject
 inx
 cpx #8
 bne V13CheckNativeLoop
 rep #$20
 .ACCU 16
 lda $1c3b
 and #$0080
 beq V13LegacyTimerCode
 lda $1c04
 clc
 adc #50
 bra V13TimerCodePointer
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
 bne V13DriverTimerReject
 iny
 cpy #7
 bne V13CheckTimerCode
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
''')
emit('V13Time:')
text(2,12,'TIME:',2)
emit(' rep #$20\n .ACCU 16\n lda $1d94\n jsr V13Decimal5\n sep #$20\n .ACCU 8\n lda #$53\n jsr PutChar\n rts\nV13Title:')
pos(5,2,3)
emit(''' lda $1d88
 cmp #6
 bcs V13TitleDone
 lda.l $7e5023
 cmp #$1a
 bne V13TitleFallback
 lda.l $7e502e
 beq V13TitleFallback
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
 beq V13TitleDone
 jsr PutChar
 inx
 cpx #28
 bne V13TitleFile
V13TitleDone:
 rts
''')
emit('V13GlobalData:')
text(4,2,'DSP STATUS / MIXER',1)
text(6,2,'MVOL L/R:',0);emit(' lda $160c\n jsr PutHex\n lda #$2f\n jsr PutChar\n lda $161c\n jsr PutHex')
text(7,2,'EVOL L/R:',0);emit(' lda $162c\n jsr PutHex\n lda #$2f\n jsr PutChar\n lda $163c\n jsr PutHex')
text(8,2,'ECHO FB:',0);emit(' lda $160d\n jsr PutHex')
text(8,17,'DELAY:',0);emit(' lda $167d\n and #15\n jsr PutHex')
text(9,2,'DIR:',0);emit(' lda $165d\n jsr PutHex\n lda #$30\n jsr PutChar\n jsr PutChar')
text(9,17,'ESA:',0);emit(' lda $166d\n jsr PutHex\n lda #$30\n jsr PutChar\n jsr PutChar')
text(10,2,'FLG:',0);emit(' lda $166c\n jsr PutHex')
text(10,13,'NOISE RATE:',0);emit(' lda $166c\n and #31\n jsr PutHex')
text(11,2,'KON:',0);emit(' lda $164c\n jsr PutHex')
text(11,13,'KOFF:',0);emit(' lda $165c\n jsr PutHex')
text(12,2,'ENDX:',0);emit(' lda $167c\n jsr PutHex')
text(13,2,'FIR:',1)
for i in range(8):
 pos(14 if i<4 else 15,3+(i%4)*6);emit(f' lda ${0x160f+i*16:04x}\n jsr PutHex')
text(16,2,'ELAPSED:',2);emit(' rep #$20\n .ACCU 16\n lda $1d94\n jsr V13Decimal5\n lda #$53\n jsr PutChar\n rts')
emit('V13Voices:')
text(4,2,'VOICE DATA / REAL-TIME',1)
emit(' lda $1d88\n cmp #2\n bne V13HeaderEnvelope')
text(6,2,'# SRC  VL VR PITCH ENV OUT',0)
emit(' bra V13VoiceBegin\nV13HeaderEnvelope:\n cmp #3\n bne V13HeaderFlags')
text(6,2,'# SRC  ADSR1 ADSR2 GAIN ENV',0)
emit(' bra V13VoiceBegin\nV13HeaderFlags:\n cmp #4\n bne V13HeaderDIR')
text(6,2,'# SRC  ON N E P  ENDX',0)
emit(' bra V13VoiceBegin\nV13HeaderDIR:')
text(6,2,'# SRC  START LOOP  READ PTR',0)
text(16,2,'READ PTR NOT EXPOSED BY DSP',2)
emit('''V13VoiceBegin:
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
 jsr PutChar
 lda #0
 sta $1ca2
 lda #$20
 jsr PutChar
 lda $1604,x
 jsr PutHex
 lda #$20
 jsr PutChar
 jsr PutChar
 lda $1d88
 cmp #2
 beq V13VoiceMix
 cmp #3
 beq V13VoiceEnvelope
 cmp #4
 beq V13VoiceFlags
 jsr V13Directory
 bra V13VoiceEnd
V13VoiceMix:
 lda $1600,x
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1601,x
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1603,x
 and #$3f
 jsr PutHex
 lda $1602,x
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1608,x
 jsr PutHex
 lda #$20
 jsr PutChar
 lda $1609,x
 jsr PutHex
 bra V13VoiceEnd
V13VoiceEnvelope:
 lda $1605,x
 jsr PutHex
 lda #$20
 jsr PutChar
 jsr PutChar
 jsr PutChar
 lda $1606,x
 jsr PutHex
 lda #$20
 jsr PutChar
 jsr PutChar
 jsr PutChar
 lda $1607,x
 jsr PutHex
 lda #$20
 jsr PutChar
 jsr PutChar
 jsr PutChar
 lda $1608,x
 jsr PutHex
 bra V13VoiceEnd
V13VoiceFlags:
 lda $1608,x
 beq V13VoiceInactive
 lda #$2b
 bra V13VoiceActivePut
V13VoiceInactive:
 lda #$2d
V13VoiceActivePut:
 jsr PutChar
 lda #$20
 jsr PutChar
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
 jsr PutChar
 lda $167c
 jsr V13FlagChar
V13VoiceEnd:
 inc $1d8c
 lda $1d8c
 cmp #8
 bne V13VoiceRow
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
 jsr PutChar
 lda #$20
 jmp PutChar
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
 jsr PutChar
 ldy #3
 lda [$94],y
 jsr PutHex
 dey
 lda [$94],y
 jsr PutHex
 lda #$20
 jsr PutChar
 lda #$2d
 jsr PutChar
 jsr PutChar
 plx
 rts
''')
emit('V13VoiceBars:')
text(4,2,'EIGHT VOICES / AUDIO LEDS',1)
text(6,2,'#  20 SEGMENTS PER VOICE',2)
emit(''' stz $1d8c
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
 jsr PutChar
 lda #$20
 jsr PutChar
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
 bcc V13BarEmpty
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
 bra V13BarPut
V13BarEmpty:
 lda #110
V13BarPut:
 jsr HUDTile
 inc $1d8d
 lda $1d8d
 cmp #20
 bne V13BarCell
 inc $1d8c
 lda $1d8c
 cmp #8
 bne V13BarsRow
''')
text(15,2,'VOICE LEVEL: OUTX X VOLUME',2)
text(16,2,'20 LEDS / PEAK HOLD',2);emit(' rts\nV13BarThresholds:\n .db 1,2,3,4,5,6,8,10,12,15,18,22,27,33,40,48,58,70,84,100')
emit('V13Scopes:')
text(4,2,'EIGHT VOICES / OSCILLOSCOPE',1)
text(6,2,'#  -       OUTX       +',2)
emit(''' stz $1d8c
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
 jsr PutChar
 lda #$20
 jsr PutChar
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
 bcc V13TraceLow
 cmp #160
 bcs V13TraceHigh
 sec
 sbc #96
 lsr a
 lsr a
 lsr a
 bra V13TraceLevel
V13TraceLow:
 lda #0
 bra V13TraceLevel
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
 bne V13ScopeCell
 inc $1d8c
 lda $1d8c
 cmp #8
 bne V13ScopeRow
''')
text(15,2,'SIGNED OUTX / 4X VIEW GAIN',2)
text(16,2,'LOW-RATE / NOT FULL PCM',2);emit(' rts')
# Tag helpers split 32-byte fields into 28+4 so nothing is silently truncated.
emit('''V13TagField:
 ldy #0
V13TagNext:
 lda $1dac
 bne V13TagBlank
 lda.l $7e5000,x
 bne +
 inc $1dac
 bra V13TagBlank
+:
 cmp #$20
 bcs V13TagPut
V13TagBlank:
 lda #$20
V13TagPut:
 jsr PutChar
 inx
 iny
 cpy $1da6
 bne V13TagNext
 rts
''')
emit('V13MusicTags:')
text(4,2,'INFO AND MEDIA DATA / MUSIC',1)
emit(' lda.l $7e5023\n cmp #$1a\n beq V13MusicHasTags')
text(10,2,'NO ID666 TAGS IN THIS SPC',2);emit(' rts\nV13MusicHasTags:')
for row,label,offset in [(5,'TITLE',0x2e),(8,'GAME',0x4e),(11,'ARTIST',0xb0),(14,'COMMENT',0x7e)]:
 text(row,2,label,1)
 pos(row+1);emit(' rep #$20\n .ACCU 16\n lda #28\n sta $1da6\n sep #$20\n .ACCU 8\n stz $1dac')
 emit(f' ldx #{offset}')
 if label=='ARTIST':emit(' lda $1d9a\n beq +\n inx\n+:')
 emit(' jsr V13TagField');pos(row+2);emit(' rep #$20\n .ACCU 16\n lda #4\n sta $1da6\n sep #$20\n .ACCU 8\n jsr V13TagField')
emit(' rts\nV13FileTags:')
text(4,2,'INFO AND MEDIA DATA / FILE',1)
emit(' lda.l $7e5023\n cmp #$1a\n beq V13FileHasTags')
text(10,2,'NO ID666 TAGS IN THIS SPC',2);emit(' rts\nV13FileHasTags:')
text(6,2,'DUMPER:',1);pos(7);emit(' rep #$20\n .ACCU 16\n lda #16\n sta $1da6\n sep #$20\n .ACCU 8\n stz $1dac\n ldx #$6e\n jsr V13TagField')
text(9,2,'DUMP DATE:',1)
emit(' lda $1d9a\n beq V13DateBinary')
pos(10);emit(' rep #$20\n .ACCU 16\n lda #11\n sta $1da6\n sep #$20\n .ACCU 8\n stz $1dac\n ldx #$9e\n jsr V13TagField\n bra V13LengthTag\nV13DateBinary:')
pos(10);emit(' lda.l $7e50a1\n jsr PutHex\n lda.l $7e50a0\n jsr PutHex\n lda.l $7e509f\n jsr PutHex\n lda.l $7e509e\n jsr PutHex')
text(10,12,'RAW DATE (HEX)',2)
emit('V13LengthTag:')
text(12,2,'PLAYTIME:',1);emit(' ldx #$a9\n ldy #3\n jsr V13TagNumber\n rep #$20\n .ACCU 16\n lda $1da4\n jsr V13Decimal5\n sep #$20\n .ACCU 8\n jsr V13CapMark\n lda #$53\n jsr PutChar')
text(13,2,'FADE:',1);emit(' ldx #$ac\n ldy #5\n lda $1d9a\n bne +\n ldy #4\n+:\n jsr V13TagNumber\n rep #$20\n .ACCU 16\n lda $1da4\n jsr V13Decimal5\n sep #$20\n .ACCU 8\n jsr V13CapMark\n lda #$20\n jsr PutChar\n lda #$4d\n jsr PutChar\n lda #$53\n jsr PutChar')
text(15,2,'FORMAT:',1);emit(' lda $1d9a\n beq V13TagBinaryLabel')
text(15,10,'ID666 TEXT',0);emit(' bra V13TagFileEnd\nV13TagBinaryLabel:')
text(15,10,'ID666 BINARY',0)
emit('V13TagFileEnd:');text(16,2,'LENGTH/FADE: TAGS ONLY',2);emit(' rts')
emit('''; Text decimal or little-endian binary. Cap at 65535; append + when
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
 bne V13NumberText
 lda.l $7e5000,x
 sta $1da4
 lda.l $7e5001,x
 sta $1da5
 lda.l $7e5002,x
 bne V13NumberCap
 cpy #4
 bne V13NumberDone
 lda.l $7e5003,x
 bne V13NumberCap
 bra V13NumberDone
V13NumberText:
 lda.l $7e5000,x
 cmp #$20
 bne +
 inx
 dey
 beq V13NumberDone
 bra V13NumberText
+:
 cmp #$30
 bcc V13NumberDone
 cmp #$3a
 bcs V13NumberDone
 sec
 sbc #$30
 rep #$20
 .ACCU 16
 and #255
 sta $1da6
 lda $1da4
 cmp #6553
 bcc +
 bne V13NumberCap16
 lda $1da6
 cmp #6
 bcs V13NumberCap16
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
 bne V13NumberText
 bra V13NumberDone
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
 jsr PutChar
+:
 rts
''')
emit('\n'.join(strings))
source='\n'.join(code)+'\n'
source=source.replace('jsr PutChar','jsr V13Char').replace('jmp PutChar','jmp V13Char')
source=source.replace(' jsr V13Decimal5\n',' jsr V13Decimal5\n sep #$20\n .ACCU 8\n')
source+='''\n; Character helper preserves A, including when writing several blanks.
V13Char:
 .ACCU 8
 pha
 jsr PutChar
 pla
 rts
'''
(B/'v13.asm').write_text(source)
# Plain full-width panel, preserving the established header/status/controls.
data=bytearray(2048)
for r in range(4,18):
 for c in range(32):struct.pack_into('<H',data,2*(r*32+c),107)
for r in range(5,17):
 struct.pack_into('<H',data,2*(r*32+1),101|(1<<10))
 struct.pack_into('<H',data,2*(r*32+30),101|(1<<10)|0x4000)
for r in (4,17):
 for c in range(2,30):struct.pack_into('<H',data,2*(r*32+c),100|(1<<10)|(0x8000 if r==17 else 0))
for r,c,tile in ((4,1,96),(4,30,97),(17,1,98),(17,30,99)):
 struct.pack_into('<H',data,2*(r*32+c),tile|(1<<10))
(B/'v13_panel.bin').write_bytes(data)
print('1.0 views generated')
