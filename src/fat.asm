; FAT32, 512-byte sectors, first primary 0B/0C partition or direct VBR.
; Read-only traversal of directory and file cluster chains, including fragmentation.
Mount:
 rep #$20
 .ACCU 16
 stz $20
 stz $22
 sep #$20
 .ACCU 8
 jsr SDInit
 bcc +
 rts
+:
 rep #$20
 .ACCU 16
 stz $20
 stz $22
 stz $24
 stz $26
 sep #$20
 .ACCU 8
 SDTRY
 jsr CheckSignature
 bcc +
 rts
+:
 rep #$20
 .ACCU 16
 lda $020b
 cmp #512
 sep #$20
 .ACCU 8
 bne LongBranch_fat_0
 jmp BootRecord
LongBranch_fat_0:
 ldx #446
FindPartition:
 lda $0204,x
 cmp #$0b
 bne LongBranch_fat_1
 jmp PartitionFound
LongBranch_fat_1:
 cmp #$0c
 bne LongBranch_fat_2
 jmp PartitionFound
LongBranch_fat_2:
 rep #$20
 .ACCU 16
 txa
 clc
 adc #16
 tax
 sep #$20
 .ACCU 8
 cpx #510
 beq LongBranch_fat_3
 jmp FindPartition
LongBranch_fat_3:
 lda #$21
 jmp FSError
PartitionFound:
 rep #$20
 .ACCU 16
 lda $0208,x
 sta $20
 sta $24
 lda $020a,x
 sta $22
 sta $26
 sep #$20
 .ACCU 8
 SDTRY
BootRecord:
 jsr CheckSignature
 bcc +
 rts
+:
 rep #$20
 .ACCU 16
 lda $020b
 cmp #512
 beq LongBranch_fat_4
 jmp BadBPB16
LongBranch_fat_4:
 lda $0211
 ora $0216
 ora $022a
 beq LongBranch_fat_5
 jmp BadBPB16
LongBranch_fat_5:
 lda $020e
 bne LongBranch_fat_6
 jmp BadBPB16
LongBranch_fat_6:
 sta $50
 stz $52
 lda $0224
 sta $5a
 lda $0226
 sta $5c
 ora $5a
 bne LongBranch_fat_7
 jmp BadBPB16
LongBranch_fat_7:
 lda $022c
 sta $30
 lda $022e
 and #$0fff
 sta $32
 lda $0220
 sta $1814
 lda $0222
 sta $1816
 sep #$20
 .ACCU 8
 lda $020d
 bne LongBranch_fat_8
 jmp BadBPB
LongBranch_fat_8:
 sta $40
 dec a
 and $40
 beq LongBranch_fat_9
 jmp BadBPB
LongBranch_fat_9:
 lda $0210
 bne LongBranch_fat_10
 jmp BadBPB
LongBranch_fat_10:
 cmp #3
 bcc LongBranch_fat_11
 jmp BadBPB
LongBranch_fat_11:
 sta $41
 sta $1818
 stz $1819
 lda $40
 stz $42
SPCShift:
 cmp #1
 bne LongBranch_fat_12
 jmp Geometry
LongBranch_fat_12:
 lsr a
 inc $42
 jmp SPCShift
BadBPB16:
 sep #$20
 .ACCU 8
BadBPB:
 lda #$22
 jmp FSError
Geometry:
 COPY32 $28,$24
 ADD32 $28,$50
 COPY32 $2c,$28
 lda $41
 sta $0c
FATRegion:
 ADD32 $2c,$5a
 dec $0c
 beq LongBranch_fat_13
 jmp FATRegion
LongBranch_fat_13:
 ; Non-mirrored FAT32 volumes may select the second FAT.
 rep #$20
 .ACCU 16
 lda $0228
 and #$0080
 bne LongBranch_fat_14
 jmp FATSelected16
LongBranch_fat_14:
 lda $0228
 and #$000f
 cmp $1818
 bcc LongBranch_fat_15
 jmp BadBPB16
