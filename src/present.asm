; Two VBlanks per animation frame: tiles into the hidden character buffer,
; then map/palette plus the buffer switch. No visible VRAM is overwritten.
; $1d60 table offset; $1d62 frame index; $1d64 hidden character-base selector.
PresentVideo:
 lda #$8f
 sta $2100
 stz $2105
 stz $210b
 ; Align asset row zero with the first visible SNES scanline.
 lda #$ff
 sta $210e
 sta $210e
 lda #$60
 sta $2107
 rep #$20
 .ACCU 16
 stz $1d60
 stz $1d62
 sep #$20
 .ACCU 8
 stz $1d64
 jsr PresentTiles
 jsr PresentMap
 rts
PresentAnimation:
 rep #$20
 .ACCU 16
 lda $1d62
 inc a
 sta $1d62
 cmp #PRESENT_FRAME_COUNT
 bcs PresentAnimationDone
 lda $1d60
 clc
 adc #9
 sta $1d60
 sep #$20
 .ACCU 8
 lda $1d64
 eor #2
 sta $1d64
 jsr WaitFrame
 jsr PresentTiles
 jsr WaitFrame
 jsr PresentMap
 jmp PresentAnimation
PresentAnimationDone:
 sep #$20
 .ACCU 8
 rts
PresentTiles:
 rep #$20
 .ACCU 16
 ldx $1d60
 lda.w PresentFrames,x
 sta $88
 lda.w PresentFrames+3,x
 sta $84
 sep #$20
 .ACCU 8
 lda.w PresentFrames+2,x
 sta $8a
 lda $1d64
 beq PresentTilesZero
 ldx #$2000
 jmp IntroVRAM
PresentTilesZero:
 ldx #0
 jmp IntroVRAM
PresentMap:
 rep #$20
 .ACCU 16
 ldx $1d60
 lda.w PresentFrames+5,x
 sta $88
 lda #2048
 sta $84
 sep #$20
 .ACCU 8
 lda.w PresentFrames+2,x
 sta $8a
 lda $1d64
 beq PresentMapZero
 ldx #$6400
 bra PresentMapUpload
PresentMapZero:
 ldx #$6000
PresentMapUpload:
 jsr IntroVRAM
 rep #$20
 .ACCU 16
 ldx $1d60
 lda.w PresentFrames+7,x
 sta $88
 sep #$20
 .ACCU 8
 stz $2121
 ldy #0
PresentPalette:
 lda [$88],y
 sta $2122
 iny
 cpy #8
 bne PresentPalette
 lda $1d64
 sta $210b
 beq PresentMapSelectZero
 lda #$64
 sta $2107
 rts
PresentMapSelectZero:
 lda #$60
 sta $2107
 rts
.include "present_frames.inc"
