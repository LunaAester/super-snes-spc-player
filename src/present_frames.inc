.DEFINE PRESENT_FRAME_COUNT 127
PresentFrames:
 .dw PresentFrame000+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 16
 .dw PresentFrame000+10+16
 .dw PresentFrame000
 .dw PresentFrame001+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 1712
 .dw PresentFrame001+10+1712
 .dw PresentFrame001
 .dw PresentFrame002+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 2144
 .dw PresentFrame002+10+2144
 .dw PresentFrame002
 .dw PresentFrame003+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 2336
 .dw PresentFrame003+10+2336
 .dw PresentFrame003
 .dw PresentFrame004+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 2256
 .dw PresentFrame004+10+2256
 .dw PresentFrame004
 .dw PresentFrame005+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 2496
 .dw PresentFrame005+10+2496
 .dw PresentFrame005
 .dw PresentFrame006+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 2464
 .dw PresentFrame006+10+2464
 .dw PresentFrame006
 .dw PresentFrame007+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 2480
 .dw PresentFrame007+10+2480
 .dw PresentFrame007
 .dw PresentFrame008+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 2224
 .dw PresentFrame008+10+2224
 .dw PresentFrame008
 .dw PresentFrame009+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 2464
 .dw PresentFrame009+10+2464
 .dw PresentFrame009
 .dw PresentFrame010+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 2400
 .dw PresentFrame010+10+2400
 .dw PresentFrame010
 .dw PresentFrame011+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 2192
 .dw PresentFrame011+10+2192
 .dw PresentFrame011
 .dw PresentFrame012+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 2048
 .dw PresentFrame012+10+2048
 .dw PresentFrame012
 .dw PresentFrame013+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 1856
 .dw PresentFrame013+10+1856
 .dw PresentFrame013
 .dw PresentFrame014+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 1344
 .dw PresentFrame014+10+1344
 .dw PresentFrame014
 .dw PresentFrame015+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 65
.ENDIF
 .dw 1200
 .dw PresentFrame015+10+1200
 .dw PresentFrame015
 .dw PresentFrame016+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 1152
 .dw PresentFrame016+10+1152
 .dw PresentFrame016
 .dw PresentFrame017+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 1056
 .dw PresentFrame017+10+1056
 .dw PresentFrame017
 .dw PresentFrame018+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 1024
 .dw PresentFrame018+10+1024
 .dw PresentFrame018
 .dw PresentFrame019+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 1024
 .dw PresentFrame019+10+1024
 .dw PresentFrame019
 .dw PresentFrame020+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 992
 .dw PresentFrame020+10+992
 .dw PresentFrame020
 .dw PresentFrame021+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 880
 .dw PresentFrame021+10+880
 .dw PresentFrame021
 .dw PresentFrame022+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 672
 .dw PresentFrame022+10+672
 .dw PresentFrame022
 .dw PresentFrame023+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame023+10+704
 .dw PresentFrame023
 .dw PresentFrame023+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame023+10+704
 .dw PresentFrame023
 .dw PresentFrame023+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame023+10+704
 .dw PresentFrame023
 .dw PresentFrame023+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame023+10+704
 .dw PresentFrame023
 .dw PresentFrame023+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame023+10+704
 .dw PresentFrame023
 .dw PresentFrame023+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame023+10+704
 .dw PresentFrame023
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame029+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 704
 .dw PresentFrame029+10+704
 .dw PresentFrame029
 .dw PresentFrame046+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 944
 .dw PresentFrame046+10+944
 .dw PresentFrame046
 .dw PresentFrame047+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 66
