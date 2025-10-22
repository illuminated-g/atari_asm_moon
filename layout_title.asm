    ;org $6000

layout_title
    .byte SL_ZERO,52
    .byte SL_RUN,16,$20
    .byte SL_ZERO,25
    .byte SL_RUN,14,$41
    .byte SL_ZERO,67
    .byte SL_RUN,12,$D4
    .byte SL_ZERO,29
    .byte SL_RUN,10,$F6 ;15 after on row
    .byte SL_ZERO,225
    .byte SL_RUN,20,$E0
    .byte SL_ZERO,10
    .byte SL_END

layout_moon
    .byte $74,$75