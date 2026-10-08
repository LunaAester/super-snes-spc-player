.include "game_fields.inc"

; Choose by verified driver code, never by the song's name.
; $1860: 0 C700, 1 Faceball, 2 Plok; $1862 scratch, $1864 hook,
; $1866 displaced length, $1868 tail offset, $186a IPL token.
DispatchLoadAPU:
 lda $1860
 bne +
 jmp LoadAPU
+:
 jmp GameLoadAPU

GamePrepare:
 jsr ControlPrepare
 ldx #0
ControlResumeTemplate:
 lda.w GeneralResumeData,x
 sta $1a00,x
 inx
 cpx #64
 beq P5Long_game_apu_0
 jmp ControlResumeTemplate
P5Long_game_apu_0:
 jsr GeneralResumeFields
 jmp GamePrepareStack
GameResumeFields:
 lda $1860
 cmp #3
 bne +
 jsr GeneralResumeFields
 jmp GamePrepareStack
+:
 lda.l $7e8100
 sta $1a00+GAME_RAM0
 lda.l $7e8101
 sta $1a00+GAME_RAM1
 lda.l $7e81f4
 sta $1a00+GAME_PORT0
 lda.l $7e81f8
 sta $1a00+GAME_RAMF8
 lda.l $7e81f9
 sta $1a00+GAME_RAMF9
 lda.l $7e81fa
 sta $1a00+GAME_T0
 lda.l $7e81fb
 sta $1a00+GAME_T1
 lda.l $7e81fc
 sta $1a00+GAME_T2
 lda.l $7e81f2
 sta $1a00+GAME_DSPADDR
 lda.l $7e81f1
 and #$cf
 sta $1a00+GAME_CONTROL
 lda.l $7f814c
 sta $1a00+GAME_KON
 lda.l $7f816c
 sta $1a00+GAME_FLG
 lda.l $7e8027
 sta $1a00+GAME_A
 lda.l $7e8028
 sta $1a00+GAME_X
 lda.l $7e8029
 sta $1a00+GAME_Y
 lda.l $7e802b
 sec
 sbc #3
 sta $1a00+GAME_SP
GamePrepareStack:
 ; Put the saved PC in an interrupt frame immediately below the active stack.
 ; A snapshot inside the displaced instructions resumes in their relocated tail.
 rep #$20
 .ACCU 16
 lda.l $7e8025
 sta $186e
 sec
 sbc $1864
 bne P5Long_game_apu_1
 jmp GamePCReady
P5Long_game_apu_1:
 cmp $1866
 bcc P5Long_game_apu_2
 jmp GamePCReady
P5Long_game_apu_2:
 clc
 adc $1862
 adc #80
 adc $1868
 sta $186e
GamePCReady:
 sep #$20
 .ACCU 8
 lda.l $7e802b
 rep #$20
 .ACCU 16
 and #$00ff
 tax
 sep #$20
 .ACCU 8
 lda $186f
 sta.l $7e8200,x
 dex
 rep #$20
 .ACCU 16
 txa
 and #$00ff
 tax
 sep #$20
 .ACCU 8
 lda $186e
 sta.l $7e8200,x
 dex
 rep #$20
 .ACCU 16
 txa
 and #$00ff
 tax
 sep #$20
 .ACCU 8
 lda.l $7e802a
 sta.l $7e8200,x
 ; If IPL was visible in the snapshot, use the appendix for its underlying RAM.
 lda.l $7e81f1
 and #$80
 bne P5Long_game_apu_3
 jmp GameTopReady
P5Long_game_apu_3:
 ldx #0
GameTopRAM:
 lda.l $7f81c0,x
 sta.l $7f80c0,x
 inx
 cpx #64
 beq P5Long_game_apu_4
 jmp GameTopRAM
P5Long_game_apu_4:
GameTopReady:
 ldy #0
GameInsertScratch:
 lda $1a00,y
 sta [$94],y
 iny
 cpy $186c
 beq P5Long_game_apu_5
 jmp GameInsertScratch
P5Long_game_apu_5:
 lda $1860
 cmp #3
 bne +
 rts
+:
 ; Patch a JMP into the verified timer loop, padding displaced instructions.
 rep #$20
 .ACCU 16
 lda $1864
 clc
 adc #$8100
 sta $94
 sep #$20
 .ACCU 8
 lda #$7e
 adc #0
 sta $96
 ldy #0
 lda #$5f
 sta [$94],y
 iny
 rep #$20
 .ACCU 16
 lda $1862
 clc
 adc #80
 sta [$94],y
 sep #$20
 .ACCU 8
 ldy #3
 cpy $1866
 bne P5Long_game_apu_6
 jmp GameHookDone
P5Long_game_apu_6:
 lda #0
GameHookPadding:
 sta [$94],y
 iny
 cpy $1866
 beq P5Long_game_apu_7
 jmp GameHookPadding
P5Long_game_apu_7:
GameHookDone:
 rts

GameLoadAPU:
 jsr WaitIPL
 bcc +
 lda #$51
 jmp FSError