LongBranch_fat_15:
 sep #$20
 .ACCU 8
 sta $0c
 bne LongBranch_fat_16
 jmp FATSelected
LongBranch_fat_16:
ActiveFAT:
 ADD32 $28,$5a
 dec $0c
 beq LongBranch_fat_17
 jmp ActiveFAT
LongBranch_fat_17:
 jmp FATSelected
FATSelected16:
 sep #$20
 .ACCU 8
FATSelected:
 ; Cluster count = (total sectors - reserved - all FAT sectors) >> log2(SPC).
 rep #$20
 .ACCU 16
 sec
 lda $2c
 sbc $24
 sta $50
 lda $2e
 sbc $26
 sta $52
 sec
 lda $1814
 sbc $50
 sta $5e
 lda $1816
 sbc $52
 sta $60
 bcs LongBranch_fat_18
 jmp BadGeometry16
LongBranch_fat_18:
 sep #$20
 .ACCU 8
 lda $42
 bne LongBranch_fat_19
 jmp CountReady
LongBranch_fat_19:
 rep #$20
 .ACCU 16
 and #$00ff
 tax
 sep #$20
 .ACCU 8
CountShift:
 rep #$20
 .ACCU 16
 lsr $60
 ror $5e
 sep #$20
 .ACCU 8
 dex
 beq LongBranch_fat_20
 jmp CountShift
LongBranch_fat_20:
CountReady:
 rep #$20
 .ACCU 16
 lda $60
 beq LongBranch_fat_21
 jmp EnoughClusters
LongBranch_fat_21:
 lda $5e
 cmp #65525
 bcs LongBranch_fat_22
 jmp BadGeometry16
LongBranch_fat_22:
EnoughClusters:
 inc $5e
 bne +
 inc $60
+:
 sep #$20
 .ACCU 8
 COPY32 $38,$30
 jsr ValidateCluster
 rts
BadGeometry16:
 sep #$20
 .ACCU 8
 lda #$23
 jmp FSError
CheckSignature:
 rep #$20
 .ACCU 16
 lda $03fe
 cmp #$aa55
 sep #$20
 .ACCU 8
 bne LongBranch_fat_23
 jmp SignatureOK
LongBranch_fat_23:
 lda #$20
 jmp FSError
SignatureOK:
 clc
 rts
FSError:
 sta $4d
 sec
 rts
ValidateCluster:
 rep #$20
 .ACCU 16
 lda $3a
 cmp $60
 bcs LongBranch_fat_24
 jmp ClusterUpperOK
LongBranch_fat_24:
 beq LongBranch_fat_25
 jmp BadCluster16
LongBranch_fat_25:
 lda $38
 cmp $5e
 bcs LongBranch_fat_26
 jmp ClusterUpperOK
LongBranch_fat_26:
 bne LongBranch_fat_27
 jmp ClusterUpperOK
LongBranch_fat_27:
 jmp BadCluster16
ClusterUpperOK:
 .ACCU 16
 lda $3a
 beq LongBranch_fat_28
 jmp ValidCluster16
LongBranch_fat_28:
 lda $38
 cmp #2
 bcs LongBranch_fat_29
 jmp BadCluster16
LongBranch_fat_29:
ValidCluster16:
 sep #$20
 .ACCU 8
 clc
 rts
BadCluster16:
 sep #$20
 .ACCU 8
 lda #$31
 jmp FSError
ClusterSector:
 jsr ValidateCluster
 bcc +
 rts
+:
 COPY32 $20,$38
 rep #$20
 .ACCU 16
 sec
 lda $20
 sbc #2
 sta $20
 lda $22
 sbc #0
 sta $22
 sep #$20
 .ACCU 8
 lda $42
 bne LongBranch_fat_30
 jmp ClusterAdd
LongBranch_fat_30:
 rep #$20
 .ACCU 16
 and #$00ff
 tax
 sep #$20
 .ACCU 8
ClusterScale:
 rep #$20
 .ACCU 16
 asl $20
 rol $22
 sep #$20
 .ACCU 8
 dex
 beq LongBranch_fat_31
 jmp ClusterScale
