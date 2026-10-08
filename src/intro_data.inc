ROMBLOCK 120, 0
.SECTION "IntroGraphics" FORCE
IntroTiles:
 .incbin "intro_tiles.bin"
IntroTilesEnd:
IntroPalette:
 .incbin "intro_palette.bin"
IntroNameMap:
 .incbin "intro_name.bin"
IntroLogoMap:
 .incbin "intro_logo.bin"
.ENDS
ROMBLOCK 121, 0
.SECTION "IntroAudioLeft" FORCE
IntroDirectory:
 .incbin "intro_directory.bin"
IntroDriver:
 .incbin "intro_apu.bin"
IntroLeft:
 .incbin "PRESENT_L.BRR"
IntroLeftEnd:
.ENDS
ROMBLOCK 122, 0
.SECTION "IntroAudioRight" FORCE
IntroRight:
 .incbin "PRESENT_R.BRR"
IntroRightEnd:
.ENDS
ROMBLOCK 123, 0
.SECTION "LogoAudioLeft" FORCE
LogoAudioDirectory:
 .incbin "MATCH_directory.bin"
LogoAudioDriver:
 .incbin "effect_logo.bin"
LogoAudioLeft:
 .incbin "MATCH_L.BRR"
LogoAudioLeftEnd:
.ENDS
ROMBLOCK 124, 0
.SECTION "LogoAudioRight" FORCE
LogoAudioRight:
 .incbin "MATCH_R.BRR"
LogoAudioRightEnd:
.ENDS
ROMBLOCK 125, 0
.SECTION "MoveAudio" FORCE
MoveDirectory:
 .incbin "MOVE_directory.bin"
MoveDriver:
 .incbin "effect_move.bin"
MoveLeft:
 .incbin "MOVE_L.BRR"
MoveLeftEnd:
MoveRight:
 .incbin "MOVE_R.BRR"
MoveRightEnd:
.ENDS
