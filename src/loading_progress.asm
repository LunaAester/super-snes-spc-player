; Weighted completed work: SD sectors 0..45%, validation 50%, ARAM 50..98%,
; bootstrap acknowledgement 100%. No value is based on elapsed time.
LoadingReadProgress:
 php
 sep #$20
 .ACCU 8
 pha
 phx
 phy
 rep #$20
 .ACCU 16
 lda #129
 sec
 sbc $6a
 sta $4202
 sep #$20
 .ACCU 8
 lda #45
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
 lda #129
 sta $4206
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 lda $4214
 jsr LoadingSet
 ply
 plx
 pla
 plp
 rts
LoadingUploadProgress:
 php
 sep #$20
 .ACCU 8
 pha
 phx
 phy
 lda $1cd0
 bne P5Long_loading_progress_0
 jmp LoadingUploadExit
P5Long_loading_progress_0:
 rep #$20
 .ACCU 16
 tya
 and #$03ff
 beq P5Long_loading_progress_1
 jmp LoadingUploadExit16
P5Long_loading_progress_1:
 tya
 clc
 adc $86
 bcc P5Long_loading_progress_2
 jmp LoadingUploadMaximum
P5Long_loading_progress_2:
 xba
 sep #$20
 .ACCU 8
 sta $4202
 lda #49
 sta $4203
 nop
 nop
 nop
 nop
 lda $4217
 clc
 adc #50
 jsr LoadingSet
 jmp LoadingUploadExit
LoadingUploadMaximum:
 sep #$20
 .ACCU 8
 lda #98
 jsr LoadingSet
 jmp LoadingUploadExit
LoadingUploadExit16:
 sep #$20
 .ACCU 8
LoadingUploadExit:
 ply
 plx
 pla
 plp
 rts
LoadingSet:
 ; Caller enters A8, X/Y16. Preserve all registers and processor flags.
 sta $1cd4
 php
 pha
 phx
 phy
 lda $1cd0
 bne P5Long_loading_progress_3
 jmp LoadingSetExit
P5Long_loading_progress_3:
 lda $1cd4
 cmp $1cd1
 bne P5Long_loading_progress_4
 jmp LoadingSetExit
P5Long_loading_progress_4:
 bcs P5Long_loading_progress_5
 jmp LoadingSetExit
P5Long_loading_progress_5:
 sta $1cd1
 lda #1
 sta $1caa
 rep #$20
 .ACCU 16
 lda #2*(14*32+14)
 sta $1ca0
 sep #$20
 .ACCU 8
 lda #$10
 sta $1ca2
 rep #$20
 .ACCU 16
 lda $1cd1
 and #$00ff
 jsr HUDDecimal
 sep #$20
 .ACCU 8
 lda $1cd1
 sta $4202
 lda #26
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
 ldx #2*(12*32+3)
 stx $1ca0
 ldy #0
 nop
 nop
 nop
 nop
LoadingBarCell:
 rep #$20
 .ACCU 16
 tya
 cmp $4214
 sep #$20
 .ACCU 8
 lda #$10
 bcc P5Long_loading_progress_6
 jmp LoadingBarDim
P5Long_loading_progress_6:
 lda #$10
 jmp LoadingBarAttribute
LoadingBarDim:
 lda #$1c
LoadingBarAttribute:
 sta $1ca2
 lda #109
 jsr HUDTile
 iny
 cpy #26
 beq P5Long_loading_progress_7
 jmp LoadingBarCell
P5Long_loading_progress_7:
 jsr WaitFrame
 lda #$80
 sta $2115
 ldx #$2000+12*32
 stx $2116
 lda #1
 sta $4300
 lda #$18
 sta $4301
 ldx #$3000+12*64
 stx $4302
 lda #$7e
 sta $4304
 ldx #3*64
 stx $4305
 lda #1
 sta $420b
 stz $1caa
LoadingSetExit:
 ply
 plx
 pla
 plp
 rts
