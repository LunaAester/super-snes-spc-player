; Display-only state: $1cb0/1 envelope, $1cb2/3 peak, $1cb4/5 hold.
; The APU sampling cadence and DSP/audio commands remain unchanged.
HUDMonoText:
 .db "MONO   "
HUDStereoText:
 .db "STEREO "
HUDStereoOnlyText:
 .db "STEREO*"
HUDPlayText:
 .db "PLAY "
HUDThresholds:
 .db 120,100,84,70,58,48,40,33,27,22,18,15,12,10,8,6,4,3,2,1

HUDClearMeters:
 .ACCU 8
 phx
 ldx #5
HUDClearNext:
 stz $1cb0,x
 dex
 bmi P5Long_hud_meters_0
 jmp HUDClearNext
P5Long_hud_meters_0:
 plx
 rts

HUDSliders:
 .ACCU 8
 lda $1c40
 sta $4202
 lda #12
 sta $4203
 nop
 nop
 nop
 nop
 rep #$20
 .ACCU 16
 lda $4216
 sta $4204
 sep #$20
 .ACCU 8
 lda #100
 sta $4206
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 lda $4214
 sta $1cb6
 rep #$20
 .ACCU 16
 lda #2*(20*32+17)
 sta $1ca0
 sep #$20
 .ACCU 8
 ldx #0
HUDVolumeTick:
 lda #28
 sta $1ca2
 txa
 cmp $1cb6
 bcc P5Long_hud_meters_1
 jmp HUDVolumeEmpty
P5Long_hud_meters_1:
 lda #16
 sta $1ca2
 lda #109
 jmp HUDVolumeReady
HUDVolumeEmpty:
 lda #110
HUDVolumeReady:
 jsr HUDTile
 inx
 cpx #12
 beq P5Long_hud_meters_2
 jmp HUDVolumeTick
P5Long_hud_meters_2:
 rep #$20
 .ACCU 16
 lda #2*(21*32+17)
 sta $1ca0
 sep #$20
 .ACCU 8
 ldx #0
HUDTempoTick:
 lda #28
 sta $1ca2
 txa
 cmp $1c41
 beq P5Long_hud_meters_3
 jmp HUDTempoEmpty
P5Long_hud_meters_3:
 lda #24
 sta $1ca2
 lda #109
 jmp HUDTempoReady
HUDTempoEmpty:
 lda #110
HUDTempoReady:
 jsr HUDTile
 inx
 cpx #7
 beq P5Long_hud_meters_4
 jmp HUDTempoTick
P5Long_hud_meters_4:
 rts

HUDMeters:
 .ACCU 8
 lda $8f
 bne P5Long_hud_meters_5
 jmp HUDMetersSilent
P5Long_hud_meters_5:
 lda $1c40
 beq P5Long_hud_meters_6
 jmp HUDMetersStart
P5Long_hud_meters_6:
HUDMetersSilent:
 jsr HUDClearMeters
HUDMetersStart:
 ldx #0
HUDSide:
 lda $8f
 bne P5Long_hud_meters_7
 jmp HUDNoActivity
P5Long_hud_meters_7:
 lda $1c40
 bne P5Long_hud_meters_8
 jmp HUDNoActivity
P5Long_hud_meters_8:
 ; Fivefold display gain, then apply the user's volume. No audio gain change.
 lda $1c60,x
 cmp #26
 bcc P5Long_hud_meters_9
 jmp HUDGainClip
P5Long_hud_meters_9:
 sta $1cab
 asl a
 asl a
 clc
 adc $1cab
 jmp HUDGainReady
HUDGainClip:
 lda #127
HUDGainReady:
 sta $4202
 lda $1c40
 sta $4203
 nop
 nop
 nop
 nop
 rep #$20
 .ACCU 16
 lda $4216
 sta $4204
 sep #$20
 .ACCU 8
 lda #100
 sta $4206
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 lda $4214
 sta $1cab
 ; Instant attack; release is two units per rendered frame.
 cmp $1cb0,x
 bcc P5Long_hud_meters_10
 jmp HUDEnvelopeReady
