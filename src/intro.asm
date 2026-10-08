; Intro is self-contained and returns the APU to IPL before any SD/SPC use.
RunIntro:
 stz $1cd0
 lda #1
 sta $1cda
 jsr IntroVideo
 jsr APUEnsureIPL
 bcc +
 jmp IntroNoAudio
+:
 lda #$cc
 sta $186a
 rep #$20
 .ACCU 16
 lda #IntroDirectory
 sta $88
 lda #$0400
 sta $86
 lda #8
 sta $84
 sep #$20
 .ACCU 8
 lda #ROMBANK_121
 sta $8a
 jsr GameIPLRange
 bcc +
 jmp IntroNoAudio
+:
 rep #$20
 .ACCU 16
 lda #IntroLeft
 sta $88
 lda #$1000
 sta $86
 lda #(IntroLeftEnd-IntroLeft)
 sta $84
 sep #$20
 .ACCU 8
 jsr GameIPLRange
 bcc +
 jmp IntroNoAudio
+:
 rep #$20
 .ACCU 16
 lda #IntroRight
 sta $88
 lda #$1000+(IntroLeftEnd-IntroLeft)
 sta $86
 lda #(IntroRightEnd-IntroRight)
 sta $84
 sep #$20
 .ACCU 8
 lda #ROMBANK_122
 sta $8a
 jsr GameIPLRange
 bcc +
 jmp IntroNoAudio
+:
 rep #$20
 .ACCU 16
 lda #IntroDriver
 sta $88
 lda #$0200
 sta $86
 lda #256
 sta $84
 sep #$20
 .ACCU 8
 lda #ROMBANK_121
 sta $8a
 jsr GameIPLRange
 bcc +
 jmp IntroNoAudio
+:
 jsr GameIPLExecute
 bcc +
 jmp IntroNoAudio
+:
 lda #$55
 jsr WaitAck
 bcc +
 jmp IntroNoAudio
+:
 lda #1
 sta $1cdc
IntroNoAudio:
 jsr PresentVideo
 jsr WaitFrame
 lda #2
 sta $1cda
 lda #$0f
 sta $2100
 ; Start the animated presentation and its audio on the same VBlank.
 lda #1
 sta $2140
 jsr PresentAnimation
 lda #4
 sta $1cda
 jsr IntroFadeOut
 lda $1cdc
 bne P5Long_intro_1
 jmp IntroLogoShow
P5Long_intro_1:
 lda #$a6
 sta $2140
 jsr WaitIPL
 bcs P5Long_intro_2
 jmp IntroLogoShow
P5Long_intro_2:
 lda #1
 sta $1cde
IntroLogoShow:
 lda #5
 sta $1cda
 jsr UISoundPrepareLogo
 bcc +
 lda #2
 sta $1cde
+:
 jsr IntroThunderCue
 ldx #24
IntroTransitionPause:
 jsr WaitFrame
 dex
 beq P5Long_intro_5
 jmp IntroTransitionPause
P5Long_intro_5:
 ; Restore the logo's 4bpp tiles and palette after the 2bpp animation.
 jsr IntroVideo
 lda #$8f
 sta $2100
 rep #$20
 .ACCU 16
 lda #IntroLogoMap
 sta $88
 lda #2048
 sta $84
 ldx #$6000
 sep #$20
 .ACCU 8
 lda #ROMBANK_120
 sta $8a
 jsr IntroVRAM
 lda #3
 sta $1cda
 jsr IntroFadeIn
 ldx #LOGO_HOLD_FRAMES
IntroLogoHold:
 jsr WaitFrame
 dex
 beq P5Long_intro_3
 jmp IntroLogoHold
P5Long_intro_3:
 lda #6
 sta $1cda
 jsr IntroFadeOut
 jsr UISoundRelease
 bcc +
 lda #3
 sta $1cde
+:
 stz $1cda
 stz $1cdc
 jsr InitVideo
 rts
; Thunder remains empty. Match-start begins with the first visible logo frame.
IntroThunderCue:
 rts
IntroLogoCue:
 jmp UISoundLogo
IntroFadeOut:
 lda #15
 sta $1cdf
IntroFadeOutStep:
 jsr WaitFrame
 jsr WaitFrame
 dec $1cdf
 lda $1cdf
 sta $2100
 beq P5Long_intro_6
 jmp IntroFadeOutStep
P5Long_intro_6:
 rts
IntroFadeIn:
 stz $1cdf
IntroFadeInStep:
 jsr WaitFrame
 jsr WaitFrame
 inc $1cdf
 lda $1cdf
 sta $2100
 cmp #1
 bne +
 jsr IntroLogoCue
+:
 lda $1cdf
 cmp #15
 beq P5Long_intro_7
 jmp IntroFadeInStep
P5Long_intro_7:
 rts
IntroVideo:
 lda #$8f
 sta $2100
 stz $210e
 stz $210e
 lda #1
 sta $2105
 lda #$60
 sta $2107
 stz $210b
 stz $2121
 ldx #0
IntroPaletteLoop:
 lda.l IntroPalette,x
 sta $2122
 inx
 cpx #64
 beq P5Long_intro_4
 jmp IntroPaletteLoop
P5Long_intro_4:
 rep #$20
 .ACCU 16
 lda #IntroTiles
 sta $88
 lda #(IntroTilesEnd-IntroTiles)
 sta $84
 ldx #0
 sep #$20
 .ACCU 8
 lda #ROMBANK_120
 sta $8a
 jsr IntroVRAM
 rep #$20
 .ACCU 16
 lda #IntroNameMap
 sta $88
 lda #2048
 sta $84
 ldx #$6000
 sep #$20
 .ACCU 8
 jmp IntroVRAM
IntroVRAM:
 lda #$80
 sta $2115
 stx $2116
 lda #1
 sta $4300
 lda #$18
 sta $4301
 ldx $88
 stx $4302
 lda $8a
 sta $4304
 ldx $84
 stx $4305
 lda #1
 sta $420b
 rts
.include "present.asm"
