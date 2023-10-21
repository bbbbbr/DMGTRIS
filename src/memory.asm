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


IF !DEF(MEMORY_ASM)
DEF MEMORY_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Memory Functions", ROM0
; Copies data from de to hl, bc bytes
UnsafeMemCopy::
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, UnsafeMemCopy
    ret


; Copies data from de to hl, bc bytes
SafeMemCopy::
    wait_vram
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, SafeMemCopy
    ret

; Sets memory from hl to hl+bc to d
UnsafeMemSet::
    ld [hl], d
    inc hl
    dec bc
    ld a, b
    or a, c
    jr nz, UnsafeMemSet
    ret


ENDC
