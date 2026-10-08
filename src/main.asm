.MEMORYMAP
 DEFAULTSLOT 0
 .IFDEF HIROMBUILD
  SLOTSIZE $10000
  SLOT 0 $0000
 .ELSE
  SLOTSIZE $8000
  SLOT 0 $8000
 .ENDIF
.ENDME
.IFDEF HIROMBUILD
 .ROMBANKSIZE $10000
 .ROMBANKS 64
 .BASE $c0
.ELSE
 .ROMBANKSIZE $8000
 .ROMBANKS 128
.ENDIF
.EMPTYFILL 0
.include "rom_mapping.inc"
.include "rom_bank_defs.inc"
.IFDEF TESTFS
 .include "fixture_defs.inc"
.ENDIF
.SNESHEADER
 ID "EVDR"
 NAME "SUPER SPC PLAYER 1.1"
 .IFDEF HIROMBUILD
  FASTROM
  HIROM
 .ELSE
  SLOWROM
  LOROM
 .ENDIF
 CARTRIDGETYPE 0
 ROMSIZE $0c
 SRAMSIZE 0
 COUNTRY 1
 LICENSEECODE 0
 VERSION 0
.ENDSNES
.SNESNATIVEVECTOR
 COP Handler
 BRK Handler
 ABORT Handler
 NMI FrameNMI
 IRQ Handler
.ENDNATIVEVECTOR
.SNESEMUVECTOR
 COP Handler
 ABORT Handler
 NMI FrameNMI
 RESET Start
 IRQBRK Handler
.ENDEMUVECTOR

.MACRO ADD32 ARGS dest,src
 rep #$20
 .ACCU 16
 clc
 lda dest
 adc src
 sta dest
 lda dest+2
 adc src+2
 sta dest+2
 sep #$20
 .ACCU 8
.ENDM
.MACRO COPY32 ARGS dest,src
 rep #$20
 .ACCU 16
 lda src
 sta dest
 lda src+2
 sta dest+2
 sep #$20
 .ACCU 8
.ENDM
.MACRO SDTRY
 jsr ReadSector
 bcc +
 rts
+:
.ENDM

.BANK 0 SLOT 0
.IFDEF HIROMBUILD
 .ORG $8000
.ELSE
 .ORG 0
.ENDIF
.SECTION "Code" FORCE
Start:
 sei
 clc
 xce
 rep #$38
 .ACCU 16
 .INDEX 16
 ldx #$1fff
 txs
 lda #0
 tcd
 sep #$20
 .ACCU 8
 lda #0
 pha
 plb
.IFDEF HIROMBUILD
 lda #1
 sta $420d
 jml FastStart
FastStart:
.ELSE
 stz $420d
.ENDIF
 stz $4200
 stz $420b
 stz $420c
 stz $1890
 stz $8f
 stz $4d
 rep #$20
 .ACCU 16
 stz $6e
 sep #$20
 .ACCU 8
 ldx #0
P5ClearState:
 stz $1c00,x
 inx
 cpx #512
 beq P5Long_main_0
 jmp P5ClearState
P5Long_main_0:
 lda #100
 sta $1c40
 lda #3
 sta $1c41
 rep #$20
 .ACCU 16
 lda #100
 sta $1c42
 sep #$20
 .ACCU 8
 jsr InitVideo
 jsr APUStartup
 jsr RunIntro
 jsr V13Init
BootMount:
 stz $4d
 jsr DrawLoading
 jsr Mount
 bcs LongBranch_main_0
 jmp Mounted
LongBranch_main_0:
 jmp Fatal
Mounted:
 rep #$20
 .ACCU 16
 stz $4a
 lda $30
 sta $34
 sta $0600
 lda $32
 sta $36
 sta $0602
 sep #$20
 .ACCU 8
 jsr ListDirectory
 bcc +
 jmp Fatal
+:
 jsr UISoundEnsureMove
 jsr DrawBrowser
GameLoop:
 lda #1
 sta $7f
 jsr ReadJoy
 jsr V13Input
 lda $1ced
 beq +
 jmp CreditsLoop
+:
 rep #$20
 .ACCU 16
 lda $70
 and #$1040
 cmp #$1040
 bne +
 lda $72
 and #$1040
 beq +
 jmp CreditsToggle
+:
 sep #$20
 .ACCU 8
 lda $1c4e
 bne P5Long_main_1
 jmp P5Controls
P5Long_main_1:
 jsr WaitFrame
 rep #$20
 .ACCU 16
 lda $72
 bit #$8000
 bne P5Long_main_2
 jmp P5ErrorIdle
P5Long_main_2:
 sep #$20
 .ACCU 8
 stz $1c4e
 stz $4d
 jmp P5Back
P5ErrorIdle:
 sep #$20
 .ACCU 8
 jmp GameLoop
P5Controls:
 rep #$20
 .ACCU 16
 lda $70
 bit #$2000
 bne P5Long_main_3
 jmp P5SpeedModifier
P5Long_main_3:
 lda $72
 bit #$0080
 beq P5Long_main_4
 jmp P5Stop
