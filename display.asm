
SAVMSC = $0058 ; Screen memory address
SDLSTL = $0230 ; Display list address
CHBAS  = $02F4 ; Character base
DMACTL = $022F ; DMACTL shadow register
GPRIOR = $026F ; PM priority shadow register
GPRI_PMFRONT = %00000001 ; All players in front
GPRI_P01FRONT = %00000010 ; Players 0,1 in front of PF
GPRI_PFFRONT  = %00000100 ; PFs in front
GPRI_PF01FRONT = %00001000 ; PF 0,1 in front and 2,3 in back
GPRI_PLAYER4   = %00010000 ; Use missiles as 5th player
GPRI_OVRLAPCOL = %00100000 ; Use overlap color

VDSLST = $0200 ; DLI handler address
VVBLKI = $0222 ; Immediate VBI vector
VVBLKD = $0224 ; Deferred VBI vector
SYSVBV = $E45F ; Immediate VBI jmp target
XITVBV = $E462 ; Deferred VBI jmp target

; OS shadow registers
PCOLR0  = $02C0 ; Player 0 color
PCOLR1  = $02C1 ; Player 1 color
PCOLR2  = $02C2 ; Player 2 color
PCOLR3  = $02C3 ; Player 3 color

COLOR0  = $02C4 ; %01
COLOR1  = $02C5 ; %10
COLOR2  = $02C6 ; Normal %11
COLOR3  = $02C7 ; Inverted %11
COLOR4  = $02C8 ; %00 COLBK shadow

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

;SCR_BLK_CUR = $0094 ; size of current map block
;SCR_BLK_NUM = $0095 ; number of map blocks

; value to point to using screen0 or screen1
; points to the buffer currently being updated,
; the display will be pointed to the other screen
SCR_INDEX = $0096
SCR_FLIP  = $0097 ; flag to flip the screen pointer during VBI

PM_SRC  = $0098
PM_SRCL = $0098
PM_SRCH = $0099

PM_DST  = $009A
PM_DSTL = $009A
PM_DSTH = $009B

PM_INDEX = $009C
PM_FLIP  = $009D
PM_TMP   = $009E

MASK_PX0 =       %11
MASK_PX1 =     %1100
MASK_PX2 =   %110000
MASK_PX3 = %11000000

B0 =        %1
B1 =       %10
B2 =      %100
B3 =     %1000
B4 =    %10000
B5 =   %100000
B6 =  %1000000
B7 = %10000000

;SCR0 = $B000 ; Buffer location for screen 0
;SCR1 = $B200 ; Buffer location for screen 1

;-------------------------------
; Screen layout instruction values
SL_END  = $00
SL_ZERO = $01 ; Zero Fill: SL_ZERO, <Count>
SL_RUN  = $02 ; Incremented: SL_RUN, <Count>, <Start>
SL_SKIP = $03 ; Skip: SL_SKIP, <Count>

PM_END = $FF ; end of sprite

PM_P0_OFFSET = $0400
PM_P1_OFFSET = $0500
PM_P2_OFFSET = $0600
PM_P3_OFFSET = $0700

;-------------------------------
; Display list values

med_gray = $06
lt_gray  = $0A
green    = $C2
brown    = $22
black    = $00
gold     = $2C
dk_blue  = $90

PM0   = $A000
PM0M  = $A180 ; missiles start
PM0P0 = $A200 ; Player 0 start
PM0P1 = $A280
PM0P2 = $A300
PM0P3 = $A380

PM1   = $A800
PM1M  = $A980
PM1P0 = $AA00
PM1P1 = $AA80
PM1P2 = $AB00
PM1P3 = $AB80

SCR0 = $B000
SCR1 = $B200

pm_init
    lda #>PM0
    sta PMBASE
    lda #60
    sta HPOSP0
    sta HPOSP1
    lda #%00101110
    sta DMACTL ; enable player missle graphics
    lda #3
    sta GRACTL
    rts

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
    jmp scr_load_inst

screen_load_pos ; variant for load with offset in X and Y
    stx SCR_DST
    lda SCR_INDEX
    bne scr_pos1
scr_pos0
    lda #>SCR0
    sta SCR_DST+1
    clc
    lda #<SCR0
    adc SCR_DST
    jmp load_pos1
