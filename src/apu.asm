; Initial standalone C700 exports only. Reject other layouts before patch/upload.
ValidateC700:
 ldx #0
ValidateSignature:
 lda.l $7e8000,x
 cmp.w Signature,x
 beq LongBranch_apu_0
 jmp UnsupportedC700
LongBranch_apu_0:
 inx
 cpx #25
 beq LongBranch_apu_1
 jmp ValidateSignature
LongBranch_apu_1:
 rep #$20
 .ACCU 16
 lda.l $7e8025
 cmp #$0100
 beq LongBranch_apu_2
 jmp UnsupportedC70016
LongBranch_apu_2:
 sep #$20
 .ACCU 8
 lda.l $7e8027
 ora.l $7e8028
 ora.l $7e8029
 beq LongBranch_apu_3
 jmp UnsupportedC700
LongBranch_apu_3:
 lda.l $7e802a
 cmp #2
 beq LongBranch_apu_4
 jmp UnsupportedC700
LongBranch_apu_4:
 lda.l $7e802b
 cmp #$ff
 beq LongBranch_apu_5
 jmp UnsupportedC700
LongBranch_apu_5:
 lda.l $7f815d
 cmp #4
 beq LongBranch_apu_6
 jmp UnsupportedC700
LongBranch_apu_6:
 lda.l $7f816d
 cmp #8
 beq LongBranch_apu_7
 jmp UnsupportedC700
LongBranch_apu_7:
 ldx #0
ValidateDriver:
 lda.l $7e8200,x
 cmp.w DriverSignature,x
 beq LongBranch_apu_8
 jmp UnsupportedC700
LongBranch_apu_8:
 inx
 cpx #48
 beq LongBranch_apu_9
 jmp ValidateDriver
LongBranch_apu_9:
 ldx #0
ValidateFreeRAM:
 lda.l $7e8300,x
 beq LongBranch_apu_10
 jmp UnsupportedC700
LongBranch_apu_10:
 inx
 cpx #512
 beq LongBranch_apu_11
 jmp ValidateFreeRAM
LongBranch_apu_11:
 ldx #0
ValidateIO:
 lda.l $7e81f0,x
 beq LongBranch_apu_12
 jmp UnsupportedC700
LongBranch_apu_12:
 inx
 cpx #16
 beq LongBranch_apu_13
 jmp ValidateIO
LongBranch_apu_13:
 clc
 rts
UnsupportedC70016:
 sep #$20
 .ACCU 8
UnsupportedC700:
 lda #$61
 jmp FSError
WaitIPL:
 phx
 ldx #$ffff
IPLCheck:
 lda $2140
 cmp #$aa
 beq LongBranch_apu_15
 jmp IPLAgain
LongBranch_apu_15:
 lda $2141
 cmp #$bb
 bne LongBranch_apu_16
 jmp IPLReady
LongBranch_apu_16:
IPLAgain:
 dex
 beq LongBranch_apu_17
 jmp IPLCheck
LongBranch_apu_17:
 plx
 sec
 rts
IPLReady:
 plx
 clc
 rts
WaitAck:
 sta $90
 phx
 ldx #$ffff
AckCheck:
 lda $2140
 cmp $90
 bne LongBranch_apu_18
 jmp AckReady
LongBranch_apu_18:
 dex
 beq LongBranch_apu_19
 jmp AckCheck
LongBranch_apu_19:
 plx
 sec
 rts
AckReady:
 plx
 clc
 rts
LoadAPU:
 jsr WaitIPL
 bcc +
 lda #$51
 jmp FSError
+:
 rep #$20
 .ACCU 16
 lda #$0200
 sta $2142
 sep #$20
 .ACCU 8
 lda #1
 sta $2141
 lda #$cc
 sta $2140
 jsr WaitAck
 bcc +
 jmp UploadFailed
+:
 ldy #0
IPLBootBytes:
 lda.w BootData,y
 sta $2141
 tya
 sta $2140
 jsr WaitAck
 bcc +
 jmp UploadFailed
+:
 iny
 cpy #(BootEnd-BootData)
 beq LongBranch_apu_20
 jmp IPLBootBytes