P5Long_main_4:
 bit #$8000
 beq P5Long_main_5
 jmp P11AudioToggle
P5Long_main_5:
 bit #$1000
 beq P5Long_main_49
 jmp V13Visual16
P5Long_main_49:
 bit #$0020
 beq P5Long_main_50
 jmp V13PageLeft16
P5Long_main_50:
 bit #$0010
 beq P5Long_main_51
 jmp V13PageRight16
P5Long_main_51:
 jmp P5SpeedModifier
V13Visual16:
 sep #$20
 .ACCU 8
 stz $1d88
 lda $1d89
 inc a
 cmp #3
 bcc +
 lda #0
+:
 sta $1d89
 jmp P5NoButton
V13PageLeft16:
 sep #$20
 .ACCU 8
 lda $1d88
 bne +
 lda #8
+:
 dec a
 sta $1d88
 jmp P5NoButton
V13PageRight16:
 sep #$20
 .ACCU 8
 lda $1d88
 inc a
 cmp #8
 bcc +
 lda #0
+:
 sta $1d88
 jmp P5NoButton
P11AudioToggle:
 sep #$20
 .ACCU 8
 lda $1c80
 eor #1
 sta $1c80
 jsr ControlOutputMode
 bcc +
 jmp P5Error
+:
 jmp P5NoButton
P5SpeedModifier:
 .ACCU 16
 lda $70
 bit #$4000
 bne P5Long_main_6
 jmp P5VolumeModifier
P5Long_main_6:
 lda $72
 bit #$0200
 beq P5Long_main_7
 jmp P5Slower
P5Long_main_7:
 bit #$0100
 beq P5Long_main_8
 jmp P5Faster
P5Long_main_8:
 jmp P5NoButton
P5VolumeModifier:
 lda $70
 bit #$0040
 bne P5Long_main_9
 jmp P5Normal
P5Long_main_9:
 lda $72
 bit #$0800
 beq P5Long_main_10
 jmp P5Louder
P5Long_main_10:
 bit #$0400
 beq P5Long_main_11
 jmp P5Quieter
P5Long_main_11:
 jmp P5NoButton
P5Normal:
 lda $72
 bit #$0020
 beq P5Long_main_12
 jmp P5Previous
P5Long_main_12:
 bit #$0010
 beq P5Long_main_13
 jmp P5Next
P5Long_main_13:
 bit #$0800
 beq P5Long_main_14
 jmp P5Up
P5Long_main_14:
 bit #$0400
 beq P5Long_main_15
 jmp P5Down
P5Long_main_15:
 bit #$0080
 beq P5Long_main_16
 jmp P5Play
P5Long_main_16:
 bit #$8000
 beq P5Long_main_17
 jmp P5Back16
P5Long_main_17:
P5NoButton:
 sep #$20
 .ACCU 8
 jsr ControlMeter
 bcc P5Long_main_18
 jmp P5Error
P5Long_main_18:
 jsr V13Poll
 bcc +
 jmp P5Error
+:
 jsr DrawBrowser
 jmp GameLoop
P5Up:
 .ACCU 16
 lda $44
 bne P5Long_main_19
 jmp P5NoButton
P5Long_main_19:
 lda $46
 beq P5Long_main_20
 jmp P5UpDecrement
P5Long_main_20:
 lda $44
 sta $46
P5UpDecrement:
 dec $46
 jsr UISoundMove
 .ACCU 16
 jmp P5NoButton
P5Down:
 lda $44
 bne P5Long_main_47
 jmp P5NoButton
P5Long_main_47:
 lda $46
 inc a
 cmp $44
 bcs P5Long_main_48
 jmp P5DownSave
P5Long_main_48:
 lda #0
P5DownSave:
 sta $46
 jsr UISoundMove
 .ACCU 16
 jmp P5NoButton
P5Previous:
 lda #$ffff
 jmp P5SkipSong
P5Next:
 lda #1
P5SkipSong:
 sta $1c78
 ; Follow the playing track when browsing within its original directory.
 lda $8f
 and #$00ff
 bne P5Long_main_44
 jmp P5SkipCursor
P5Long_main_44:
 lda $34
 cmp $1d12
 beq P5Long_main_45
 jmp P5SkipCursor
P5Long_main_45:
 lda $36
 cmp $1d14
 beq P5Long_main_46
 jmp P5SkipCursor
P5Long_main_46:
 lda $1d10
 sta $46
P5SkipCursor:
 lda $44
 bne P5Long_main_21
 jmp P5NoButton
P5Long_main_21:
 sta $1c7a
P5FindSong:
 lda $46
 clc
 adc $1c78
 bpl P5Long_main_22
 jmp P5WrapLast
P5Long_main_22:
 cmp $44
 bcs P5Long_main_23
 jmp P5CheckSong
P5Long_main_23:
 lda #0
 jmp P5CheckSong
P5WrapLast:
 lda $44
 dec a
P5CheckSong:
 sta $46
 asl a
 asl a
 asl a
 asl a
 asl a
 tax
 sep #$20
 .ACCU 8
 lda $080b,x
 and #$10
 bne P5Long_main_24
 jmp P5Play8