scr_pos1
    lda #>SCR1
    sta SCR_DST+1
    clc
    lda #<SCR1
    adc SCR_DST

load_pos1
    dey
    bmi load_pos2
    clc
    adc #40
    bcc load_pos1
    inc SCR_DST+1
    jmp load_pos1
load_pos2
    sta SCR_DST

scr_load_inst
    ldy #0
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

flip_screen
    lda SCR_INDEX
    EOR #1 ; flip screen index
    sta SCR_INDEX ; store index back to ZP
    beq flip_screen1 ; branch to screen1 if SCR0 now active

flip_screen0
    ;lda #<SCR0
    ;sta dlist_title_screen
    lda #>SCR0
    sta dlist_title_screen+1
    rts

flip_screen1
    ;lda #<SCR1
    ;sta dlist_title_screen
    lda #>SCR1
    sta dlist_title_screen+1
    rts

wait_vbi
    lda $14 ; rtclock LSB
wait_vbi_loop
    cmp $14
    beq wait_vbi_loop
    rts

;-------------------------
; routine to wait for buffer flip
wait_flip
    lda SCR_FLIP
    bne wait_flip
    rts

flip_pm
    lda PM_INDEX
    EOR #1 ; flip screen index
    sta PM_INDEX ; store index back to ZP
    beq flip_pm1 ; branch to screen1 if SCR0 now active

flip_pm0
    lda #>PM0
    sta PMBASE
    rts

flip_pm1
    lda #>PM1
    sta PMBASE
    rts

wait_pm_flip
    lda PM_FLIP
    bne wait_pm_flip
    rts

;------------------------------
; loads 2 character graphics into a player area
; PM_SRC(+1) = Source of PM graphics
; A = player index
; X = start line
; Y = # bytes
; if Y is 0, the tile in A is centered in the sprite instead of split left/right
pm_load
    stx PM_DST ; store starting offset to LSB of dest
    ldx PM_INDEX
    bne pm_load_pm1p0

pm_load_pm0p0
    sec
    sbc #1
    bpl pm_load_pm0p1
    clc
    lda PM_DST
    adc #<PM0P0
    sta PM_DST
    lda #>PM0P0
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm0p1
    sec
    sbc #1
    bpl pm_load_pm0p2
    clc
    lda PM_DST
    adc #<PM0P1
    sta PM_DST
    lda #>PM0P1
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm0p2
    sec
    sbc #1
    bpl pm_load_pm0p3
    clc
    lda PM_DST
    adc #<PM0P2
    sta PM_DST
    lda #>PM0P2
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm0p3
    sec
    sbc #1
    bpl pm_load_pm0p4
    clc
    lda PM_DST
    adc #<PM0P3
    sta PM_DST
    lda #>PM0P3
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm0p4
    clc
    lda PM_DST
    adc #<PM0M
    sta PM_DST
    lda #>PM0M
    sta PM_DST+1
    jmp pm_load_copy

pm_load_pm1p0
    sec
    sbc #1
    bpl pm_load_pm1p1
    clc
    lda PM_DST
    adc #<PM1P0
    sta PM_DST
    lda #>PM1P0
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm1p1
    sec
    sbc #1
    bpl pm_load_pm1p2
    clc
    lda PM_DST
    adc #<PM1P1
    sta PM_DST
    lda #>PM1P1
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm1p2
    sec
    sbc #1
    bpl pm_load_pm1p3
    clc
    lda PM_DST
    adc #<PM1P2
    sta PM_DST
    lda #>PM1P2
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm1p3
    sec
    sbc #1
    bpl pm_load_pm1p4
    clc
    lda PM_DST
    adc #<PM1P3
    sta PM_DST
    lda #>PM1P3
    sta PM_DST+1
    jmp pm_load_copy
pm_load_pm1p4
    clc
    lda PM_DST
    adc #<PM1M
    sta PM_DST
    lda #>PM1M
    sta PM_DST+1
    jmp pm_load_copy

pm_load_copy
    lda (PM_SRC), y
    sta (PM_DST), y
    dey
    bpl pm_load_copy

pm_load_done
    rts


; src offset in X
; height in Y
; player index (0-3) in A
player_up
    stx PM_SRC
    ldx PM_INDEX
    bne pup_pm1p0

