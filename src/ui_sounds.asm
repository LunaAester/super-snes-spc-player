.include "ui_audio_defs.inc"
; $1ce0: resident UI APU; $1ce1: cue sequence; $1ce2: 1 move / 2 logo / 3 error.
; The UI APU is always released before loading an ordinary SPC.
UISoundEnsureMove:
 lda $8f
 bne P5Long_ui_sounds_0
 jmp UISoundIdle
P5Long_ui_sounds_0:
 clc
 rts
UISoundIdle:
 lda $1ce0
 bne P5Long_ui_sounds_1
 jmp UISoundLoadMove
P5Long_ui_sounds_1:
 lda $1ce2
 cmp #1
 bne P5Long_ui_sounds_2
 jmp UISoundReady
P5Long_ui_sounds_2:
UISoundLoadMove:
 jsr UISoundRelease
 bcc P5Long_ui_sounds_3
 jmp UISoundFailed
P5Long_ui_sounds_3:
 lda #1
 jmp UISoundLoad
UISoundPrepareLogo:
 jsr UISoundRelease
 bcc P5Long_ui_sounds_4
 jmp UISoundFailed
P5Long_ui_sounds_4:
 lda #2
UISoundLoad:
 sta $1ce5
 stz $1cd0
 jsr WaitIPL
 bcc P5Long_ui_sounds_5
 jmp UISoundFailed
P5Long_ui_sounds_5:
 lda #$cc
 sta $186a
 rep #$20
 .ACCU 16
 ldx #0
 sep #$20
 .ACCU 8
 lda $1ce5
 cmp #2
 beq P5Long_ui_sounds_6
 jmp UISoundDescriptorReady
P5Long_ui_sounds_6:
 ldx #28
UISoundDescriptorReady:
 lda #4
 sta $1ce8
 lda $1ce5
 cmp #3
 bne +
 ldx #56
 lda #3
 sta $1ce8
+:
UISoundSegment:
 rep #$20
 .ACCU 16
 lda.w UIAudioDescriptors,x
 sta $88
 lda.w UIAudioDescriptors+3,x
 sta $86
 lda.w UIAudioDescriptors+5,x
 sta $84
 sep #$20
 .ACCU 8
 lda.w UIAudioDescriptors+2,x
 sta $8a
 jsr UIIPLRange
 bcc P5Long_ui_sounds_7
 jmp UISoundFailed
P5Long_ui_sounds_7:
 rep #$20
 .ACCU 16
 txa
 clc
 adc #7
 tax
 sep #$20
 .ACCU 8
 dec $1ce8
 beq P5Long_ui_sounds_8
 jmp UISoundSegment
P5Long_ui_sounds_8:
 jsr GameIPLExecute
 bcc P5Long_ui_sounds_9
 jmp UISoundFailed
P5Long_ui_sounds_9:
 lda #$55
 jsr WaitAck
 bcc P5Long_ui_sounds_10
 jmp UISoundFailed
P5Long_ui_sounds_10:
 stz $2140
 lda #$e2
 jsr WaitAck
 bcc +
 jmp UISoundFailed
+:
 stz $1ce1
 lda $1ce5
 sta $1ce2
 lda #1
 sta $1ce0
UISoundReady:
 clc
 rts
UISoundFailed:
 stz $1ce0
 stz $1ce2
 sec
 rts
UISoundRelease:
 lda $1ce0
 bne P5Long_ui_sounds_11
 jmp UISoundReleased
P5Long_ui_sounds_11:
 lda #$a6
 sta $2140
 jsr WaitIPL
 bcc P5Long_ui_sounds_12
 jmp UISoundReleaseFailed
P5Long_ui_sounds_12:
 stz $1ce0
 stz $1ce2
UISoundReleased:
 clc
 rts
UISoundReleaseFailed:
 sec
 rts

; Preserve the caller's 8/16-bit A mode and selection registers.
UISoundMove:
 php
 sep #$20
 .ACCU 8
 pha
 phx
 phy
 lda $8f
 beq P5Long_ui_sounds_13
 jmp UISoundMoveDone
P5Long_ui_sounds_13:
 lda $44
 cmp #1
 bne +
 jmp UISoundMoveDone
+:
 lda $1ce0
 bne P5Long_ui_sounds_14
 jmp UISoundMoveDone
P5Long_ui_sounds_14:
 lda $1ce2
 cmp #1
 beq P5Long_ui_sounds_15
 jmp UISoundMoveDone
