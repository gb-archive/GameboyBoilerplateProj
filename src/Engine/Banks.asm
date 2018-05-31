section "Banks", rom0

; This game uses Memory Bank Controller 3
; 128 ROM Banks (2MB)
; 4 RAM Banks (32KB)
; RTC Clock

; Calls from rom bank 1+ to another rom bank 1+ and back
; \1 label
farcallrom:      macro
    ld b, BANK(\1)
    ld hl, \2
    call FarcallRom
endm

; Jumps to rom bank 1+ from anywhere
; \1 label
farjprom:    macro
    ld b, BANK(\1)
    ld hl, \2
    jp FarJpRom
endm

; Calls from one ram bank to another ram bank and back
; \1 label
farcallsram:      macro
    ld b, BANK(\1)
    ld hl, \2
    call FarcallSRam
endm

; Jumps to any sram bank from another sram bank
; \1 label
farjpsram:    macro
    ld b, BANK(\1)
    ld hl, \2
    jp FarJpSRam
endm

; Calls from outside sram to sram and back, handles boot
; and shutdown of sram
; \1 label
callsram:      macro
    ld b, BANK(\1)
    ld hl, \2
    call CallSRam
endm

; Jumps to any sram bank from outside sram
; you are responsible for shutting down SRAM afterwards
; \1 label
jpsram:    macro
    ld b, BANK(\1)
    ld hl, \2
    jp JpSRam
endm

; Makes a call from anywhere to rom bank1+ and back
; given your calling from the non-home bank
; This makes a lot of clever hacks to get this to work
; B = Bank #
; HL = Call address
FarcallRom:
	ld a, [$4000]
	push af ; Save current rom bank

	ld a, b
	MBCSelectROMb ; Switch to new ROM Bank

    ; We're going to emulate a stack call in a hack
    ; Save the .return address below onto the stack
    ; And jp, the next ret will jump there as though
    ; we made a function call
	ld bc, .return
	push bc

	jp hl ; Jump (call in this case) to address

.return

    ; This is another hack, the processor popped off the
    ; above push, so what we're popping off here is actually
    ; the af from above that we pushed which contained current
    ; rom bank in a
	pop af
	MBCSelectROMb ; Switch to previous ROM Bank
	ret

; Switches to new ROM Bank and jumps to an address there
; Callable from anywhere to rom bank 1+
; b = Bank Number
; hl = Address
FarJpRom:
    ld a, b
	MBCSelectROMb ; Switch to new ROM Bank
    jp hl

; Similar to FarCallRom but works for strictly within SRAM
; Makes a call from one sram bank to another and back
; B = Bank #
; HL = Call address
FarcallSRam:
	ld a, [$A000]
	push af ; Save current sram bank

	ld a, b
	MBCSelectRAMb ; Switch to new sram Bank
	ld bc, .return
	push bc

	jp hl ; Jump (call in this case) to address

.return
	pop af
	MBCSelectRAMb ; Switch to previous sram Bank
	ret

; Switches to new RAM Bank and jumps to an address there
; Callable from any sram bank to any sram bank
; b = Bank Number
; hl = Address
FarJpSram:
    ld a, b
	MBCSelectRAMb ; Switch to new ROM Bank
    jp hl

; Calls a bank in SRAM from outside the RAM
; Boot up and shuts down ram when done
; 
; WARNING: Since this handles boot and shutdown and since other code exists
; which does the same, be careful calling code from sram especially calling
; code outside sram from sram because theres a good chance another function
; outside sram may shutdown sram when it's called from sram therefore crashing
; the game/program
; 
; B = Bank #
; HL = Call address
CallSRam:
    MBCPowerOn
	ld a, b
	MBCSelectRAMb ; Switch to sram Bank
	ld bc, .return
	push bc

	jp hl ; Jump (call in this case) to address

.return
    MBCPowerOff
	ret

; Boots up SRAM to a bank and jumps to an address there
; Callable from any non-sram bank to any sram bank
; You will be responsible for shutting down SRAM when done
; b = Bank Number
; hl = Address
JpSram:
    MBCPowerOn
    ld a, b
	MBCSelectRAMb ; Switch to new RAM Bank
    jp hl