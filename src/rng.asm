; DMGTRIS
; Copyright (C) 2023 - Randy Thiemann <randy.thiemann@gmail.com>

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.


IF !DEF(RNG_ASM)
DEF RNG_ASM EQU 1


INCLUDE "globals.asm"


SECTION "High RNG Variables", HRAM
hRNGSeed:      ds 4
hPieceHistory: ds 4
hNextPiece::   ds 1


section "RNG Functions", ROM0
RNGInit::
    ; Do some bit fuckery on the seed using the gameboy's free-running timers.
    ldh a, [rDIV]
    xor a, [hl]
    ldh [hRNGSeed], a

    ldh a, [rTIMA]
    xor a, [hl]
    ldh [hRNGSeed+1], a

    ldh a, [rDIV]
    xor a, [hl]
    ldh [hRNGSeed+2], a

    ldh a, [rTIMA]
    xor a, [hl]
    ldh [hRNGSeed+3], a

    ; Initialize the next history.
    ld a, PIECE_Z
    ldh [hPieceHistory], a
    ldh [hPieceHistory+1], a
    ld a, PIECE_S
    ldh [hPieceHistory+2], a
    ldh [hPieceHistory+3], a

    ; Get the first piece and make sure it's not Z, S or O.
:   call NextPiece
    cp a, PIECE_Z
    jr z, :-
    cp a, PIECE_S
    jr z, :-
    cp a, PIECE_O
    jr z, :-

    ; Store it.
    ldh [hPieceHistory], a
    ld [hNextPiece], a
    ret


GetNextPiece::
    ld e, 7
:   dec e
    jr z, :+

    call NextPiece
    ld hl, hPieceHistory
    cp a, [hl]
    jr z, :-
    inc hl
    cp a, [hl]
    jr z, :-
    inc hl
    cp a, [hl]
    jr z, :-
    inc hl
    cp a, [hl]
    jr z, :-

:   ldh [hNextPiece], a
    ld b, a
    ldh a, [hPieceHistory+2]
    ldh [hPieceHistory+3], a
    ldh a, [hPieceHistory+1]
    ldh [hPieceHistory+2], a
    ldh a, [hPieceHistory]
    ldh [hPieceHistory+1], a
    ld a, b
    ldh [hPieceHistory], a
    ret


NextPiece:
    call NextByte
    and a, $07
    cp a, 7
    ret nz
    dec a
    ret

NextByte:
    ; Load seed
    ld hl, hRNGSeed+3
    ld a, [hl-]
    ld b, a
    ld a, [hl-]
    ld c, a
    ld a, [hl-]

    ; Multiply by 0x01010101
    add [hl]
    ld d, a
    adc c
    ld c, a
    adc b
    ld b, a

    ; Add 0x31415927 and write back
    ld a, [hl]
    add $27
    ld [hl+], a
    ld a, d
    adc $59
    ld [hl+], a
    ld a, c
    adc $41
    ld [hl+], a
    ld c, a
    ld a, b
    adc $31
    ld [hl], a
    ret


ENDC
