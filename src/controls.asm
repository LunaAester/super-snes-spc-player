.include "control_fields.inc"

; Record pointers are LoROM long addresses. All validation happens before upload.
ValidateSPC:
 stz $4d
 stz $1db0
 stz $1db1
 ldx #0
ControlHeader:
 lda.l $7e8000,x
 cmp.w Signature,x
 beq P5Long_controls_0
 jmp ControlUnsupported
P5Long_controls_0:
 inx
 cpx #25
 beq P5Long_controls_1
 jmp ControlHeader
P5Long_controls_1:
 lda.l $7e81f7
 and #$f0
 cmp #$60
 bne +
 jmp ControlUnsupported
+:
 rep #$20
 .ACCU 16
 stz $1c24
 sep #$20
 .ACCU 8
 ; Fingerprint the original RAM once, before scanning per-snapshot records.
 ; C700 profiles deliberately skip this fingerprint to accept future songs.
 jsr ControlRAMCRC
ControlNext:
 stz $1db0
 ldx $1c24
 rep #$20
 .ACCU 16
 lda.w ControlProfilePointers,x
 sta $98
 sep #$20
 .ACCU 8
 lda.w ControlProfilePointers+2,x
 sta $9a
 ldy #0
ControlRecordHeader:
 lda [$98],y
 sta $1c00,y
 iny
 cpy #32
 beq P5Long_controls_2
 jmp ControlRecordHeader
P5Long_controls_2:
 lda $1c0f
 beq P5Long_controls_52
 jmp ControlCRCMatch
P5Long_controls_52:
 rep #$20
 .ACCU 16
 ldy #32
 lda [$98],y
 cmp $1cf0
 beq +
 jmp AutoNeedCRC
+:
 iny
 iny
 lda [$98],y
 cmp $1cf2
 beq +
 jmp AutoNeedCRC
+:
 sep #$20
 .ACCU 8
 jmp ControlCRCMatch
AutoNeedCRC:
 sep #$20
 .ACCU 8
 jsr AutoExactCRC
 bcs P5Long_controls_60
 jmp ControlCRCMatch
P5Long_controls_60:
 lda #1
 sta $1db0
ControlCRCMatch:
 rep #$20
 .ACCU 16
 lda $1c0c
 jsr ControlRAMPointer
 ldy #36
 ldx #0
 sep #$20
 .ACCU 8
ControlSignature:
 lda [$94]
 cmp [$98],y
 beq P5Long_controls_3
 jmp ControlMismatch
P5Long_controls_3:
 rep #$20
 .ACCU 16
 inc $94
 sep #$20
 .ACCU 8
 bne +
 inc $96
+:
 iny
 inx
 cpx #48
 beq P5Long_controls_4
 jmp ControlSignature
P5Long_controls_4:
 lda $1c0f
 beq P5Long_controls_5
 jmp ControlC700Check
P5Long_controls_5:
 lda $1db0
 beq P5Long_controls_63
 jmp ControlPadding
P5Long_controls_63:
 lda.l $7f816d
 cmp $1c10
 beq P5Long_controls_6
 jmp ControlMismatch
P5Long_controls_6:
 lda.l $7f817d
 and #15
 cmp $1c11
 beq P5Long_controls_7
 jmp ControlMismatch
P5Long_controls_7:
 lda.l $7f816c
 and #$20
 cmp $1c12
 beq P5Long_controls_8
 jmp ControlMismatch
P5Long_controls_8:
 rep #$20
 .ACCU 16
 lda.l $7f815d
 and #$00ff
 xba
 cmp $1c08
 beq P5Long_controls_9
 jmp ControlMismatch16
P5Long_controls_9:
 sep #$20
 .ACCU 8
 ; The full original RAM CRC covers every sample-directory byte.
 jmp ControlPadding
ControlC700Check:
 jsr ValidateC700
 bcc P5Long_controls_12
 jmp ControlMismatch
P5Long_controls_12:
ControlPadding:
 rep #$20
 .ACCU 16
 lda $1c04
 jsr ControlRAMPointer
 ldy #84
 ldx #0
 sep #$20
 .ACCU 8
ControlPadByte:
 lda [$94]
 cmp [$98],y
 beq P5Long_controls_13
 jmp ControlMismatch
P5Long_controls_13:
 rep #$20
 .ACCU 16
 inc $94
 sep #$20
 .ACCU 8
 bne +
 inc $96
+:
 iny
 inx
 cpx $1c0a
 beq P5Long_controls_14
 jmp ControlPadByte