.ENDIF
 .dw 944
 .dw PresentFrame047+10+944
 .dw PresentFrame047
 .dw PresentFrame048+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 944
 .dw PresentFrame048+10+944
 .dw PresentFrame048
 .dw PresentFrame049+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 944
 .dw PresentFrame049+10+944
 .dw PresentFrame049
 .dw PresentFrame050+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 944
 .dw PresentFrame050+10+944
 .dw PresentFrame050
 .dw PresentFrame051+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 896
 .dw PresentFrame051+10+896
 .dw PresentFrame051
 .dw PresentFrame052+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 896
 .dw PresentFrame052+10+896
 .dw PresentFrame052
 .dw PresentFrame053+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 896
 .dw PresentFrame053+10+896
 .dw PresentFrame053
 .dw PresentFrame054+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 896
 .dw PresentFrame054+10+896
 .dw PresentFrame054
 .dw PresentFrame055+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 896
 .dw PresentFrame055+10+896
 .dw PresentFrame055
 .dw PresentFrame056+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 1088
 .dw PresentFrame056+10+1088
 .dw PresentFrame056
 .dw PresentFrame057+10
.IFDEF HIROMBUILD
 .db $e1
.ELSE
 .db 67
.ENDIF
 .dw 1088
 .dw PresentFrame057+10+1088
 .dw PresentFrame057
 .dw PresentFrame058+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame058+10+1088
 .dw PresentFrame058
 .dw PresentFrame059+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame059+10+1088
 .dw PresentFrame059
 .dw PresentFrame060+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame060+10+1088
 .dw PresentFrame060
 .dw PresentFrame061+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame061+10+1088
 .dw PresentFrame061
 .dw PresentFrame062+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame062+10+1088
 .dw PresentFrame062
 .dw PresentFrame063+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame063+10+1088
 .dw PresentFrame063
 .dw PresentFrame064+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame064+10+1088
 .dw PresentFrame064
 .dw PresentFrame065+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame065+10+1088
 .dw PresentFrame065
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame066+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1088
 .dw PresentFrame066+10+1088
 .dw PresentFrame066
 .dw PresentFrame113+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 68
.ENDIF
 .dw 1152
 .dw PresentFrame113+10+1152
 .dw PresentFrame113
 .dw PresentFrame114+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 1344
 .dw PresentFrame114+10+1344
 .dw PresentFrame114
 .dw PresentFrame115+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 1296
 .dw PresentFrame115+10+1296
 .dw PresentFrame115
 .dw PresentFrame116+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 1376
 .dw PresentFrame116+10+1376
 .dw PresentFrame116
 .dw PresentFrame117+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 1408
 .dw PresentFrame117+10+1408
 .dw PresentFrame117
 .dw PresentFrame118+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 1728
 .dw PresentFrame118+10+1728
 .dw PresentFrame118
 .dw PresentFrame119+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 1760
 .dw PresentFrame119+10+1760
 .dw PresentFrame119
 .dw PresentFrame120+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 2000
 .dw PresentFrame120+10+2000
 .dw PresentFrame120
 .dw PresentFrame121+10
.IFDEF HIROMBUILD
 .db $e2
.ELSE
 .db 69
.ENDIF
 .dw 1760
 .dw PresentFrame121+10+1760
 .dw PresentFrame121
 .dw PresentFrame122+10
.IFDEF HIROMBUILD
 .db $e3
.ELSE
 .db 70
.ENDIF
 .dw 1680
 .dw PresentFrame122+10+1680
 .dw PresentFrame122
 .dw PresentFrame123+10
.IFDEF HIROMBUILD
 .db $e3
.ELSE
 .db 70
.ENDIF
 .dw 1744
 .dw PresentFrame123+10+1744
 .dw PresentFrame123
 .dw PresentFrame124+10
.IFDEF HIROMBUILD
 .db $e3
.ELSE
 .db 70
.ENDIF
 .dw 1584
 .dw PresentFrame124+10+1584
 .dw PresentFrame124
 .dw PresentFrame125+10
.IFDEF HIROMBUILD
 .db $e3
.ELSE
 .db 70
.ENDIF
 .dw 1520
 .dw PresentFrame125+10+1520
 .dw PresentFrame125
 .dw PresentFrame000+10
.IFDEF HIROMBUILD
 .db $e0
.ELSE
 .db 64
.ENDIF
 .dw 16
 .dw PresentFrame000+10+16
 .dw PresentFrame000
