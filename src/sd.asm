; $20 LBA, $43 SDHC, sector at $0200.
.include "sd_init.asm"

ReadSector:
.IFDEF TESTFS
 jmp MockReadSector
.ELSE
 COPY32 $50,$20
 lda $43
 beq LongBranch_sd_3
 jmp AddressReady
LongBranch_sd_3:
 ldx #9
AddressShift:
 rep #$20
 .ACCU 16
 asl $50
 rol $52
 sep #$20
 .ACCU 8
 dex
 beq LongBranch_sd_4
 jmp AddressShift
LongBranch_sd_4:
AddressReady:
 lda #$51
 sta $1800
 lda $53
 sta $1801
 lda $52
 sta $1802
 lda $51
 sta $1803
 lda $50
 sta $1804
 jsr SendCommand
 bcc LongBranch_sd_5
 jmp SDReturn
LongBranch_sd_5:
 cmp #0
 bne LongBranch_sd_6
 jmp TokenBegin
LongBranch_sd_6:
 lda #$14
 jmp SDFail
TokenBegin:
 ldy #$1000
TokenPoll:
 lda #$ff
 jsr SPIByte
 bcc LongBranch_sd_7
 jmp SDTimeout
LongBranch_sd_7:
 cmp #$fe
 bne LongBranch_sd_8
 jmp SectorBegin
LongBranch_sd_8:
 cmp #$ff
 bne LongBranch_sd_9
 jmp TokenNext
LongBranch_sd_9:
 cmp #0
 bne LongBranch_sd_10
 jmp TokenNext
LongBranch_sd_10:
 lda #$16
 jmp SDFail
TokenNext:
 dey
 beq LongBranch_sd_11
 jmp TokenPoll
LongBranch_sd_11:
 lda #$15
 jmp SDFail
SectorBegin:
 ldy #0
SDBytes:
 lda #$ff
 jsr SPIByte
 bcc LongBranch_sd_12
 jmp SDTimeout
LongBranch_sd_12:
 sta $0200,y
 iny
 cpy #512
 beq LongBranch_sd_13
 jmp SDBytes
LongBranch_sd_13:
 lda #$ff
 jsr SPIByte
 bcc LongBranch_sd_14
 jmp SDTimeout
LongBranch_sd_14:
 sta $58
 lda #$ff
 jsr SPIByte
 bcc LongBranch_sd_15
 jmp SDTimeout
LongBranch_sd_15:
 sta $59
 jsr SDRelease
 jsr CRC16
 lda $09
 cmp $58
 beq LongBranch_sd_16
 jmp CRCFailure
LongBranch_sd_16:
 lda $08
 cmp $59
 beq LongBranch_sd_17
 jmp CRCFailure
LongBranch_sd_17:
 clc
 rts
CRCFailure:
 lda #$03
 jmp SDFail
.ENDIF
SDTimeout:
 lda #$10
SDFail:
 sta $4d
 jsr SDRelease
 sec
SDReturn:
 rts

SendCommand:
 lda #$ff
 sta $1825
 ; CRC7 over command byte and 32-bit argument; handles CRC-enabled cards too.
 stz $06
 ldx #0
CRC7Byte:
 lda $1800,x
 sta $07
 ldy #8
CRC7Bit:
 lda $06
 asl a
 eor $07
 and #$80
 sta $0a
 asl $06
 lda $0a
 bne LongBranch_sd_18
 jmp CRC7NoXor
LongBranch_sd_18:
 lda $06
 eor #$09
 sta $06
CRC7NoXor:
 asl $07
 dey
 beq LongBranch_sd_19
 jmp CRC7Bit
LongBranch_sd_19:
 inx
 cpx #5
 beq LongBranch_sd_20
 jmp CRC7Byte
LongBranch_sd_20:
 lda $06
 asl a
 ora #1
 sta $1805
 ; Finish any previous card response before asserting selection again.
 jsr SDRelease
 bcc +
 jmp CommandTimeout
+:
 lda #1
 sta.l $003002
 lda #$ff
 jsr SPIByte
 bcc LongBranch_sd_21
 jmp CommandTimeout
LongBranch_sd_21:
 ldx #0
CommandOut:
 lda $1800,x
 jsr SPIByte
 bcc LongBranch_sd_22
 jmp CommandTimeout
LongBranch_sd_22:
 inx
 cpx #6
 beq LongBranch_sd_23
 jmp CommandOut
LongBranch_sd_23:
 ldy #32
CommandResponse:
 lda #$ff
 jsr SPIByte
 bcc LongBranch_sd_24
 jmp CommandTimeout
LongBranch_sd_24:
 sta $1825
 cmp #$80
 bcs LongBranch_sd_25
 jmp CommandOK
LongBranch_sd_25:
 dey
 beq LongBranch_sd_26
 jmp CommandResponse
LongBranch_sd_26:
 lda #$11
 jmp SDFail
CommandTimeout:
 jmp SDTimeout
CommandOK:
 clc
 rts
SDRelease:
 lda #0
 sta.l $003002
 lda #$ff
 jsr SPIByte
 rts

; SPIByte and CRC16 below are generated from the physically validated V2.
.include "spi_crc.asm"
