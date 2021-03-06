if      !def(CORE_GRAPHICS_INC)
CORE_GRAPHICS_INC  set  1

include "./src/Includes.inc"

; Special Graphic Engine Commands

GSTOP   EQU     $FF
GNEXT   EQU     $FE
GEND    EQU     $FD

; Convers Y, X coords to address offset and adds them to base address
; \1 = Y
; \2 = X
; \3 = Base Address
coord:      macro
    ld b, \1
    ld c, \2
    ld de, \3
    call CoordToAddr
endm

; Prints a tile at address
; \1 = Address
; \2 = Tile
raw_print:      macro
    ld de, \1
    ld a, \2
    call PrintTile
endm

; Prints a tile at coords in address
; \1 = Address
; \2 = Y
; \3 = X
; \4 = Tile
print:      macro
    ld de, \1
    ld b, \2
    ld c, \3
    ld a, \4
    call PrintTileAt
endm

; Prints tiles at address using engine (Stops at GSTOP)
; \1 = From Address
; \2 = To Address
raw_printstr:      macro
    ld hl, \1
    ld de, \2
    call PrintTiles
endm

; Prints tiles at address using engine (Stops at GSTOP)
; \1 = From Address
; \2 = To Address
; \3 = Y
; \4 = X
printstr:      macro
    ld hl, \1
    ld de, \2
    ld b, \3
    ld c, \4
    call PrintTilesAt
endm

; Prints tilemap to screen coords
; \1 = TileMap Address
; \2 = To Address
; \3 = Y
; \4 = X
printmap:       macro
    ld hl, \1
    ld de, \2
    ld b, \3
    ld c, \4
    call PrintTileMap
endm

endc