P5Long_hud_meters_10:
 lda $1cb0,x
 sec
 sbc #2
 bcs P5Long_hud_meters_11
 jmp HUDEnvelopeZero
P5Long_hud_meters_11:
 cmp $1cab
 bcc P5Long_hud_meters_12
 jmp HUDEnvelopeReady
P5Long_hud_meters_12:
HUDEnvelopeZero:
 lda $1cab
HUDEnvelopeReady:
 sta $1cb0,x
 cmp $1cb2,x
 bcc P5Long_hud_meters_13
 jmp HUDPeakAttack
P5Long_hud_meters_13:
 lda $1cb4,x
 bne P5Long_hud_meters_14
 jmp HUDPeakRelease
P5Long_hud_meters_14:
 dec $1cb4,x
 jmp HUDEnvelopeDone
HUDPeakRelease:
 lda $1cb2,x
 sec
 sbc #3
 bcs P5Long_hud_meters_15
 jmp HUDPeakFloor
P5Long_hud_meters_15:
 cmp $1cb0,x
 bcc P5Long_hud_meters_16
 jmp HUDPeakReady
P5Long_hud_meters_16:
HUDPeakFloor:
 lda $1cb0,x
HUDPeakReady:
 sta $1cb2,x
 jmp HUDEnvelopeDone
HUDPeakAttack:
 sta $1cb2,x
 lda #12
 sta $1cb4,x
HUDEnvelopeDone:
 jmp HUDMeterColumn
HUDNoActivity:
 stz $1cb0,x
 stz $1cb2,x
 stz $1cb4,x
HUDMeterColumn:
 rep #$20
 .ACCU 16
 txa
 bne P5Long_hud_meters_17
 jmp HUDLeftColumn
P5Long_hud_meters_17:
 lda #2*(7*32+28)
 jmp HUDColumn
HUDLeftColumn:
 lda #2*(7*32+25)
HUDColumn:
 sta $1ca0
 sep #$20
 .ACCU 8
 stz $1cb7
 ldy #0
HUDLED:
 lda #0
 sta $1cb9
 lda $1cb7
 beq P5Long_hud_meters_18
 jmp HUDSegmentLevel
P5Long_hud_meters_18:
 lda $1cb2,x
 cmp.w HUDThresholds,y
 bcs P5Long_hud_meters_19
 jmp HUDSegmentLevel
P5Long_hud_meters_19:
 inc $1cb7
 lda #2
 sta $1cb9
HUDSegmentLevel:
 lda $1cb0,x
 cmp.w HUDThresholds,y
 bcs P5Long_hud_meters_20
 jmp HUDSegmentReady
P5Long_hud_meters_20:
 lda #1
 sta $1cb9
HUDSegmentReady:
 tya
 and #1
 beq P5Long_hud_meters_21
 jmp HUDPairReady
P5Long_hud_meters_21:
 lda $1cb9
 sta $1cb8
 jmp HUDSegmentNext
HUDPairReady:
 lda #16
 sta $1ca2
 cpy #4
 bcs P5Long_hud_meters_22
 jmp HUDPairRed
P5Long_hud_meters_22:
 cpy #10
 bcc P5Long_hud_meters_25
 jmp HUDPairColourReady
P5Long_hud_meters_25:
 lda #20
 sta $1ca2
 jmp HUDPairColourReady
HUDPairRed:
 lda #24
 sta $1ca2
HUDPairColourReady:
 lda $1cb8
 asl a
 clc
 adc $1cb8
 adc $1cb9
 adc #118
 sta $1cb9
 jsr HUDTile
 lda $1ca2
 ora #$40
 sta $1ca2
 lda $1cb9
 jsr HUDTile
 rep #$20
 .ACCU 16
 lda $1ca0
 clc
 adc #60
 sta $1ca0
 sep #$20
 .ACCU 8
HUDSegmentNext:
 iny
 cpy #20
 beq P5Long_hud_meters_26
 jmp HUDLED
P5Long_hud_meters_26:
P5Long_hud_meters_23:
 inx
 cpx #2
 beq P5Long_hud_meters_24
 jmp HUDSide
P5Long_hud_meters_24:
 rts
