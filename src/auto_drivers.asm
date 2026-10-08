; File-independent checks for supported executable drivers. $A0..$A5 are
; temporary long pointers. $1DB0..$1DDA are scratch after the presentation.
; BRR reservations use up to 260 eight-byte intervals at $7E4000.
AutoExactCRC:
 phx
 phy
 rep #$20
 .ACCU 16
 ldx $1c24
 lda.w AutoExactPointers,x
 sta $a0
 sep #$20
 .ACCU 8
 lda.w AutoExactPointers+2,x
 sta $a2
 rep #$20
 .ACCU 16
 ldy #0
 lda [$a0],y
 sta $1db2
 iny
 iny
AutoExactNext:
 lda [$a0],y
 cmp $1cf0
 beq P5Long_auto_drivers_0
 jmp AutoExactSkip
P5Long_auto_drivers_0:
 iny
 iny
 lda [$a0],y
 cmp $1cf2
 bne P5Long_auto_drivers_1
 jmp AutoExactOK
P5Long_auto_drivers_1:
 dey
 dey
AutoExactSkip:
 iny
 iny
 iny
 iny
 dec $1db2
 beq P5Long_auto_drivers_2
 jmp AutoExactNext
P5Long_auto_drivers_2:
 sep #$20
 .ACCU 8
 ply
 plx
 sec
 rts
AutoExactOK:
 sep #$20
 .ACCU 8
 ply
 plx
 clc
 rts

AutoDriverValidate:
 phx
 phy
 rep #$20
 .ACCU 16
 ldx $1c24
 lda.w AutoGuardPointers,x
 sta $a0
 sep #$20
 .ACCU 8
 lda.w AutoGuardPointers+2,x
 bne P5Long_auto_drivers_3
 jmp AutoDriverBad
P5Long_auto_drivers_3:
 sta $a2
 ldy #0
 lda.l $7e81f1
 and #$cf
 cmp [$a0],y
 beq P5Long_auto_drivers_4
 jmp AutoDriverBad
P5Long_auto_drivers_4:
 iny
 ldx #0
AutoTimerConfig:
 lda.l $7e81fa,x
 cmp [$a0],y
 beq P5Long_auto_drivers_5
 jmp AutoDriverBad
P5Long_auto_drivers_5:
 iny
 inx
 cpx #3
 beq P5Long_auto_drivers_6
 jmp AutoTimerConfig
P5Long_auto_drivers_6:
 lda.l $7e802a
 and #32
 cmp [$a0],y
 beq P5Long_auto_drivers_7
 jmp AutoDriverBad
P5Long_auto_drivers_7:
 iny
 rep #$20
 .ACCU 16
 lda [$a0],y
 sta $1db2
 iny
 iny
 lda [$a0],y
 sta $1db4
 iny
 iny
 lda [$a0],y
 sta $1dba
 iny
 iny
 lda [$a0],y
 sta $1dbc
 iny
 iny
 lda [$a0],y
 sta $1ddc
 iny
 iny
 lda [$a0],y
 sta $a3
 iny
 iny
 sep #$20
 .ACCU 8
 lda [$a0],y
.IFDEF HIROMBUILD
 pha
 lsr a
 clc
 adc #$c0
 sta $a5
 pla
 and #1
 beq +
 lda #$80
 ora $a4
 sta $a4
+:
.ELSE
 sta $a5
 lda $a4
 ora #$80
 sta $a4
.ENDIF
 stz $1dbe
 rep #$20
 .ACCU 16
 lda #$ffff
 sta $1db6
 sta $1db8
 sep #$20
 .ACCU 8
 ldy #0
AutoCodeNext:
 rep #$20
 .ACCU 16
 lda [$a3],y
 sta $1dc0
 iny
 iny
 sep #$20
 .ACCU 8
 lda [$a3],y
 bpl P5Long_auto_drivers_8
 jmp AutoCodeTable
P5Long_auto_drivers_8:
 rep #$20
 .ACCU 16
 lda $1dc0
 cmp.l $7e8025
 bne +
 sep #$20
 .ACCU 8
 lda #1
 sta $1dbe
+:
 sep #$20
 .ACCU 8
 lda [$a3],y
AutoCodeTable:
 and #$7f
 sta $1dbf
 iny
 rep #$20
 .ACCU 16
 lda $1dc0
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
AutoCodeByte:
 lda [$94]
 jsr AutoCRCByte
 rep #$20
 .ACCU 16
 inc $94
 sep #$20
 .ACCU 8
 bne +
 inc $96