LongBranch_apu_20:
 rep #$20
 .ACCU 16
 lda #$0200
 sta $2142
 sep #$20
 .ACCU 8
 stz $2141
 tya
 inc a
 sta $2140
 lda #$55
 jsr WaitAck
 bcc +
 jmp UploadFailed
+:
 ; Echo length is latched at ring wrap. Setting EDL=0 alone is insufficient.
 ; Sixteen video frames exceed the maximum 240 ms echo ring on NTSC/PAL.
 ldx #16
EchoSettle:
 jsr WaitFrame
 dex
 bne EchoSettle
 ; Hook the original MOV A,$FF / CLRC tick; preserves normal A/flags behavior.
 lda #$5f
 sta.l $7e8215
 lda #$c0
 sta.l $7e8216
 lda #3
 sta.l $7e8217
 ; RAM $0000-$00EF.
 rep #$20
 .ACCU 16
 lda #$8100
 sta $88
 stz $86
 lda #$00f0
 sta $84
 sep #$20
 .ACCU 8
 lda #$7e
 sta $8a
 jsr SendRange
 bcc +
 jmp UploadFailed
+:
 ; RAM $0100-$01FF.
 rep #$20
 .ACCU 16
 lda #$8200
 sta $88
 lda #$0100
 sta $86
 sta $84
 sep #$20
 .ACCU 8
 lda #$7e
 sta $8a
 jsr SendRange
 bcc +
 jmp UploadFailed
+:
 ; RAM $0400-$FFFF, including original BRR bytes behind the IPL overlay.
 rep #$20
 .ACCU 16
 lda #$8500
 sta $88
 lda #$0400
 sta $86
 lda #$fc00
 sta $84
 sep #$20
 .ACCU 8
 lda #$7e
 sta $8a
 jsr SendRange
 bcc +
 jmp UploadFailed
+:
 ; DSP source registers, separate from the original file's extra-RAM appendix.
 rep #$20
 .ACCU 16
 lda #$8100
 sta $88
 lda #$0300
 sta $86
 lda #$0080
 sta $84
 sep #$20
 .ACCU 8
 lda #$7f
 sta $8a
 jsr SendRange
 bcc +
 jmp UploadFailed
+:
 rep #$20
 .ACCU 16
 lda #StopData
 sta $88
 lda #$03c0
 sta $86
 lda #(StopEnd-StopData)
 sta $84
 sep #$20
 .ACCU 8
 stz $8a
 jsr SendRange
 bcc +
 jmp UploadFailed
+:
 ; Finish upload, let APU initialize DSP while muted, then resume at $0100.
 stz $2141
 lda #$fa
 sta $2140
 lda #$55
 jsr WaitAck
 bcc +
 jmp UploadFailed
+:
 stz $2141
 stz $2142
 stz $2143
 stz $2140
 lda #$c7
 jsr WaitAck
 bcc +
 lda #$54
 jmp FSError
+:
 lda #1
 sta $8f
 clc
 rts
UploadFailed:
 lda #$52
 jmp FSError
SendRange:
 rep #$20
 .ACCU 16
 lda $84
 cmp #128
 bcs LongBranch_apu_21
 jmp SmallPacket
LongBranch_apu_21:
 lda #128
SmallPacket:
 sta $8c
 lda $86
 sta $2142
 sep #$20
 .ACCU 8
 lda $8c
 sta $2141
 lda #$fa
 sta $2140
 jsr WaitAck
 bcc LongBranch_apu_22
 jmp RangeReturn
LongBranch_apu_22:
 ldy #0
PacketBytes:
 lda [$88],y
 sta $2141
 tya
 sta $2140
 jsr WaitAck
 bcc LongBranch_apu_23
 jmp RangeReturn
LongBranch_apu_23:
 iny
 cpy $8c
 beq LongBranch_apu_24
 jmp PacketBytes
LongBranch_apu_24:
 rep #$20
 .ACCU 16
 clc
 lda $88
 adc $8c
 sta $88
 sep #$20
 .ACCU 8
 bcc +
 inc $8a
+:
 rep #$20
 .ACCU 16
 clc
 lda $86
 adc $8c
 sta $86
 sec
 lda $84
 sbc $8c
 sta $84
 sep #$20
 .ACCU 8
 beq LongBranch_apu_25
 jmp SendRange
LongBranch_apu_25:
 clc
RangeReturn:
 rts
