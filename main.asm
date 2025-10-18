; Derrick Bommarito
; Helloworld first experiments
; Build: mads -l -t main.asm
; Run: altirra /singleinstance main.obx

    org $0600

init
    ; store display list address into SDLSTL
    ; with mads compiler can be: mwa #dlist_title SDLSTL
    lda #<dlist_title
    sta SDLSTL
    lda #>dlist_title
    sta SDLSTL + 1

    lda #1
    sta SCR_INDEX ; init drawing buffer to SCR1

    ; set color palette
    mva #black    COLB ; %00
    mva #lt_gray  COL1 ; %01
    mva #dk_blue  COL2 ; %10
    mva #gold     COL3 ; %11
    mva #med_gray COLI ; %11 (inverse)

    mva #>Tile0 CHBAS ; Sets page containing start of char set (MSB of start)

main
    ; do stuff!

    ; set current layout address
    lda #<layout_title
    sta SCR_SRC
    lda #>layout_title
    sta SCR_SRC+1
    
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

flip0
    ; load title screen layout to buffer
    lda #<layout_title
    sta SCR_SRC
    lda #>layout_title
    sta SCR_SRC+1
    jsr screen_load

    inc SCR_FLIP
    jsr wait_flip
    ;jsr flip_screen

flip1
    lda #<layout_title2
    sta SCR_SRC
    lda #>layout_title2
    sta SCR_SRC+1
    jsr screen_load

    inc SCR_FLIP
    jsr wait_flip
    ;jsr flip_screen
    jmp flip0

dli
    pha ; save A to stack
    lda #green
    sta COLIH ;change invert color to green in hardware (resets at VBLANK)
    pla ; restore A to interrupted value
    rti

;----------------------------------
; handles screen flipping when signalled by a non-zero value in SCR_FLIP
vbi
    pha
    lda SCR_FLIP
    beq vbi_done ; skip flip if not set
    lda #0
    sta SCR_FLIP ; clear flip, not just dec in case multiple sources inc
    jsr flip_screen

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
    icl 'math.asm'
    icl 'display.asm'
    icl 'vast_tiles.asm'
    icl 'layout_title.asm'
    icl 'mult.asm'