+:
 dec $1dbf
 beq P5Long_auto_drivers_9
 jmp AutoCodeByte
P5Long_auto_drivers_9:
 rep #$20
 .ACCU 16
 dec $1db2
 sep #$20
 .ACCU 8
 beq P5Long_auto_drivers_10
 jmp AutoCodeNext
P5Long_auto_drivers_10:
 lda $1dbe
 bne P5Long_auto_drivers_11
 jmp AutoDriverBad
P5Long_auto_drivers_11:
 rep #$20
 .ACCU 16
 lda $1db6
 eor #$ffff
 cmp $1dba
 beq P5Long_auto_drivers_12
 jmp AutoDriverBad16
P5Long_auto_drivers_12:
 lda $1db8
 eor #$ffff
 cmp $1dbc
 beq P5Long_auto_drivers_13
 jmp AutoDriverBad16
P5Long_auto_drivers_13:
 sep #$20
 .ACCU 8
 lda $1db1
 bne +
 jsr AutoBuildOccupied
+:
 ldy #18
AutoReservationNext:
 rep #$20
 .ACCU 16
 lda [$a0],y
 sta $1dd4
 iny
 iny
 lda [$a0],y
 dec a
 clc
 adc $1dd4
 sta $1dd6
 iny
 iny
 jsr AutoRangeCollision
 bcc P5Long_auto_drivers_14
 jmp AutoDriverBad16
P5Long_auto_drivers_14:
 dec $1db4
 beq P5Long_auto_drivers_15
 jmp AutoReservationNext
P5Long_auto_drivers_15:
 sep #$20
 .ACCU 8
 ply
 plx
 clc
 rts
AutoDriverBad16:
 sep #$20
 .ACCU 8
AutoDriverBad:
 ply
 plx
 sec
 rts

; Update reflected zlib CRC32 for one byte, leaving the layout iterator Y.
AutoCRCByte:
 eor $1db6
 rep #$20
 .ACCU 16
 and #$00ff
 asl a
 asl a
 tax
 lda $1db6
 xba
 and #$00ff
 sta $1dd2
 lda $1db8
 xba
 and #$ff00
 ora $1dd2
 eor.w ControlCRCTable,x
 sta $1db6
 lda $1db8
 xba
 and #$00ff
 eor.w ControlCRCTable+2,x
 sta $1db8
 sep #$20
 .ACCU 8
 rts

AutoBuildOccupied:
 phy
 rep #$20
 .ACCU 16
 stz $1dc2
 stz $1dc8
 lda #1024
 sta $1dc6
 lda #$ffff
 sta $1dd8
 lda.l $7f815d
 and #$00ff
 xba
 sta $1dc4
 sta $1dd4
 lda #1024
 jsr AutoAddWrapped
 lda.l $7f816d
 and #$00ff
 xba
 sta $1dd4
 lda.l $7f817d
 and #15
 xba
 asl a
 asl a
 asl a
 bne +
 lda #4
+:
 jsr AutoAddWrapped
AutoDirectoryNext:
 lda $1dc4
 clc
 adc $1dc8
 cmp #$fffd
 bcc P5Long_auto_drivers_16
 jmp AutoDirectorySkip
P5Long_auto_drivers_16:
 jsr ControlRAMPointer
 lda [$94]
 cmp #$0200
 bcs P5Long_auto_drivers_17
 jmp AutoDirectorySkip
P5Long_auto_drivers_17:
 cmp #$fff7
 bcc P5Long_auto_drivers_18
 jmp AutoDirectorySkip
P5Long_auto_drivers_18:
 sta $1dca
 sta $1dce
 ldy #2
 lda [$94],y
 sta $1dcc
AutoBRRNext:
 lda $1dce
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 lda [$94]
 sta $1dd0
 and #1
 beq P5Long_auto_drivers_19
 jmp AutoBRREnd
P5Long_auto_drivers_19:
 rep #$20
 .ACCU 16
 lda $1dce
 clc
 adc #9
 bcc P5Long_auto_drivers_20
 jmp AutoDirectorySkip
P5Long_auto_drivers_20:
 cmp #$fff7
 bcc P5Long_auto_drivers_21
 jmp AutoDirectorySkip
