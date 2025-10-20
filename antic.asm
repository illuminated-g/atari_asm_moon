DMACTLH      = $D400
DMA_NARROWPF = %00000001 ; narrow playfield
DMA_STNDPF   = %00000010 ; standard playfield
DMA_ENMIS    = %00000100 ; enable missile DMA
DMA_ENPL     = %00001000 ; enable player DMA
DMA_SLRES    = %00010000 ; single line resolution
DMA_ENABLE   = %00100000 ; enable DMA

CHACTL  = $D401
 
DLIST   = $D402
DLISTL  = $D402
DLISTH  = $D403
 
HSCROL  = $D404
VSCROL  = $D405

PMBASE  = $D407

CHBASE  = $D409

WSYNC   = $D40A
VCOUNT  = $D40B

PENH    = $D40C
PENV    = $D40D

NMIEN   = $D40E
NMIRES  = $D40F
NMIST   = $D40F

NMIEN_VBI = $40
NMIEN_DLI = $80


BLANK8 = $70 ; 8 blank lines
LMS    = $40 ; load memory scan
JVB    = $41 ; Jump while vblank