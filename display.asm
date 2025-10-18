
; zero page registers

; Starting address for the graphics currently in use for blit operations
SCR_SRC   = $0080
SCR_SRC_H = $0081

;BLIT_X_X is used by screen_blit_row below
SCR_BLIT_SC = $0082 ; Source Col
SCR_BLIT_SR = $0083 ; Source Row
SCR_BLIT_DC = $0084 ; Dest Col
SCR_BLIT_DR = $0085 ; Dest Row

SCR_TMP = $0086 ; Temporary register used for rect blit
SCR_PG = $0087 ; Stores MSB for currently used screen layout

; space for indirect addressing of the inactive screen
SCR_DST   = $0092
SCR_DST_H = $0093

SCR_BLK_CUR = $0094 ; size of current map block
SCR_BLK_NUM = $0095 ; number of map blocks

; value to point to using screen0 or screen1
; points to the buffer currently being updated,
; the display will be pointed to the other screen
SCR_INDEX = $0096
SCR_FLIP  = $0097 ; flag to flip the screen pointer during VBI

;SCR0 = $B000 ; Buffer location for screen 0
;SCR1 = $B200 ; Buffer location for screen 1

;-------------------------------
; Screen layout instruction values
SL_END  = $00
SL_ZERO = $01 ; Zero Fill: SL_ZERO, <Count>
SL_RUN  = $02 ; Incremented: SL_RUN, <Start>, <Count>

;-------------------------------
; Display list values
blank8 = $70 ; 8 blank lines
lms    = $40 ; load memory scan
jvb    = $41 ; Jump while vblank

med_gray = $06
lt_gray  = $0A
green    = $C2
brown    = $22
black    = $00
gold     = $2C
dk_blue  = $90

SCR0 = $B000
SCR1 = $B200

;-----------------------------------
; loads an instruction based tilemap into the screen
; only works for full screens
; In: source address in SCR_SRC word
screen_load
    ; set current screen dest address
    lda SCR_INDEX
    bne load_1
load_0
    lda #<SCR0
    sta SCR_DST
    lda #>SCR0
    sta SCR_DST+1
    jmp scr_load_inst

load_1
    lda #<SCR1
    sta SCR_DST
    lda #>SCR1
    sta SCR_DST+1

scr_load_inst
    sec
    lda (SCR_SRC), y ; read instruction or tile index
    beq scr_load_end ; if value is 0 go to end
    sbc #1 ; decrement to check for zero fill
    beq scr_load_zero ; if value was 1, go to zero fill
    sbc #1 ; decrement to test for incrementing run
    beq scr_load_run
    clc
    adc #2 ; add to get original value, is tile index (character)
    sta (SCR_DST), y
    inc SCR_DST
    bne scr_load_next
    inc SCR_DST+1
    jmp scr_load_next

scr_load_zero
    iny ; move to zero count
    lda (SCR_SRC), y ; load zero count
    tax ; put count in x for loop count
    lda #0 ; load 0 into A to store into memory block
    ldy #0 ; load 0 offset for indirect addressing
    inc SCR_SRC
    bne scr_load_zero_loop
    inc SCR_SRC+1
scr_load_zero_loop
    sta (SCR_DST), y ; put 0 into screen memory
    inc SCR_DST
    bne scr_load_zero_2
    inc SCR_DST+1
scr_load_zero_2
    dex ; decrement zero count
    bne scr_load_zero_loop ; remaining zeros
    jmp scr_load_next ; done with zeros

scr_load_run
    ; fill with incrementing sequence
    clc ; clear carry bit, assume won't wrap during operation (encoding error)
    inc SCR_SRC ;move to run length
    bne scr_load_run2
    inc SCR_SRC+1
scr_load_run2
    lda (SCR_SRC),y ; load run length into A
    tax ; transfer run length to X
    inc SCR_SRC ; move past run length
    bne scr_load_run3
    inc SCR_SRC+1
scr_load_run3
    lda (SCR_SRC),y ; load start char into A
scr_load_run_loop
    sta (SCR_DST),y ; store char to buffer
    inc SCR_DST
    bne scr_load_run_loop2
    inc SCR_DST+1
scr_load_run_loop2
    adc #1 ; increment current character
    dex
    bne scr_load_run_loop

scr_load_next
    ; increment source, decrement count and loop if not done
    inc SCR_SRC
    bne scr_load_inst
    inc SCR_SRC+1
    jmp scr_load_inst

scr_load_end
    ;done!
    rts

;--------------------------------
; stores value in A to current screen location
; increments screen destination before returning
; assumes Y is 0
scr_load_char
    sta (SCR_DST), y
    inc SCR_DST
    bne scr_char_done
    inc SCR_DST+1
scr_char_done
    rts

;-------------------------
; routine to wait for buffer flip
wait_flip
    lda SCR_FLIP
    bne wait_flip
    rts