+:
 jsr GamePrepare
 ; Temporary DSP code lives in CPU WRAM; it is replaced by the original RAM later.
 ldx #0
GameDSPTemplate:
 lda.w GameDSPData,x
 sta $1900,x
 inx
 cpx #256
 beq P5Long_game_apu_8
 jmp GameDSPTemplate
P5Long_game_apu_8:
 ldx #0
GameDSPRegisters:
 lda.l $7f8100,x
 sta $1980,x
 inx
 cpx #128
 beq P5Long_game_apu_9
 jmp GameDSPRegisters
P5Long_game_apu_9:
 lda.l $7e81f8
 sta $1989
 lda.l $7e81f9
 sta $198a
 lda.l $7e81fa
 sta $198b
 lda.l $7e81fb
 sta $1999
 lda.l $7e81fc
 sta $199a
 lda #$cc
 sta $186a
 rep #$20
 .ACCU 16
 lda #$1900
 sta $88
 lda #$0200
 sta $86
 lda #256
 sta $84
 sep #$20
 .ACCU 8
 stz $8a
 jsr GameIPLRange
 bcc +
 jmp UploadFailed
+:
 jsr GameIPLExecute
 bcc +
 jmp UploadFailed
+:
 lda #$55
 jsr WaitAck
 bcc +
 jmp UploadFailed
+:
 ldx #16
GameEchoSettle:
 jsr WaitFrame
 dex
 beq P5Long_game_apu_10
 jmp GameEchoSettle
P5Long_game_apu_10:
 lda #$a6
 sta $2140
 jsr WaitIPL
 bcc +
 jmp UploadFailed
+:
 lda #$cc
 sta $186a
 rep #$20
 .ACCU 16
 lda #$8102
 sta $88
 lda #2
 sta $86
 lda #$00ee
 sta $84
 sep #$20
 .ACCU 8
 lda #$7e
 sta $8a
 jsr GameIPLRange
 bcc +
 jmp UploadFailed
+:
 rep #$20
 .ACCU 16
 lda #$8200
 sta $88
 lda #$0100
 sta $86
 lda #$ff00
 sta $84
 sep #$20
 .ACCU 8
 jsr GameIPLRange
 bcc +
 jmp UploadFailed
+:
 rep #$20
 .ACCU 16
 lda $1862
 sta $86
 sep #$20
 .ACCU 8
 jsr GameIPLExecute
 bcc +
 jmp UploadFailed
+:
 lda #$55
 jsr WaitAck
 bcc +
 jmp UploadFailed
+:
 ; Restore input ports while the bootstrap holds execution; then release them.
.IFDEF TESTFS
 lda $1890
 cmp #$a5
 beq P5Long_game_apu_11
 jmp GameTestContinue
P5Long_game_apu_11:
 lda #2
 sta $7f
GameTestHold:
 lda $1890
 cmp #$a5
 bne P5Long_game_apu_12
 jmp GameTestHold
P5Long_game_apu_12:
 stz $7f
GameTestContinue:
.ENDIF
 lda.l $7e81f5
 sta $2141
 lda.l $7e81f6
 sta $2142
 lda.l $7e81f7
 sta $2143
 lda #$81
 sta $2140
 lda #$56
 jsr WaitAck
 bcc +
 jmp UploadFailed
+:
 lda.l $7e81f4
 sta $2140
 lda #$c7
 jsr WaitAck
 bcc +
 lda #$54
 jmp FSError
+:
 lda #1
 sta $8f
 jsr ControlSongStarted
 rts

; ROM IPL protocol, not the C700 custom packet protocol. The counter for the
; next block is last-byte-index + 2 (avoiding zero), as required by the IPL.
GameIPLRange:
 rep #$20
 .ACCU 16
 lda $86
 sta $2142
 sep #$20
 .ACCU 8
 lda #1
 sta $2141
 lda $186a
 sta $2140
 jsr WaitAck
 bcc +
 rts
+:
 ldy #0
GameIPLByte:
 lda [$88],y
 sta $2141
 tya
 sta $2140
 jsr WaitAck
 bcc +
 rts
+:
 iny
 jsr LoadingUploadProgress
 cpy $84
 beq P5Long_game_apu_13
 jmp GameIPLByte
P5Long_game_apu_13:
 tya
 inc a
 bne +
 inc a
+:
 sta $186a
 clc
 rts
GameIPLExecute:
 rep #$20
 .ACCU 16
 lda $86
 sta $2142
 sep #$20
 .ACCU 8
 stz $2141
 lda $186a
 sta $2140
 jmp WaitAck

GameFaceballSignature:
 .incbin "game_signature_faceball.bin"
GamePlokSignature:
 .incbin "game_signature_plok.bin"
GameResumeData:
 .incbin "game_resume.bin"
GameFaceballHook:
 .incbin "game_hook_faceball.bin"
GamePlokHook:
 .incbin "game_hook_plok.bin"
GameDSPData:
 .incbin "game_dsp.bin"