LongBranch_fat_31:
ClusterAdd:
 ADD32 $20,$2c
 clc
 rts
NextCluster:
 COPY32 $20,$38
 ldx #7
FATIndex:
 rep #$20
 .ACCU 16
 lsr $22
 ror $20
 sep #$20
 .ACCU 8
 dex
 beq LongBranch_fat_32
 jmp FATIndex
LongBranch_fat_32:
 ADD32 $20,$28
 rep #$20
 .ACCU 16
 lda $38
 and #127
 asl a
 asl a
 sta $54
 sep #$20
 .ACCU 8
 SDTRY
 ldx $54
 rep #$20
 .ACCU 16
 lda $0200,x
 sta $3c
 lda $0202,x
 and #$0fff
 sta $3e
 sep #$20
 .ACCU 8
 clc
 rts
IncrementLBA:
 rep #$20
 .ACCU 16
 inc $20
 bne +
 inc $22
+:
 sep #$20
 .ACCU 8
 rts

ListDirectory:
 rep #$20
 .ACCU 16
 stz $44
 stz $46
 stz $48
 stz $4e
 sep #$20
 .ACCU 8
 jsr TitleDirectoryReset
 COPY32 $38,$34
DirectoryCluster:
 jsr ClusterSector
 bcc +
 rts
+:
 stz $4c
DirectorySector:
 SDTRY
 rep #$20
 .ACCU 16
 inc $4e
 lda $4e
 cmp #1025
 bcc +
 sep #$20
 .ACCU 8
 lda #$32
 jmp FSError
+:
 stz $56
 sep #$20
 .ACCU 8
DirectoryEntry:
 ldy $56
 lda $0200,y
 bne +
 jmp DirectoryDone
+:
 lda $020b,y
 cmp #$0f
 bne +
 jsr LFNEntry
 jmp SkipEntry
+:
 lda $0200,y
 bne LongBranch_fat_33
 jmp DirectoryDone
LongBranch_fat_33:
 cmp #$e5
 bne LongBranch_fat_34
 jmp SkipShortEntry
LongBranch_fat_34:
 cmp #$2e
 bne LongBranch_fat_35
 jmp SkipShortEntry
LongBranch_fat_35:
 lda $020b,y
 and #$0e
 beq LongBranch_fat_36
 jmp SkipShortEntry
LongBranch_fat_36:
 lda $020b,y
 and #$10
 beq LongBranch_fat_37
 jmp SaveEntry
LongBranch_fat_37:
 lda $0208,y
 cmp #$53
 beq LongBranch_fat_38
 jmp SkipShortEntry
LongBranch_fat_38:
 lda $0209,y
 cmp #$50
 beq LongBranch_fat_39
 jmp SkipShortEntry
LongBranch_fat_39:
 lda $020a,y
 cmp #$43
 beq LongBranch_fat_40
 jmp SkipShortEntry
LongBranch_fat_40:
SaveEntry:
 rep #$20
 .ACCU 16
 lda $44
 cmp #96
 bcc LongBranch_fat_41
 jmp DirectoryDone16
LongBranch_fat_41:
 sep #$20
 .ACCU 8
 jsr TitleSaveEntry
 rep #$20
 .ACCU 16
 lda $44
 asl a
 asl a
 asl a
 asl a
 asl a
 tax
 inc $44
 sep #$20
 .ACCU 8
 lda #32
 sta $0c
CopyEntry:
 lda $0200,y
 sta $0800,x
 iny
 inx
 dec $0c
 beq LongBranch_fat_42
 jmp CopyEntry
LongBranch_fat_42:
 jmp SkipEntry
SkipShortEntry:
 jsr TitleReset
SkipEntry:
 rep #$20
 .ACCU 16
 lda $56
 clc
 adc #32
 sta $56
 cmp #512
 sep #$20
 .ACCU 8
 beq LongBranch_fat_43
 jmp DirectoryEntry