P5Long_controls_14:
 rep #$20
 .ACCU 16
 lda $1c06
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 ldx #0
ControlBootByte:
 lda [$94]
 cmp [$98],y
 beq P5Long_controls_15
 jmp ControlMismatch
P5Long_controls_15:
 rep #$20
 .ACCU 16
 inc $94
 sep #$20
 .ACCU 8
 bne +
 inc $96
+:
 iny
 inx
 cpx #64
 beq P5Long_controls_16
 jmp ControlBootByte
P5Long_controls_16:
 ; Verify every instruction operand that will be changed.
 ldy $1c18
 ldx $1c14
ControlVerifyPatch:
 rep #$20
 .ACCU 16
 lda [$98],y
 jsr ControlRAMPointer
 iny
 iny
 sep #$20
 .ACCU 8
 lda [$98],y
 cmp [$94]
 beq P5Long_controls_17
 jmp ControlMismatch
P5Long_controls_17:
 iny
 iny
 dex
 beq P5Long_controls_18
 jmp ControlVerifyPatch
P5Long_controls_18:
 ; Saved PC cannot execute the borrowed area or the bootstrap.
 rep #$20
 .ACCU 16
 lda.l $7e8025
 sec
 sbc $1c04
 cmp $1c0a
 bcs P5Long_controls_19
 jmp ControlMismatch16
P5Long_controls_19:
 lda.l $7e8025
 sec
 sbc $1c06
 cmp #64
 bcs P5Long_controls_20
 jmp ControlMismatch16
P5Long_controls_20:
 ; Alternate snapshots may have a lower stack than the profiled source.
 lda $1c04
 cmp #$0200
 bcc P5Long_controls_24
 jmp ControlStackBoot
P5Long_controls_24:
 clc
 adc $1c0a
 clc
 adc #8
 sta $1c74
 lda.l $7e802b
 and #$00ff
 ora #$0100
 cmp $1c74
 bcc P5Long_controls_45
 jmp ControlStackBoot
P5Long_controls_45:
 jmp ControlMismatch16
ControlStackBoot:
 lda $1c06
 cmp #$0200
 bcc P5Long_controls_46
 jmp ControlStackValid
P5Long_controls_46:
 clc
 adc #67
 sta $1c74
 lda.l $7e802b
 and #$00ff
 ora #$0100
 cmp $1c74
 bcc P5Long_controls_47
 jmp ControlStackValid
P5Long_controls_47:
 jmp ControlMismatch16
ControlStackValid:
 lda $1c1c
 bne P5Long_controls_48
 jmp ControlAuxiliaryStackValid
P5Long_controls_48:
 sta $1c74
 lda.l $7e802b
 and #$00ff
 cmp $1c74
 bcc P5Long_controls_49
 jmp ControlAuxiliaryStackValid
P5Long_controls_49:
 jmp ControlMismatch16
ControlAuxiliaryStackValid:
 ; CPU-waiting sound effects can share code/data with musical snapshots.
 lda $1c1e
 bne P5Long_controls_50
 jmp ControlSnapshotPCValid
P5Long_controls_50:
 cmp.l $7e8025
 bne P5Long_controls_51
 jmp ControlSnapshotPCValid
P5Long_controls_51:
 jmp ControlMismatch16
ControlSnapshotPCValid:
 sep #$20
 .ACCU 8
 lda $1db0
 bne P5Long_controls_61
 jmp AutoDriverAccepted
P5Long_controls_61:
 jsr AutoDriverValidate
 bcc P5Long_controls_62
 jmp ControlMismatch
P5Long_controls_62:
AutoDriverAccepted:
 rep #$20
 .ACCU 16
 lda $98
 sta $1c20
 sep #$20
 .ACCU 8
 lda $9a
 sta $1c22
 lda #3
 sta $1860
 rep #$20
 .ACCU 16
 lda $1c06
 sta $1862
 stz $1864
 stz $1866
 lda #64
 sta $186c
 lda $1862
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 stz $4d
 clc
 rts
ControlMismatch16:
 sep #$20
 .ACCU 8
ControlMismatch:
 rep #$20
 .ACCU 16
 lda $1c24
 clc
 adc #3
 sta $1c24
 cmp #CONTROL_PROFILE_COUNT*3
 bcc +
 sep #$20
 .ACCU 8
ControlUnsupported:
 lda #$67
 jmp FSError
+:
 sep #$20
 .ACCU 8
 jmp ControlNext