P5Long_main_24:
 rep #$20
 .ACCU 16
 dec $1c7a
 beq P5Long_main_25
 jmp P5FindSong
P5Long_main_25:
 jmp P5NoButton
P5Play:
 sep #$20
 .ACCU 8
P5Play8:
 stz $7f
 jsr Activate
 bcc P5Long_main_26
 jmp P5Error
P5Long_main_26:
 jmp P5Refresh
P5Back16:
 sep #$20
 .ACCU 8
P5Back:
 stz $7f
 jsr Back
 bcc P5Long_main_27
 jmp P5Error
P5Long_main_27:
 jmp P5Refresh
P5Parent:
 sep #$20
 .ACCU 8
 stz $7f
 jsr BackFolder
 bcc P5Long_main_28
 jmp P5Error
P5Long_main_28:
 jmp P5Refresh
P5Stop:
 sep #$20
 .ACCU 8
 jsr StopAPU
 bcc P5Long_main_29
 jmp P5Error
P5Long_main_29:
 jmp P5Refresh
P5Slower:
 sep #$20
 .ACCU 8
 lda $8f
 bne P5Long_main_30
 jmp P5Refresh
P5Long_main_30:
 lda $1c41
 bne P5Long_main_31
 jmp P5Refresh
P5Long_main_31:
 dec $1c41
 jsr ControlTempo
 bcc P5Long_main_32
 jmp P5Error
P5Long_main_32:
 jmp P5Refresh
P5Faster:
 sep #$20
 .ACCU 8
 lda $1c0f
 bne P5Long_main_42
 jmp P5FasterGeneral
P5Long_main_42:
 lda $1c41
 cmp #4
 bcs P5Long_main_43
 jmp P5FasterGeneral
P5Long_main_43:
 jmp P5Refresh
P5FasterGeneral:
 lda $8f
 bne P5Long_main_33
 jmp P5Refresh
P5Long_main_33:
 lda $1c41
 cmp #6
 bne P5Long_main_34
 jmp P5Refresh
P5Long_main_34:
 inc $1c41
 jsr ControlTempo
 bcc P5Long_main_35
 jmp P5Error
P5Long_main_35:
 jmp P5Refresh
P5Louder:
 sep #$20
 .ACCU 8
 lda $8f
 bne P5Long_main_36
 jmp P5Refresh
P5Long_main_36:
 lda $1c40
 cmp #100
 bne P5Long_main_37
 jmp P5Refresh
P5Long_main_37:
 clc
 adc #10
 sta $1c40
 jsr ControlVolume
 bcc P5Long_main_38
 jmp P5Error
P5Long_main_38:
 jmp P5Refresh
P5Quieter:
 sep #$20
 .ACCU 8
 lda $8f
 bne P5Long_main_39
 jmp P5Refresh
P5Long_main_39:
 lda $1c40
 bne P5Long_main_40
 jmp P5Refresh
P5Long_main_40:
 sec
 sbc #10
 sta $1c40
 jsr ControlVolume
 bcc P5Long_main_41
 jmp P5Error
P5Long_main_41:
P5Refresh:
 stz $7f
 jsr UISoundEnsureMove
 jsr DrawBrowser
 jmp GameLoop
P5Error:
 lda #1
 sta $1c4e
 jsr DrawError
 jsr UISoundError
 jmp GameLoop
Fatal:
 lda #$ff
 sta $7f
 jsr DrawError
 jsr UISoundError
FatalLoop:
 jsr WaitFrame
 jsr ReadJoy
 rep #$20
 .ACCU 16
 lda $72
 bit #$8000
 beq +
 sep #$20
 .ACCU 8
 jmp BootMount
+:
 sep #$20
 .ACCU 8
 jmp FatalLoop
Handler:
 rti

.include "sd.asm"
.include "fat.asm"
.include "ui.asm"
.include "apu.asm"
.include "apu_recovery.asm"
.include "game_apu.asm"
.include "general_apu.asm"
.include "controls.asm"
.include "auto_drivers.asm"
.include "intro.asm"
.include "loading_progress.asm"
.include "ui_sounds.asm"
.include "titles.asm"
.include "v13.asm"
.include "credits.asm"
Signature:
 .db "SNES-SPC700 Sound File Data"
DriverSignature:
 .incbin "driver_signature.bin"
BootData:
 .incbin "apu_boot.bin"
BootEnd:
StopData:
 .incbin "apu_stop.bin"
StopEnd:
.ENDS
.IFDEF TESTFS
.include "fixture.inc"
.ENDIF

.include "control_profiles.inc"
.include "intro_data.inc"
.include "present_data.inc"
.include "auto_guard_data.inc"
.include "auto_exact_data.inc"

ROMBLOCK 101,0
.SECTION "HUD assets" FORCE
FontData:
 .incbin "font.bin"
FontEnd:
ScreenData:
 .incbin "screen.bin"
LoadingScreen:
 .incbin "loading.bin"
ErrorScreen:
 .incbin "error.bin"
V13PanelData:
 .incbin "v13_panel.bin"
.ENDS