LongBranch_fat_43:
 inc $4c
 lda $4c
 cmp $40
 bne LongBranch_fat_44
 jmp DirectoryFAT
LongBranch_fat_44:
 jsr IncrementLBA
 jmp DirectorySector
DirectoryFAT:
 jsr NextCluster
 bcc +
 rts
+:
 rep #$20
 .ACCU 16
 lda $3e
 cmp #$0fff
 beq LongBranch_fat_45
 jmp ContinueDirectory16
LongBranch_fat_45:
 lda $3c
 cmp #$fff8
 bcc LongBranch_fat_46
 jmp DirectoryDone16
LongBranch_fat_46:
ContinueDirectory16:
 sep #$20
 .ACCU 8
 COPY32 $38,$3c
 jmp DirectoryCluster
DirectoryDone16:
 sep #$20
 .ACCU 8
DirectoryDone:
 clc
 rts

Activate:
 rep #$20
 .ACCU 16
 lda $44
 bne +
 sep #$20
 .ACCU 8
 clc
 rts
+:
 rep #$20
 .ACCU 16
 lda $46
 asl a
 asl a
 asl a
 asl a
 asl a
 tax
 stx $74
 lda $081a,x
 sta $62
 lda $0814,x
 and #$0fff
 sta $64
 lda $081c,x
 sta $66
 lda $081e,x
 sta $68
 sep #$20
 .ACCU 8
 lda $080b,x
 and #$10
 bne LongBranch_fat_47
 jmp ActivateFile
LongBranch_fat_47:
 rep #$20
 .ACCU 16
 lda $4a
 cmp #15
 bcc LongBranch_fat_48
 jmp TooDeep16
LongBranch_fat_48:
 inc $4a
 lda $4a
 asl a
 asl a
 asl a
 asl a
 tay
 lda $62
 sta $0600,y
 lda $64
 sta $0602,y
 sep #$20
 .ACCU 8
 lda #11
 sta $0c
CopyFolderName:
 lda $0800,x
 sta $0604,y
 inx
 iny
 dec $0c
 beq LongBranch_fat_49
 jmp CopyFolderName
LongBranch_fat_49:
 COPY32 $34,$62
 jmp ListDirectory
TooDeep16:
 sep #$20
 .ACCU 8
 lda #$33
 jmp FSError
ActivateFile:
 stz $1cec
 jsr UISoundRelease
 bcc +
 lda #$53
 jmp FSError
+:
 lda $8f
 beq +
 jsr StopAPU
 bcc +
 rts
+:
 jsr APUEnsureIPL
 bcc +
 lda #$51
 jmp FSError
+:
 ldx $74
 ldy #0
P5SaveSongName:
 lda $0800,x
 sta $1d00,y
 inx
 iny
 cpy #11
 beq P5Long_fat_0
 jmp P5SaveSongName
P5Long_fat_0:
 jsr TitleSavePlaying
 jsr DrawLoading
 jsr ReadFile
 bcc +
 rts
+:
 jsr ValidateSPC
 bcc +
 rts
+:
 lda #50
 jsr LoadingSet
 jsr DispatchLoadAPU
 bcc P5Long_fat_3
 jmp ActivateLoadFailed
P5Long_fat_3:
 lda #100
 jsr LoadingSet
 stz $1cd0
 clc
ActivateLoadFailed:
 rts
Back:
 jmp BackFolder
BackFolder:
 rep #$20
 .ACCU 16
 lda $4a
 bne LongBranch_fat_51
 jmp BackAtRoot16
LongBranch_fat_51:
 dec $4a
 lda $4a
 asl a
 asl a
 asl a
 asl a
 tay
 lda $0600,y
 sta $34
 lda $0602,y
 sta $36
 sep #$20
 .ACCU 8
 jmp ListDirectory
BackAtRoot16:
 sep #$20
 .ACCU 8
 clc
 rts

ReadFile:
 rep #$20
 .ACCU 16
 lda $68
 cmp #1
 bcs LongBranch_fat_52
 jmp FileSmall16
LongBranch_fat_52:
 beq LongBranch_fat_53
 jmp FileSizeOK16