; A is the SMP address; returns an image pointer in $94..$96, A remains 16 bit.
ControlRAMPointer:
 .ACCU 16
 clc
 adc #$8100
 sta $94
 sep #$20
 .ACCU 8
 lda #$7e
 adc #0
 sta $96
 rep #$20
 .ACCU 16
 rts

ControlPrepare:
 rep #$20
 .ACCU 16
 lda $1c20
 sta $98
 sep #$20
 .ACCU 8
 lda $1c22
 sta $9a
 ldx #0
ControlSaveInputs:
 lda.l $7e81f4,x
 sta $1c30,x
 inx
 cpx #4
 beq P5Long_controls_21
 jmp ControlSaveInputs
P5Long_controls_21:
 lda $1c32
 sta.l $7e81f8
 lda $1c33
 sta.l $7e81f9
 rep #$20
 .ACCU 16
 lda $1c04
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 ldy $1c16
 ldx #0
ControlCopyProgram:
 lda [$98],y
 sta [$94]
 rep #$20
 .ACCU 16
 inc $94
 sep #$20
 .ACCU 8
 bne +
 inc $96
+:
 iny
 inx
 cpx $1c0a
 beq P5Long_controls_22
 jmp ControlCopyProgram
P5Long_controls_22:
 ldy $1c18
 ldx $1c14
ControlApplyPatch:
 rep #$20
 .ACCU 16
 lda [$98],y
 jsr ControlRAMPointer
 iny
 iny
 iny
 sep #$20
 .ACCU 8
 lda [$98],y
 sta [$94]
 iny
 dex
 beq P5Long_controls_23
 jmp ControlApplyPatch
P5Long_controls_23:
 jsr AutoRefreshInputs
 rep #$20
 .ACCU 16
 lda.l $7e8025
 sec
 sbc $1c00
 cmp $1c02
 bcc P5Long_controls_10
 jmp ControlPCUnchanged
P5Long_controls_10:
 clc
 adc $1c04
 adc #CONTROL_TAIL
 ; Legacy stereo fallback uses the preceding (one-byte-shorter) kernel.
 pha
 sep #$20
 .ACCU 8
 lda $1c0e
 and #$80
 rep #$20
 .ACCU 16
 beq P5Long_controls_11
 jmp ControlPCMono
P5Long_controls_11:
 pla
 dec a
 jmp ControlPCSet
ControlPCMono:
 pla
ControlPCSet:
 sta.l $7e8025
ControlPCUnchanged:
 lda $1c06
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 lda $1c0e
 sta $1c3b
 lda $1c13
 sta $1c38
 lda $1c1a
 sta $1c39
 lda $1c1b
 sta $1c3a
 lda #100
 sta $1c40
 rep #$20
 .ACCU 16
 lda #100
 sta $1c42
 sep #$20
 .ACCU 8
 lda #3
 sta $1c41
 stz $1c48
 stz $1c44
 stz $1c81
 jsr V13DriverTimer
 ; Prepare display data while the APU is stopped. Do not delay baseline
 ; control setup after the native driver starts running.
 jsr V13Song
 rep #$20
 .ACCU 16
 lda $1c06
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 rts

; F7 command in A, F6 data in $1c68. Input F4/F5 are kept unchanged.
ControlCommand:
 sta $1c69
 lda #1
 sta $16ce
 lda $1c68
 sta $2142
 lda $1c69
 sta $2143
 lda #$d6
 jsr WaitAck
 bcc P5Long_controls_25
 jmp ControlTimeout
P5Long_controls_25:
 lda $2141
 sta $1c6c
 lda $2142
 sta $1c6d
 lda $2143
 sta $1c6e
 lda $1c32
 sta $2142
 lda $1c33
 sta $2143
 phx
 ldx #$ffff
ControlRelease:
 lda $2140
 cmp #$d6
 beq P5Long_controls_26
 jmp ControlReleased
P5Long_controls_26:
 dex
 beq P5Long_controls_27
 jmp ControlRelease
P5Long_controls_27:
 plx
 jmp ControlTimeout
ControlReleased:
 plx
 stz $16ce
 clc
 rts
ControlTimeout:
 stz $16ce
 ; Always release a request after timeout, so the driver can keep running.
 lda $1c32
 sta $2142
 lda $1c33
 sta $2143
 lda #$68
 jmp FSError

ControlSongStarted:
 rep #$20
 .ACCU 16
 lda $46
 sta $1d10
 lda $34
 sta $1d12
 lda $36
 sta $1d14
 sep #$20
 .ACCU 8
 ldx #0
ControlBaseline:
 lda #3
 sta $1cd6