P5Long_auto_drivers_21:
 sta $1dce
 jmp AutoBRRNext
AutoBRREnd:
 .ACCU 8
 lda $1dd0
 and #2
 bne P5Long_auto_drivers_22
 jmp AutoBRRValid
P5Long_auto_drivers_22:
 rep #$20
 .ACCU 16
 lda $1dcc
 cmp $1dca
 bcs P5Long_auto_drivers_23
 jmp AutoDirectorySkip
P5Long_auto_drivers_23:
 cmp $1dce
 bcc +
 beq +
 jmp AutoDirectorySkip
+:
 sec
 sbc $1dca
 sta $4204
 sep #$20
 .ACCU 8
 lda #9
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
 lda $4216
 beq P5Long_auto_drivers_24
 jmp AutoDirectorySkip
P5Long_auto_drivers_24:
AutoBRRValid:
 rep #$20
 .ACCU 16
 lda $1dca
 sta $1dd4
 sec
 sbc $1dc4
 cmp #4
 bcc +
 cmp $1dc6
 bcs +
 sta $1dc6
+:
 lda $1dce
 clc
 adc #8
 sta $1dd6
 lda $1dc8
 sta $1dd8
 jsr AutoAddRange
AutoDirectorySkip:
 rep #$20
 .ACCU 16
 lda $1dc8
 clc
 adc #4
 sta $1dc8
 cmp #1024
 bcs P5Long_auto_drivers_25
 jmp AutoDirectoryNext
P5Long_auto_drivers_25:
 sep #$20
 .ACCU 8
 lda #1
 sta $1db1
 ply
 rts

; A is the length, $1DD4 is start, $1DD8 directory slot or FFFF for echo/DIR.
AutoAddWrapped:
 .ACCU 16
 dec a
 clc
 adc $1dd4
 sta $1dd6
 bcs P5Long_auto_drivers_26
 jmp AutoAddRange
P5Long_auto_drivers_26:
 pha
 lda #$ffff
 sta $1dd6
 jsr AutoAddRange
 stz $1dd4
 pla
 sta $1dd6
AutoAddRange:
 lda $1dc2
 asl a
 asl a
 asl a
 tax
 lda $1dd4
 sta.l $7e4000,x
 lda $1dd6
 sta.l $7e4002,x
 lda $1dd8
 sta.l $7e4004,x
 inc $1dc2
 rts

AutoRangeCollision:
 .ACCU 16
 ldx #0
 stz $1dda
AutoRangeNext:
 lda.l $7e4004,x
 cmp #$ffff
 bne P5Long_auto_drivers_27
 jmp AutoRangeCompare
P5Long_auto_drivers_27:
 cmp $1dc6
 bcc P5Long_auto_drivers_28
 jmp AutoRangeSkip
P5Long_auto_drivers_28:
AutoRangeCompare:
 lda.l $7e4000,x
 cmp $1dd6
 bcc +
 beq +
 jmp AutoRangeSkip
+:
 lda.l $7e4002,x
 cmp $1dd4
 bcc P5Long_auto_drivers_29
 jmp AutoRangeBad
P5Long_auto_drivers_29:
AutoRangeSkip:
 txa
 clc
 adc #8
 tax
 inc $1dda
 lda $1dda
 cmp $1dc2
 bcs P5Long_auto_drivers_30
 jmp AutoRangeNext
P5Long_auto_drivers_30:
 clc
 rts
AutoRangeBad:
 sec
 rts

AutoRefreshInputs:
 .ACCU 8
 lda $1db0
 bne P5Long_auto_drivers_31
 jmp AutoRefreshDone
P5Long_auto_drivers_31:
 rep #$20
 .ACCU 16
 lda $1ddc
 bne P5Long_auto_drivers_32
 jmp AutoRefreshDone16
P5Long_auto_drivers_32:
 jsr ControlRAMPointer
 sep #$20
 .ACCU 8
 ldx #0
 ldy #0
AutoRefreshByte:
 lda $1c30,x
 sta [$94],y
 inx
 iny
 cpx #4
 beq P5Long_auto_drivers_33
 jmp AutoRefreshByte
P5Long_auto_drivers_33:
AutoRefreshDone16:
 sep #$20
 .ACCU 8
AutoRefreshDone:
 rts

.include "auto_guard_pointers.inc"
.include "auto_exact_pointers.inc"
.ACCU 8