LongBranch_fat_53:
 lda $66
 cmp #$0200
 bcs LongBranch_fat_54
 jmp FileSmall16
LongBranch_fat_54:
FileSizeOK16:
 lda #$8000
 sta $80
 lda #129
 sta $6a
 sep #$20
 .ACCU 8
 lda #$7e
 sta $82
 COPY32 $38,$62
FileCluster:
 jsr ClusterSector
 bcc +
 rts
+:
 stz $6c
FileSector:
 SDTRY
 ldy #0
FileCopy:
 lda $0200,y
 sta [$80],y
 iny
 cpy #512
 beq LongBranch_fat_55
 jmp FileCopy
LongBranch_fat_55:
 rep #$20
 .ACCU 16
 lda $80
 clc
 adc #512
 sta $80
 sep #$20
 .ACCU 8
 bcc +
 inc $82
+:
 rep #$20
 .ACCU 16
 dec $6a
 sep #$20
 .ACCU 8
 jsr LoadingReadProgress
 bne LongBranch_fat_56
 jmp FileComplete
LongBranch_fat_56:
 inc $6c
 lda $6c
 cmp $40
 bne LongBranch_fat_57
 jmp FileFAT
LongBranch_fat_57:
 jsr IncrementLBA
 jmp FileSector
FileFAT:
 jsr NextCluster
 bcc +
 rts
+:
 rep #$20
 .ACCU 16
 lda $3e
 cmp #$0fff
 beq LongBranch_fat_58
 jmp FileContinue16
LongBranch_fat_58:
 lda $3c
 cmp #$fff8
 bcc LongBranch_fat_59
 jmp FileTruncated16
LongBranch_fat_59:
FileContinue16:
 sep #$20
 .ACCU 8
 COPY32 $38,$3c
 jmp FileCluster
FileComplete:
.IFDEF TESTFS
 lda $1892
 cmp #$a5
 beq P5Long_fat_1
 jmp FileTestContinue
P5Long_fat_1:
 lda #3
 sta $7f
FileTestHold:
 lda $1892
 cmp #$a5
 bne P5Long_fat_2
 jmp FileTestHold
P5Long_fat_2:
 stz $7f
FileTestContinue:
.ENDIF
 clc
 rts
FileSmall16:
 sep #$20
 .ACCU 8
 lda #$41
 jmp FSError
FileTruncated16:
 sep #$20
 .ACCU 8
 lda #$42
 jmp FSError

.IFDEF TESTFS
MockReadSector:
 rep #$20
 .ACCU 16
 ldx #0
MockSectorSearch:
 lda.l MockLBAs,x
 cmp $20
 beq LongBranch_fat_60
 jmp MockSectorNext
LongBranch_fat_60:
 lda.l MockLBAs+2,x
 cmp $22
 bne LongBranch_fat_61
 jmp MockSectorFound
LongBranch_fat_61:
MockSectorNext:
 inx
 inx
 inx
 inx
 cpx #MOCK_COUNT*4
 beq LongBranch_fat_62
 jmp MockSectorSearch
LongBranch_fat_62:
 sep #$20
 .ACCU 8
 lda #$7e
 jmp FSError
MockSectorFound:
 .ACCU 16
 txa
 lsr a
 lsr a
 pha
 and #63
 xba
 asl a
 ora #$8000
 sta $7a
 pla
 lsr a
 lsr a
 lsr a
 lsr a
 lsr a
 lsr a
 clc
 adc #2
.IFDEF HIROMBUILD
 pha
 and #1
 bne +
 lda $7a
 and #$7fff
 sta $7a
+:
 pla
 lsr a
 clc
 adc #$c0
.ENDIF
 sep #$20
 .ACCU 8
 sta $7c
 ldy #0
MockSectorCopy:
 lda [$7a],y
 sta $0200,y
 iny
 cpy #512
 beq LongBranch_fat_63
 jmp MockSectorCopy
LongBranch_fat_63:
 clc
 rts
.ENDIF