pup_pm0p0
    sec
    sbc #1
    bpl pup_pm0p1
    lda #>PM0P0
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM0P0
    sta PM_SRC
    bcc pup_pm0p0_done
    inc PM_SRC+1
pup_pm0p0_done
    jmp pup_copy

pup_pm0p1
    sec
    sbc #1
    bpl pup_pm0p2
    lda #>PM0P1
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM0P1
    sta PM_SRC
    bcc pup_pm0p1_done
    inc PM_SRC+1
pup_pm0p1_done
    jmp pup_copy

pup_pm0p2
    sec
    sbc #1
    bpl pup_pm0p3
    lda #>PM0P2
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM0P2
    sta PM_SRC
    bcc pup_pm0p2_done
    inc PM_SRC+1
pup_pm0p2_done
    jmp pup_copy

pup_pm0p3
    lda #>PM0P3
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM0P3
    sta PM_SRC
    bcc pup_pm0p3_done
    inc PM_SRC+1
pup_pm0p3_done
    jmp pup_copy

pup_pm1p0
    sec
    sbc #1
    bpl pup_pm1p1
    lda #>PM1P0
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM1P0
    sta PM_SRC
    bcc pup_pm1p0_done
    inc PM_SRC+1
pup_pm1p0_done
    jmp pup_copy

pup_pm1p1
    sec
    sbc #1
    bpl pup_pm1p2
    lda #>PM1P1
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM1P1
    sta PM_SRC
    bcc pup_pm1p1_done
    inc PM_SRC+1
pup_pm1p1_done
    jmp pup_copy

pup_pm1p2
    sec
    sbc #1
    bpl pup_pm1p3
    lda #>PM1P2
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM1P2
    sta PM_SRC
    bcc pup_pm1p2_done
    inc PM_SRC+1
pup_pm1p2_done
    jmp pup_copy

pup_pm1p3
    lda #>PM1P3
    sta PM_SRC+1
    lda PM_SRC
    adc #<PM1P3
    sta PM_SRC
    bcc pup_pm1p3_done
    inc PM_SRC+1
pup_pm1p3_done
    jmp pup_copy

pup_copy
    tya
    tax
    ldy #0
pup_copy_loop
    lda (PM_SRC), y
    sta (PM_SRC-1), y
    iny
    dex
    bne pup_copy_loop
pup_done
    rts

player_down
    nop

; In: player index in A
pm_clear
    ldy #128 ; rows in a PM region
    ldx PM_INDEX
    bne pm_clear_pm1p0

pm_clear_pm0p0
    sec
    sbc #1
    bpl pm_clear_pm0p1
    lda #<PM0P0
    sta PM_DST
    lda #>PM0P0
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm0p1
    sec
    sbc #1
    bpl pm_clear_pm0p2
    lda #<PM0P1
    sta PM_DST
    lda #>PM0P1
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm0p2
    sec
    sbc #1
    bpl pm_clear_pm0p3
    lda #<PM0P2
    sta PM_DST
    lda #>PM0P2
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm0p3
    sec
    sbc #1
    bpl pm_clear_pm0p4
    lda #<PM0P3
    sta PM_DST
    lda #>PM0P3
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm0p4
    lda #<PM0M
    sta PM_DST
    lda #>PM0M
    sta PM_DST+1
    jmp pm_clear_copy

pm_clear_pm1p0
    sec
    sbc #1
    bpl pm_clear_pm1p1
    lda #<PM1P0
    sta PM_DST
    lda #>PM1P0
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm1p1
    sec
    sbc #1
    bpl pm_clear_pm1p2
    lda #<PM1P1
    sta PM_DST
    lda #>PM1P1
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm1p2
    sec
    sbc #1
    bpl pm_clear_pm1p3
    lda #<PM1P2
    sta PM_DST
    lda #>PM1P2
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm1p3
    sec
    sbc #1
    bpl pm_clear_pm1p4
    lda #<PM1P3
    sta PM_DST
    lda #>PM1P3
    sta PM_DST+1
    jmp pm_clear_copy
pm_clear_pm1p4
    lda #<PM1M
    sta PM_DST
    lda #>PM1M
    sta PM_DST+1
    jmp pm_clear_copy

pm_clear_copy
    lda #0
    sta (PM_DST), y
    dey
    bpl pm_clear_copy
pm_clear_done
    rts

missile_up
    nop

missile_down
    nop