ControlBaselineRetry:
 txa
 asl a
 asl a
 asl a
 asl a
 ora #$0c
 sta $1c68
 lda #$69
 jsr ControlCommand
 bcs P5Long_controls_54
 jmp ControlBaselineReceived
P5Long_controls_54:
 ; A snapshot can finish a pending host command that clears input ports.
 ; Reissue the initial read after that command, with a bounded retry count.
 dec $1cd6
 bne P5Long_controls_55
 jmp ControlBaselineFailed
P5Long_controls_55:
 jsr WaitFrame
 jmp ControlBaselineRetry
ControlBaselineReceived:
 stz $4d
 lda $1c6c
 sta $1c34,x
 inx
 cpx #4
 beq P5Long_controls_28
 jmp ControlBaseline
P5Long_controls_28:
 lda #1
 sta $1c44
 jsr ControlOutputMode
 bcc P5Long_controls_56
 jmp ControlBaselineFailed
P5Long_controls_56:
 clc
ControlBaselineFailed:
 rts

; Preferred output survives song changes. Bit 7 marks a mono-capable profile.
ControlOutputMode:
 lda $8f
 bne P5Long_controls_57
 jmp ControlModeIdle
P5Long_controls_57:
 lda $1c3b
 and #$80
 bne P5Long_controls_58
 jmp ControlModeUnavailable
P5Long_controls_58:
 lda $1c80
 sta $1c68
 lda #$6b
 jsr ControlCommand
 bcc P5Long_controls_59
 jmp ControlModeFailed
P5Long_controls_59:
 lda $1c80
 sta $1c81
 clc
 rts
ControlModeUnavailable:
 stz $1c81
 clc
 rts
ControlModeIdle:
 lda $1c80
 sta $1c81
 clc
ControlModeFailed:
 rts

StopAPU:
 lda $8f
 bne P5Long_controls_29
 jmp ControlStopDone
P5Long_controls_29:
 ; Native IPL must see an idle CPU port 0, even if the source snapshot
 ; retained CC from a previous transfer handshake.
 stz $2140
 stz $2141
 stz $2142
 lda #$60
 sta $2143
 jsr WaitIPL
 bcc +
 lda $1c33
 sta $2143
 lda #$53
 jmp FSError
+:
 stz $8f
 stz $1c44
 ldx #0
ControlClearMeters:
 stz $1c50,x
 inx
 cpx #18
 beq P5Long_controls_30
 jmp ControlClearMeters
P5Long_controls_30:
 jsr ControlOutputMode
ControlStopDone:
 stz $4d
 clc
 rts

ControlVolume:
 ; Percentage is capped at original level, avoiding signed DSP overflow.
 lda $1c40
 cmp #100
 bne P5Long_controls_31
 jmp ControlUnity
P5Long_controls_31:
 rep #$20
 .ACCU 16
 and #$00ff
 xba
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
 bne +
 inc a
+:
 jmp ControlGainReady
ControlUnity:
 lda #0
ControlGainReady:
 sta $1c45
 sta $1c68
 lda #$6a
 jsr ControlCommand
 bcc P5Long_controls_32
 jmp ControlVolumeFailed
P5Long_controls_32:
 ldx #0
ControlVolumeRegister:
 lda $1c34,x
 jsr ControlScale
 sta $1c68
 txa
 clc
 adc #$61
 jsr ControlCommand
 bcc P5Long_controls_33
 jmp ControlVolumeFailed
P5Long_controls_33:
 inx
 cpx #4
 beq P5Long_controls_34
 jmp ControlVolumeRegister
P5Long_controls_34:
ControlVolumeDone:
 clc
 rts
ControlVolumeFailed:
 rts
ControlScale:
 pha
 bpl +
 eor #$ff
 inc a
+:
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
 pla
 bpl +
 lda $4214
 eor #$ff
 inc a
 rts
+:
 lda $4214
 rts

ControlTempo:
 ldx #0
 lda $1c3b
 sta $1c6f
ControlTimerNext:
 lsr $1c6f
 bcs P5Long_controls_35
 jmp ControlTimerSkip
P5Long_controls_35:
 lda $1c38,x
 sta $4202
 lda #100
 sta $4203
 nop
 nop
 nop
 nop
 rep #$20
 .ACCU 16
 lda $4216
 bne +
 lda #25600
+:
 sta $1c74
 sta $4204
 sep #$20
 .ACCU 8
 phx
 lda $1c41
 rep #$20
 .ACCU 16
 and #$00ff
 tax
 sep #$20
 .ACCU 8
 lda.w TempoSteps,x
 sta $4206
 plx
 nop
 nop
 nop
 nop
 rep #$20
 .ACCU 16
 lda $4214
 cmp #257
 bcc +
 lda #256