P5Long_ui_sounds_15:
 lda #127
 jsr ControlScale
 sta $2141
 lda $1c80
 sta $2142
 jsr UISoundCue
UISoundMoveDone:
 ply
 plx
 pla
 plp
 rts
UISoundLogo:
 .ACCU 8
 lda $1ce0
 bne P5Long_ui_sounds_16
 jmp UISoundLogoDone
P5Long_ui_sounds_16:
 lda $1ce2
 cmp #2
 beq P5Long_ui_sounds_17
 jmp UISoundLogoDone
P5Long_ui_sounds_17:
 lda #127
 sta $2141
 stz $2142
 jsr UISoundCue
UISoundLogoDone:
 rts
UISoundCue:
 inc $1ce1
 lda $1ce1
 and #$7f
 beq P5Long_ui_sounds_18
 jmp UISoundTokenReady
P5Long_ui_sounds_18:
 inc a
UISoundTokenReady:
 sta $1ce1
 sta $2140
 rts

; IPL byte transfer without progress redraw or a subroutine per audio byte.
; Every acknowledgement remains bounded, and the native IPL counter is kept.
UIIPLRange:
 lda #1
 sta $1cfa
 phx
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
 bcc P5Long_ui_sounds_19
 jmp UIIPLFailed
P5Long_ui_sounds_19:
 ldy #0
UIIPLByte:
 lda #2
 sta $1cfa
 lda [$88],y
 sta $2141
 tya
 sta $2140
 ldx #$ffff
UIIPLAck:
 cmp $2140
 bne P5Long_ui_sounds_20
 jmp UIIPLReceived
P5Long_ui_sounds_20:
 dex
 beq P5Long_ui_sounds_21
 jmp UIIPLAck
P5Long_ui_sounds_21:
 jmp UIIPLFailed
UIIPLReceived:
 iny
 cpy $84
 beq P5Long_ui_sounds_22
 jmp UIIPLByte
P5Long_ui_sounds_22:
 tya
 inc a
 beq P5Long_ui_sounds_23
 jmp UIIPLTokenReady
P5Long_ui_sounds_23:
 inc a
UIIPLTokenReady:
 sta $186a
 plx
 clc
 rts
UIIPLFailed:
 plx
 sec
 rts

UIAudioDescriptors:
 .dw MoveDirectory
 .db ROMBANK_125
 .dw $0400,8
 .dw MoveLeft
 .db ROMBANK_125
 .dw $1000,(MoveLeftEnd-MoveLeft)
 .dw MoveRight
 .db ROMBANK_125
 .dw $1000+(MoveLeftEnd-MoveLeft),(MoveRightEnd-MoveRight)
 .dw MoveDriver
 .db ROMBANK_125
 .dw $0200,512
 .dw LogoAudioDirectory
 .db ROMBANK_123
 .dw $0400,8
 .dw LogoAudioLeft
 .db ROMBANK_123
 .dw $1000,(LogoAudioLeftEnd-LogoAudioLeft)
 .dw LogoAudioRight
 .db ROMBANK_124
 .dw $1000+(LogoAudioLeftEnd-LogoAudioLeft),(LogoAudioRightEnd-LogoAudioRight)
 .dw LogoAudioDriver
 .db ROMBANK_123
 .dw $0200,512

 .dw ErrorDirectory
 .db ROMBANK_126
 .dw $0400,8
 .dw ErrorSample
 .db ROMBANK_126
 .dw $1000,(ErrorSampleEnd-ErrorSample)
 .dw ErrorDriver
 .db ROMBANK_126
 .dw $0200,512

; An error cue never replaces diagnostic data or blocks on an unresponsive APU.
UISoundError:
 lda $4d
 sta $1ce6
 lda $1cec
 sta $1ce7
 lda $8f
 beq +
 jsr StopAPU
 bcc P5Long_ui_sounds_24
 jmp UISoundErrorDone
P5Long_ui_sounds_24:
+:
 jsr UISoundRelease
 bcc P5Long_ui_sounds_25
 jmp UISoundErrorDone
P5Long_ui_sounds_25:
 jsr APUEnsureIPL
 bcc P5Long_ui_sounds_26
 jmp UISoundErrorDone
P5Long_ui_sounds_26:
 lda #3
 jsr UISoundLoad
 bcc P5Long_ui_sounds_27
 jmp UISoundErrorDone
P5Long_ui_sounds_27:
 lda #80
 sta $2141
 stz $2142
 jsr UISoundCue
UISoundErrorDone:
 lda $1ce7
 sta $1cec
 lda $1ce6
 sta $4d
 rts
