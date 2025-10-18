
PSLO = $A0
PSHI = $A1
PDLO = $A2
PDHI = $A3

; initialize mult lookup tables
math_init
    lda #SSQLO/256
    sta PSLO+1
    lda #SSQHI/256
    sta PSHI+1
    lda #DSQLO/256
    sta PDLO+1
    lda #DSQHI/256
    sta PDHI+1
    rts
    
; multiplies an 8 bit number by an 8 bit number stored in 16 bit result
; In: op1 in A, op2 in Y
; Out: reslo in x, reshi in A
mul_8_8_16
    sta PSLO     ;Index into sum table by A
    sta PSHI
    eor #$FF
    sta PDLO     ;Index into diff table by -A-1
    sta PDHI
    lda (PSLO),Y ;Get (a+y)^2/4 (lo byte)
    sec
    sbc (PDLO),Y ;Subtract (-a+y)^2/4 (lo byte)
    tax          ;Save it
    lda (PSHI),Y ;Get (a+y)^2/4 (hi byte)
    sbc (PDHI),Y ;Subtract (-a+y)^2/4 (hi byte)
    rti