+:
 cmp #1
 bcs +
 lda #1
+:
 sta $1c72
 sep #$20
 .ACCU 8
 sta $1c68
 txa
 clc
 adc #$65
 jsr ControlCommand
 bcc P5Long_controls_36
 jmp ControlTempoDone
P5Long_controls_36:
 ; Report attainable rate, including the divider's rounding.
 rep #$20
 .ACCU 16
 lda $1c74
 ldy $1c72
 cpy #256
 bne P5Long_controls_37
 jmp ControlRate256
P5Long_controls_37:
 sta $4204
 sep #$20
 .ACCU 8
 lda $1c72
 sta $4206
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 rep #$20
 .ACCU 16
 lda $4214
 jmp ControlRateReady
ControlRate256:
 xba
 and #$00ff
ControlRateReady:
 sta $1c42
 sep #$20
 .ACCU 8
ControlTimerSkip:
 inx
 cpx #3
 beq P5Long_controls_38
 jmp ControlTimerNext
P5Long_controls_38:
 clc
ControlTempoDone:
 rts
TempoSteps:
 .db 50,67,80,100,125,150,200

ControlMeter:
 lda $8f
 bne P5Long_controls_39
 jmp ControlMeterDone
P5Long_controls_39:
 lda $1c44
 bne P5Long_controls_40
 jmp ControlMeterDone
P5Long_controls_40:
 lda $1c48
 asl a
 asl a
 asl a
 asl a
 sta $1c68
 lda #$68
 jsr ControlCommand
 bcc P5Long_controls_41
 jmp ControlMeterFailed
P5Long_controls_41:
 ldx $1c48
 jsr V13Trace
 lda $1c6c
 bpl +
 eor #$ff
 inc a
+:
 sta $1c70
 lda $1c6d
 jsr ControlLevel
 sta $1c50,x
 lda $1c6e
 jsr ControlLevel
 sta $1c58,x
 lda $1c48
 inc a
 and #7
 sta $1c48
 ldx #0
 stz $1c60
 stz $1c61
ControlMeterSum:
 lda $1c60
 clc
 adc $1c50,x
 bcc P5Long_controls_42
 jmp ControlLeftClip
P5Long_controls_42:
 cmp #127
 bcc +
ControlLeftClip:
 lda #127
+:
 sta $1c60
 lda $1c61
 clc
 adc $1c58,x
 bcc P5Long_controls_43
 jmp ControlRightClip
P5Long_controls_43:
 cmp #127
 bcc +
ControlRightClip:
 lda #127
+:
 sta $1c61
 inx
 cpx #8
 beq P5Long_controls_44
 jmp ControlMeterSum
P5Long_controls_44:
 clc
ControlMeterDone:
 clc
 rts
ControlMeterFailed:
 rts
ControlLevel:
 bpl +
 eor #$ff
 inc a
+:
 sta $4202
 lda $1c70
 sta $4203
 nop
 nop
 nop
 nop
 lda $4217
 rts

.include "control_profile_pointers.inc"

; Reflected CRC32, matches zlib.crc32 over the 64 KiB SPC RAM image.
ControlRAMCRC:
 rep #$20
 .ACCU 16
 lda #$8100
 sta $94
 lda #$ffff
 sta $1cf0
 sta $1cf2
 sep #$20
 .ACCU 8
 lda #$7e
 sta $96
 ldy #0
ControlCRCByte:
 lda [$94]
 eor $1cf0
 rep #$20
 .ACCU 16
 and #$00ff
 asl a
 asl a
 tax
 lda $1cf0
 xba
 and #$00ff
 sta $1cf4
 lda $1cf2
 xba
 and #$ff00
 ora $1cf4
 eor.w ControlCRCTable,x
 sta $1cf0
 lda $1cf2
 xba
 and #$00ff
 eor.w ControlCRCTable+2,x
 sta $1cf2
 inc $94
 sep #$20
 .ACCU 8
 bne +
 inc $96
+:
 iny
 beq P5Long_controls_53
 jmp ControlCRCByte
P5Long_controls_53:
 rep #$20
 .ACCU 16
 lda $1cf0
 eor #$ffff
 sta $1cf0
 lda $1cf2
 eor #$ffff
 sta $1cf2
 sep #$20
 .ACCU 8
 rts
ControlCRCTable:
 .incbin "ram_crc32_table.bin"
