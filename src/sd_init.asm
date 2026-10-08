; Warm-menu fast path, with a bounded SPI-mode reset/init recovery.
; Only commands affecting volatile SD state; no filesystem writes.
; $1840 phase, $1841 recovery, $1842 SD-v2, $1843 CMD0 retries,
; $1846 ACMD41 retries. No counters in registers clobbered by SendCommand.
SDInit:
 stz $1840
 stz $1841
 stz $1842
 stz $43
 lda.l $003003
 sta $1844
 lda.l $003004
 sta $1845
 lda #$ff
 sta $1800
 sta $1825
 jsr SDZeroArgument
.IFDEF TESTFS
 lda #$40
 sta $43
 lda #8
 sta $1840
 clc
 rts
.ELSE
 jsr SDInitClocks
 bcc +
 jmp SDTimeout
+:
 lda #1
 sta $1840
 jsr SDReadOCR
 bcs +
 jmp SDSetBlockLength
+:
 lda $4d
 cmp #$10
 bne +
 sec
 rts
+:
 ; No usable OCR: do not depend on the menu's card initialization.
 stz $4d
 lda #1
 sta $1841
 lda #16
 sta $1843
SDResetAttempt:
 lda #2
 sta $1840
 jsr SDInitClocks
 bcc +
 jmp SDTimeout
+:
 jsr SDZeroArgument
 lda #$40
 sta $1800
 jsr SendCommand
 bcc SDResetR1
 lda $4d
 cmp #$10
 bne +
 sec
 rts
+:
 jmp SDResetNext
SDResetR1:
 cmp #1
 bne SDResetReleaseRetry
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
 jmp SDProbeVersion
SDResetReleaseRetry:
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
SDResetNext:
 dec $1843
 bne +
 lda #$18
 jmp SDFail
+:
 stz $4d
 jsr WaitFrame
 jmp SDResetAttempt
SDProbeVersion:
 lda #3
 sta $1840
 jsr SDZeroArgument
 lda #$48
 sta $1800
 lda #1
 sta $1803
 lda #$aa
 sta $1804
 jsr SendCommand
 bcc +
 rts
+:
 cmp #$05
 bne SDVersionModern
 ; CMD8 illegal in idle is the legacy SDSC path; there is no R7.
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
 jmp SDPowerUpBegin
SDVersionModern:
 cmp #1
 beq +
 lda #$19
 jmp SDFail
+:
 ldy #0
SDReadR7:
 lda #$ff
 jsr SPIByte
 bcc +
 jmp SDTimeout
+:
 sta $1850,y
 iny
 cpy #4
 bne SDReadR7
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
 lda $1850
 ora $1851
 bne SDVersionFailure
 lda $1852
 cmp #1
 bne SDVersionFailure
 lda $1853
 cmp #$aa
 bne SDVersionFailure
 lda #1
 sta $1842
 jmp SDPowerUpBegin
SDVersionFailure:
 lda #$19
 jmp SDFail
SDPowerUpBegin:
 lda #120
 sta $1846
SDPowerUpAttempt:
 lda #4
 sta $1840
 jsr SDZeroArgument
 lda #$77
 sta $1800
 jsr SendCommand
 bcc +
 rts
+:
 cmp #2
 bcc +
 lda #$1a
 jmp SDFail
+:
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
 lda #5
 sta $1840
 jsr SDZeroArgument
 lda #$69
 sta $1800
 lda $1842
 beq +
 lda #$40
 sta $1801
+:
 jsr SendCommand
 bcc +
 rts
+:
 cmp #0
 beq SDPowerUpComplete
 cmp #1
 beq +
 lda #$1a
 jmp SDFail
+:
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
 dec $1846
 bne +
 lda #$1b
 jmp SDFail
+:
 ; Allow over one second before timing out, even on a 60-Hz console.
 jsr WaitFrame
 jsr WaitFrame
 jmp SDPowerUpAttempt
SDPowerUpComplete:
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
 lda #6
 sta $1840
 jsr SDReadOCR
 bcc +
 rts
+:
 lda $1842
 bne +
 stz $43
+:
SDSetBlockLength:
 lda $43
 bne SDInitReady
 lda #7
 sta $1840
 jsr SDZeroArgument
 lda #$50
 sta $1800
 lda #2
 sta $1803
 jsr SendCommand
 bcc +
 rts
+:
 cmp #0
 beq +
 lda #$1d
 jmp SDFail
+:
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
SDInitReady:
 stz $4d
 lda #8
 sta $1840
 clc
 rts

SDReadOCR:
 jsr SDZeroArgument
 lda #$7a
 sta $1800
 jsr SendCommand
 bcc +
 rts
+:
 cmp #0
 beq +
 lda #$12
 jmp SDFail
+:
 ldy #0
SDInitOCRBytes:
 lda #$ff
 jsr SPIByte
 bcc +
 jmp SDTimeout
+:
 sta $1810,y
 iny
 cpy #4
 bne SDInitOCRBytes
 jsr SDRelease
 bcc +
 jmp SDTimeout
+:
 lda $1810
 and #$80
 bne +
 lda #$13
 jmp SDFail
+:
 ; Reject an OCR with no supported 2.7--3.6 V window.
 lda $1811
 and #$ff
 bne SDVoltageOK
 lda $1812
 and #$80
 bne SDVoltageOK
 lda #$1c
 jmp SDFail
SDVoltageOK:
 lda $1810
 and #$40
 sta $43
 clc
 rts
.ENDIF

SDZeroArgument:
 stz $1801
 stz $1802
 stz $1803
 stz $1804
 stz $1805
 rts
SDInitClocks:
 jsr SDRelease
 bcc +
 rts
+:
 ldy #10
SDInitIdleByte:
 lda #$ff
 jsr SPIByte
 bcc +
 rts
+:
 dey
 bne SDInitIdleByte
 clc
 rts
