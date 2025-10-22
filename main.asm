; Derrick Bommarito
; Helloworld first experiments
; Build: mads -l -t main.asm
; Run: altirra /singleinstance main.obx

    org $0600

FLAME_FRAMES = 6
MOON_FRAMES = 2

ANIMH = $00F0
ANIMV = $00F1
ANIMF = $00F2

init
    ; store display list address into SDLSTL
    ; with mads compiler can be: mwa #dlist_title SDLSTL
    lda #<dlist_title
    sta SDLSTL
    lda #>dlist_title
    sta SDLSTL + 1

    lda #$A0
    sta ANIMV

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
    sta ANIMF

    mva #>Tile0 CHBAS ; Sets page containing start of char set (MSB of start)

    ;jsr math_init
    jsr pm_init

title_init
    
    lda #<title_dli
    sta VDSLST
    lda #>title_dli
    sta VDSLST+1

    lda #<title_vbi
    sta VVBLKD
    lda #>title_vbi
    sta VVBLKD+1

    lda #NMIEN_DLI | NMIEN_VBI
    sta NMIEN

    lda #<layout_title
    sta SCR_SRC
    lda #>layout_title
    sta SCR_SRC+1
    jsr screen_load

    inc SCR_FLIP
    jsr wait_flip

    lda #<layout_title
    sta SCR_SRC
    lda #>layout_title
    sta SCR_SRC+1
    jsr screen_load

    jmp moon_done

moon_start
    ldy #7 ; 8 rows in sprite
    ldx #80
    lda #<moon1
    sta PM_SRC
    lda #>moon1
    sta PM_SRC+1
    lda #0
    jsr pm_load

    ldy #7
    ldx #80
    lda #<moon2
    sta PM_SRC
    lda #>moon2
    sta PM_SRC+1
    lda #3
    jsr pm_load

    lda #0
    sta ANIMH

    lda #MOON_FRAMES
    sta ANIMF

moon_loop
    ldx ANIMF
    dex
    stx ANIMF
    bpl moon_flip
    lda ANIMH
    cmp #196
    beq moon_done
    clc
    adc #1
    sta ANIMH
    sta HPOSP0
    sta HPOSP3
    lda #MOON_FRAMES
    sta ANIMF
moon_flip
    inc SCR_FLIP
    jsr wait_flip
    jmp moon_loop
moon_done
    lda #<layout_moon
    sta SCR_SRC
    lda #>layout_moon
    sta SCR_SRC+1
    ldx #37
    ldy #8
    jsr screen_load_pos
    inc SCR_FLIP

    lda #0
    jsr pm_clear
    lda #3
    jsr pm_clear
    inc PM_FLIP

    jsr wait_vbi

rocket1_start
    lda #130
    sta ANIMV
    lda #80
    sta ANIMH
    sta HPOSP0
    sta HPOSP1
    sta HPOSP2

    ldy #7 ; graphic will be 8 bytes long, start at last byte
    ldx ANIMV
    lda #<rocket1u
    sta PM_SRC
    lda #>rocket1u
    sta PM_SRC+1
    lda #0 ; player index
    jsr pm_load

    ldy #7
    ldx ANIMV
    lda #<rocket2u
    sta PM_SRC
    lda #>rocket2u
    sta PM_SRC+1
    lda #1
    jsr pm_load

    ldy #7
    ldx ANIMV
    lda #<flame1u
    sta PM_SRC
    lda #>flame1u
    sta PM_SRC+1
    lda #2
    jsr pm_load

    inc PM_FLIP
    jsr wait_pm_flip

    ldy #7 ; graphic will be 8 bytes long, start at last byte
    ldx ANIMV
    lda #<rocket1u
    sta PM_SRC
    lda #>rocket1u
    sta PM_SRC+1
    lda #0 ; player index
    jsr pm_load

    ldy #7
    ldx ANIMV
    lda #<rocket2u
    sta PM_SRC
    lda #>rocket2u
    sta PM_SRC+1
    lda #1
    jsr pm_load

    ldy #7
    ldx ANIMV
    lda #<flame2u
    sta PM_SRC
    lda #>flame2u
    sta PM_SRC+1
    lda #2
    jsr pm_load

    inc PM_FLIP

rocket1_loop
    jsr wait_vbi
    ldx ANIMV
    ldy #8
    lda #0
    jsr player_up
    ldx ANIMV
    ldy #8
    lda #1
    jsr player_up
    ldx ANIMV
    ldy #8
    lda #2
    jsr player_up
    lda ANIMV
    sec
    sbc #1
    sta ANIMV
    bne rocket1_loop

    jmp *

title_dli
    pha ; save A to stack
    lda #green
    sta COLPF3 ;change invert color to green in hardware (will reset at VBLANK)
    pla ; restore A to interrupted value
    rti

;----------------------------------
; handles screen flipping when signalled by a non-zero value in SCR_FLIP
title_vbi
    pha
    lda SCR_FLIP
    beq title_vbi_pm ; skip flip if not set
    lda #0
    sta SCR_FLIP ; clear flip, not just dec in case multiple sources inc
    jsr flip_screen
title_vbi_pm
    lda PM_FLIP
    beq title_vbi_done
    lda #0
    sta PM_FLIP
    jsr flip_pm
title_vbi_done
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