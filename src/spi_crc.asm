SPIByte:
  ; Both pre- and post-transfer waits are bounded. Preserve caller X and Y.
  sta $01
  phy
  ldy #$1000
SPIBefore:
.IFDEF MOCK
  jsr MockReadState
.ELSE
  lda.l $003004
.ENDIF
  and #$80
  bne SPIWrite
  dey
  bne SPIBefore
  bra SPITimeout
SPIWrite:
  lda $01
.IFDEF MOCK
  jsr MockWriteData
.ELSE
  sta.l $003001
.ENDIF
  ldy #$1000
SPIAfter:
.IFDEF MOCK
  jsr MockReadState
.ELSE
  lda.l $003004
.ENDIF
  and #$80
  bne SPIRead
  dey
  bne SPIAfter
SPITimeout:
  ply
  lda #$ff
  sec
  rts
SPIRead:
.IFDEF MOCK
  jsr MockReadData
.ELSE
  lda.l $003001
.ENDIF
  ply
  clc
  rts

.IFDEF MOCK
; Register-level fixture: bit 4 stays high while bit 7 remains low for three
; status polls after every write. An early read sets the test failure latch.
; Thus the real SPI wait loops, command/parser and CRC code are all exercised.
MockReadState:
  lda $0b
  beq MockReady
  dec $0b
  rep #$20
  .ACCU 16
  inc $32
  sep #$20
  .ACCU 8
  lda #$78
  rts
MockReady:
  lda #$f8
  rts
MockWriteData:
  phx
  ldx $04
  cmp.w MockStream,x
  beq MockExpected
  lda #$01
  sta $0c
MockExpected:
  lda.w MockStream+1,x
  sta $0d
  inx
  inx
  stx $04
  plx
  lda #$03
  sta $0b
  rts
MockReadData:
  lda $0b
  beq MockDataReady
  lda #$01
  sta $0c
  lda #$ff
  rts
MockDataReady:
  lda $0d
  rts
.ENDIF

; CRC-16/CCITT, polynomial 0x1021, initial 0, over all 512 received bytes.
CRC16:
  phx
  phy
  rep #$20
  .ACCU 16
  stz $08
  ldx #$0000
CRCByte:
  lda $0200,x
  and #$00ff
  xba
  eor $08
  ldy #$0008
CRCBit:
  asl a
  bcc CRCNext
  eor #$1021
CRCNext:
  dey
  bne CRCBit
  sta $08
  inx
  cpx #$0200
  bne CRCByte
  sep #$20
  .ACCU 8
  ply
  plx
  rts

