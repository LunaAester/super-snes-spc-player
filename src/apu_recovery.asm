; Bounded recovery of IPL / this player's resident and song drivers.
; Do not infer an APU reset from a CPU RESET or from CPU-side state flags.
APUStartup:
 stz $1ce9
 jsr APUEnsureIPL
 bcc +
 lda #1
 sta $1ce9
+:
 rts
APUEnsureIPL:
 phx
 lda $1cfa
 beq +
 jsr APUAbortIPL
 bcs P5Long_apu_recovery_4
 jmp APURecovered
P5Long_apu_recovery_4:
+:
 lda $2140
 cmp #$aa
 beq P5Long_apu_recovery_0
 jmp APURecover
P5Long_apu_recovery_0:
 lda $2141
 cmp #$bb
 bne P5Long_apu_recovery_1
 jmp APURecovered
P5Long_apu_recovery_1:
APURecover:
 ; Native IPL and cooperative drivers see these inputs, not CPU-side outputs.
 stz $2140
 stz $2141
 stz $2142
 lda #$60
 sta $2143
 lda #$a6
 sta $2140
 ldx #8
APURecoverWait:
 phx
 jsr WaitIPL
 plx
 bcs P5Long_apu_recovery_2
 jmp APURecovered
P5Long_apu_recovery_2:
 jsr WaitFrame
 dex
 beq P5Long_apu_recovery_3
 jmp APURecoverWait
P5Long_apu_recovery_3:
 plx
 sec
 rts
APURecovered:
 stz $1cfa
 stz $2140
 stz $2141
 stz $2142
 stz $2143
 stz $1ce0
 stz $1ce2
 plx
 clc
 rts

; $1cfa is set exclusively by this ROM's native IPL transfers. Never use this
; abort handshake on an arbitrary game driver. IPL compares the next byte
; counter with the last acknowledgement; advancing by two ends the block.
APUAbortIPL:
 phx
 phy
 lda $1cfa
 cmp #1
 beq P5Long_apu_recovery_5
 jmp APUAbortEndBlock
P5Long_apu_recovery_5:
 ; The IPL may still be waiting for the first (zero-indexed) byte.
 stz $2141
 stz $2140
 lda #0
 jsr WaitAck
 bcc P5Long_apu_recovery_6
 jmp APUAbortFailed
P5Long_apu_recovery_6:
APUAbortEndBlock:
 lda $2140
 clc
 adc #2
 bne +
 inc a
+:
 pha
 rep #$20
 .ACCU 16
 lda #$ffc0
 sta $2142
 sep #$20
 .ACCU 8
 stz $2141
 pla
 sta $2140
 jsr WaitIPL
 bcc P5Long_apu_recovery_7
 jmp APUAbortFailed
P5Long_apu_recovery_7:
 stz $1cfa
 ply
 plx
 clc
 rts
APUAbortFailed:
 ply
 plx
 sec
 rts
