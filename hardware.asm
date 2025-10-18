; "Register" addresses
SAVMSC = $0058 ; Screen memory address
SDLSTL = $0230 ; Display list address
CHBAS  = $02F4 ; Character base

VDSLST = $0200 ; DLI handler address
VVBLKI = $0222 ; Immediate VBI vector
VVBLKD = $0224 ; Deferred VBI vector
SYSVBV = $E45F ; Immediate VBI jmp target
XITVBV = $E462 ; Deferred VBI jmp target

NMIEN  = $D40E ; NMI enable flags
NMIEN_VBI = $40
NMIEN_DLI = $80

COLB = $02C8 ; color for %00 (background)
COL1 = $02C4 ; color for %01
COL2 = $02C5 ; color for %10
COL3 = $02C6 ; color for %11 (normal)
COLI = $02C7 ; color for %11 (inverse)

; Direct hardware registers for colors
; These get reset every VBI with the shadow values above
COLBH = $D01A
COL1H = $D016
COL2H = $D017
COL3H = $D018
COLIH = $D019


; $0600:$06FF Unused
; $0700:$1501 FMS Ram (Unused)
; $1540:$3306 DUP.SYS (Unused)
; $3307:$7FFF Unused
; $8000:$9FFF Cart B (Unused)
; $A000:$BFFF Cart A (Unused)
; $DO0O:$DO1F CTIA
; $D200:$D21F POKEY
; $D300:$D31F PIA
; $D400:$D41F ANTIC
; $D800:$FFFF OS