; Derrick Bommarito
; Helloworld first experiments
; Build: mads -l -t main.asm
; Run: altirra /singleinstance main.obx

    org $0600

FLAME_FRAMES = 6

P0H = $00F0
P0V = $00F1
P0F = $00F2

init
    ; store display list address into SDLSTL
    ; with mads compiler can be: mwa #dlist_title SDLSTL
    lda #<dlist_title
    sta SDLSTL
    lda #>dlist_title
    sta SDLSTL + 1

    lda #$A0
    sta P0V

    ; set color palette
    mva #lt_gray  COLOR0 ; %01
    mva #dk_blue  COLOR1 ; %10
    mva #med_gray COLOR2 ; %11
    mva #gold     COLOR3 ; %11 (inverse)
    mva #black    COLOR4 ; %00

    mva #lt_gray  PCOLR0
    mva #dk_blue  PCOLR1

    mva #gold     PCOLR2
    mva #med_gray PCOLR3

    lda #GPRI_PMFRONT | GPRI_PLAYER4
    sta GPRIOR

    lda #FLAME_FRAMES
    sta P0F

    mva #>Tile0 CHBAS ; Sets page containing start of char set (MSB of start)

    ;jsr math_init
    jsr pm_init

main
    ; do stuff!
    
    lda #<dli
    sta VDSLST
    lda #>dli
    sta VDSLST+1

    lda #<vbi
    sta VVBLKD
    lda #>vbi
    sta VVBLKD+1

    lda #NMIEN_DLI | NMIEN_VBI
    sta NMIEN

    ldy #7 ; graphic will be 8 bytes long, start at last byte
    ldx #6
    lda #<rocket1r
    sta PM_SRC
    lda #>rocket1r
    sta PM_SRC+1
    lda #0 ; player index
    jsr pm_load

    ldy #7
    ldx #6
    lda #<rocket2r
    sta PM_SRC
    lda #>rocket2r
    sta PM_SRC+1
    lda #1
    jsr pm_load

    ldy #7
    ldx #6
    lda #<flame1r
    sta PM_SRC
    lda #>flame1r
    sta PM_SRC+1
    lda #2
    jsr pm_load

    inc PM_FLIP
    jsr wait_pm_flip

    ldy #7 ; graphic will be 8 bytes long, start at last byte
    ldx #6
    lda #<rocket1r
    sta PM_SRC
    lda #>rocket1r
    sta PM_SRC+1
    lda #0 ; player index
    jsr pm_load

    ldy #7
    ldx #6
    lda #<rocket2r
    sta PM_SRC
    lda #>rocket2r
    sta PM_SRC+1
    lda #1
    jsr pm_load

    ldy #7
    ldx #6
    lda #<flame2r
    sta PM_SRC
    lda #>flame2r
    sta PM_SRC+1
    lda #2
    jsr pm_load

flip0
    ; load title screen layout to buffer
    lda #<layout_title
    sta SCR_SRC
    lda #>layout_title
    sta SCR_SRC+1
    jsr screen_load
    
    lda P0H
    clc
    adc #1
    sta HPOSP0
    sta HPOSP1
    sta HPOSP2
    sta P0H

    dec P0F
    bne main_flip
    inc PM_FLIP
    lda #FLAME_FRAMES
    sta P0F

main_flip
    inc SCR_FLIP
    jsr wait_flip
    jmp flip0

dli
    pha ; save A to stack
    lda #green
    sta COLPF3 ;change invert color to green in hardware (will reset at VBLANK)
    pla ; restore A to interrupted value
    rti

;----------------------------------
; handles screen flipping when signalled by a non-zero value in SCR_FLIP
vbi
    pha
    lda SCR_FLIP
    beq vbi_pm ; skip flip if not set
    lda #0
    sta SCR_FLIP ; clear flip, not just dec in case multiple sources inc
    jsr flip_screen

vbi_pm
    lda PM_FLIP
    beq vbi_done
    lda #0
    sta PM_FLIP
    jsr flip_pm

vbi_done
    pla
    jmp XITVBV

; Display list
dlist_title
    .byte blank8, blank8, blank8
    .byte $05 + lms
dlist_title_screen
    .byte <SCR1, >SCR1
    .byte      $05, $05, $05, $05, $05
    .byte $05, $05, $05, $05, $85, $05
    .byte jvb, <dlist_title, >dlist_title

    icl 'hardware.asm'
    icl 'layout_title.asm'
    icl 'vast_pm.asm'
    icl 'vast_tiles.asm'
    ;icl 'math.asm'
    ;icl 'mult.asm'