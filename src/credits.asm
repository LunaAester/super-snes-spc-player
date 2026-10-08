; Modal native HUD. Audio polling continues; no song is stopped to show credits.
CreditsToggle:
 sep #$20
 .ACCU 8
 lda $1ced
 eor #1
 sta $1ced
 beq P5Long_credits_0
 jmp CreditsOpen
P5Long_credits_0:
 jsr InitVideo
 jmp P5NoButton
CreditsOpen:
 jsr DrawCredits
 jmp GameLoop
CreditsLoop:
 rep #$20
 .ACCU 16
 lda $72
 bit #$8000
 beq P5Long_credits_1
 jmp CreditsClose
P5Long_credits_1:
 lda $70
 and #$1040
 cmp #$1040
 beq P5Long_credits_2
 jmp CreditsPoll
P5Long_credits_2:
 lda $72
 and #$1040
 beq P5Long_credits_3
 jmp CreditsClose
P5Long_credits_3:
CreditsPoll:
 sep #$20
 .ACCU 8
 jsr ControlMeter
 bcc P5Long_credits_4
 jmp CreditsError
P5Long_credits_4:
 jsr V13Poll
 bcc P5Long_credits_5
 jmp CreditsError
P5Long_credits_5:
 jsr WaitFrame
 jmp GameLoop
CreditsClose:
 sep #$20
 .ACCU 8
 stz $1ced
 jsr InitVideo
 jmp P5NoButton
CreditsError:
 stz $1ced
 jsr InitVideo
 jmp P5Error
DrawCredits:
 lda #$8f
 sta $2100
 rep #$20
 .ACCU 16
 lda #CreditsTiles
 sta $88
 lda #(CreditsTilesEnd-CreditsTiles)
 sta $84
 ldx #(136*8)
 sep #$20
 .ACCU 8
 lda #ROMBANK_126
 sta $8a
 jsr IntroVRAM
 stz $2121
 ldx #0
CreditsPaletteCopy:
 lda.l CreditsPalette,x
 sta $2122
 inx
 cpx #64
 beq P5Long_credits_6
 jmp CreditsPaletteCopy
P5Long_credits_6:
 rep #$20
 .ACCU 16
 lda #CreditsMap
 sta $88
 lda #2048
 sta $84
 ldx #$2000
 sep #$20
 .ACCU 8
 jsr IntroVRAM
 lda #$0f
 sta $2100
 rts

