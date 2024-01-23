; *********************************************************************************************************************************
; programming	: pvar a.k.a. sp1r@l ev0lut10n
; started		: 26 - 01 - 2010
; completed		: 14 - 02 - 2010
;
; A minimal (and cool ;-) approach to LED-matrix driving!
; *********************************************************************************************************************************

; **************************************************
; * fundamental assembler directives
; **************************************************

; constants -----------------------------------------------------------------------------------------------------------------------

.include "tn2313.inc"

.equ scroll_speed = 10					; higher value => lower speed

; variables -----------------------------------------------------------------------------------------------------------------------

.def row8 = r8							; topmost line of frame buffer
.def row7 = r7							;
.def row6 = r6							;
.def row5 = r5							;
.def row4 = r4							;
.def row3 = r3							;
.def row2 = r2							;
.def row1 = r1							; lowermost line of frame buffer

.def alt_row8 = r16						; topmost line of alternate frame buffer
.def alt_row7 = r15						;
.def alt_row6 = r14						;
.def alt_row5 = r13						;
.def alt_row4 = r12						;
.def alt_row3 = r11						;
.def alt_row2 = r10						;
.def alt_row1 = r9						; lowermost line of alternate frame buffer

.def pa_data = r17						; data to be output on porta
.def pb_data = r18						; data to be output on portb
.def pd_data = r19						; data to be output on portd

.def tmp1 = r20
.def tmp2 = r21
.def tmp3 = r22

; **************************************************
; * code segment initialization
; **************************************************

.cseg
.org 0x0000
	rjmp mcu_init						; Reset interrupt

; **************************************************
; * flash data table
; **************************************************

data_table:
;	 data for each line of led matrix					 char			address offset (tmp2:tmp1)
	.db	0xFF, 0xC3, 0x99, 0x81, 0x99, 0x99, 0x99, 0xFF	; A 			[0][0]
	.db	0xFF, 0x83, 0x99, 0x83, 0x99, 0x99, 0x83, 0xFF	; B 			[0][8]
	.db	0xFF, 0xC3, 0x9F, 0x9F, 0x9F, 0x9F, 0xC3, 0xFF	; C 			[0][16]
	.db	0xFF, 0x83, 0x99, 0x99, 0x99, 0x99, 0x83, 0xFF	; D 			[0][24]
	.db	0xFF, 0x83, 0x9F, 0x87, 0x9F, 0x9F, 0x83, 0xFF	; E 			[0][32]
	.db	0xFF, 0x81, 0x9F, 0x9F, 0x87, 0x9F, 0x9F, 0xFF	; F 			[0][40]
	.db	0xFF, 0xC1, 0x9F, 0x9F, 0x91, 0x99, 0xC1, 0xFF	; G 			[0][48]
	.db	0xFF, 0x99, 0x99, 0x81, 0x99, 0x99, 0x99, 0xFF	; H 			[0][56]
	.db	0xFF, 0xC3, 0xE7, 0xE7, 0xE7, 0xE7, 0xC3, 0xFF	; I 			[0][64]
	.db	0xFF, 0x83, 0xE7, 0xE7, 0xE7, 0xE7, 0x8F, 0xFF	; J 			[0][72]
	.db	0xFF, 0x99, 0x93, 0x87, 0x87, 0x93, 0x99, 0xFF	; K 			[0][80]
	.db	0xFF, 0x9F, 0x9F, 0x9F, 0x9F, 0x9F, 0x83, 0xFF	; L 			[0][88]
	.db	0xFF, 0xBD, 0x99, 0x81, 0x99, 0x99, 0x99, 0xFF	; M 			[0][96]
	.db	0xFF, 0xB9, 0x99, 0x89, 0x91, 0x99, 0x9D, 0xFF	; N 			[0][104]
	.db	0xFF, 0xC3, 0x99, 0x99, 0x99, 0x99, 0xC3, 0xFF	; O 			[0][112]
	.db	0xFF, 0x83, 0x99, 0x99, 0x83, 0x9F, 0x9F, 0xFF	; P 			[0][120]
	.db	0xFF, 0xC3, 0x9D, 0x9D, 0x99, 0x93, 0xC5, 0xFF	; Q 			[0][128]
	.db	0xFF, 0x83, 0x99, 0x99, 0x83, 0x97, 0x99, 0xFF	; R 			[0][136]
	.db	0xFF, 0xC3, 0x9F, 0xC3, 0xF9, 0xF9, 0xC3, 0xFF	; S 			[0][144]
	.db	0xFF, 0x81, 0xE7, 0xE7, 0xE7, 0xE7, 0xE7, 0xFF	; T 			[0][152]
	.db	0xFF, 0x99, 0x99, 0x99, 0x99, 0x99, 0xC3, 0xFF	; U 			[0][160]
	.db	0xFF, 0x99, 0x99, 0x99, 0xDB, 0xC3, 0xE7, 0xFF	; V 			[0][168]
	.db	0xFF, 0x99, 0x99, 0x99, 0x81, 0x99, 0xBD, 0xFF	; W 			[0][176]
	.db	0xFF, 0x99, 0xC3, 0xE7, 0xE7, 0xC3, 0x99, 0xFF	; X 			[0][184]
	.db	0xFF, 0x99, 0x99, 0xC3, 0xE7, 0xE7, 0xE7, 0xFF	; Y 			[0][192]
	.db	0xFF, 0x81, 0xF9, 0xF3, 0xE7, 0xCF, 0x81, 0xFF	; Z 			[0][200]
	.db	0xFF, 0xCF, 0xCF, 0xCF, 0xEF, 0xFF, 0xEF, 0xFF	; ! 			[0][208]
	.db	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xCF, 0xCF, 0xFF	; .				[0][216]
	.db 0xFF, 0xFF, 0xFF, 0xC3, 0xC3, 0xFF, 0xFF, 0xFF	; - 			[0][224]
	.db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF	; SPACE			[0][232]
	.db 0xFF, 0xE7, 0xCF, 0xCF, 0xCF, 0xCF, 0xE7, 0xFF ; (				[0][240]
	.db 0xFF, 0xE7, 0xF3, 0xF3, 0xF3, 0xF3, 0xE7, 0xFF ; )				[0][248]

	.db 0xDB, 0xE7, 0x81, 0x24, 0x00, 0xDB, 0xA5, 0x7E	; alien1		[1][0]
	.db 0xE7, 0xC3, 0x81, 0x24, 0x00, 0xDB, 0xA5, 0x5A	; alien2		[1][8]

	.db 0xFF, 0xFF, 0xDB, 0xE7, 0xE7, 0xDB, 0xFF, 0xFF ; bang1			[1][16]
	.db 0x7E, 0xA5, 0xC3, 0x81, 0x81, 0xC3, 0xA5, 0x7E ; bang2			[1][24]
	.db 0x24, 0x00, 0x81, 0x00, 0x00, 0x81, 0x00, 0x24 ; bang3			[1][32]

nickname:	; string length = 6
	.db 0, 152, 0, 88, 224, 184

message:	; string length = 50
	.db 48, 136, 32, 32, 152, 64, 104, 48, 144, 232, 152, 112, 232, 120, 136, 0, 32, 152, 112, 232, 240, 96, 112, 160
	.db 136, 64, 24, 64, 144, 248, 232, 0, 104, 24, 232, 144, 160, 8, 200, 32, 136, 112, 232, 240, 16, 168, 0, 136, 248, 208

; **************************************************
; * microcontroller initialization
; **************************************************

mcu_init:
	ldi tmp1, $df					; Stack Pointer setup 
	out SPL, tmp1

	ser tmp1
	out DDRA, tmp1					; all porta pins as outputs
	out DDRB, tmp1					; all portb pins as outputs
	out DDRD, tmp1					; all portd pins as outputs

	sbi ACSR, ACD					; turn off analog comparator
	cbi	ACSR, ACBG					; disconnect analog comparator from internal voltage reference

	in tmp1, MCUSR					;
	andi tmp1, 0b11110111			; clear WDRF in MCUSR
	out MCUSR, tmp1					;

	in tmp1, WDTCR					; write logical one to WDCE and WDE
	ori tmp1, 0b00011000			; keep old prescaler setting to prevent unintentional time-out
	out WDTCR, tmp1					;
	clr	tmp1						;
	out WDTCR, tmp1					; turn off watchdog timer

; **************************************************
; * print loop for all messages
; **************************************************

; AVAILABLE METHODS:___________________________________________________________________________________________________________
;	ldi tmp1, m					; reading address offset (low byte)
;	ldi tmp2, n					; reading address offset (high byte)
;	rcall flash2regfile			; copy from flash to register file
;								;
;	rcall copy_from_sec			; copy data from secondary buffer to primary
;	rcall clear_sec				; clear secondary buffer
;								;
;	rcall left_loop				; shift secondary buffer into primary (from right to left) and the primary accordingly
;	rcall right_loop			; shift secondary buffer into primary (from left to right) and the primary accordingly
;	rcall down_loop				; shift secondary buffer into primary (from up to down) and the primary accordingly
;	rcall up_loop				; shift secondary buffer into primary (from down to up) and the primary accordingly
;								;
;	ldi tmp1, k					;
;	rcall scan_loop				; scan primary buffer k times


main_loop:

; ------------------------------ my nickname as described in "nickname" table
	rcall clear_sec
	rcall copy_from_sec
	ldi tmp1, 32
	rcall scan_loop

	ldi tmp1, 40
	clr tmp2
	rcall flash2regfile
	rcall right_loop
	ldi tmp1, 32
	rcall scan_loop

	clr tmp3
type_nickname:
	ldi ZH, high (nickname * 2)		; starting address of table with nickname letters
	ldi ZL, low (nickname * 2)		; starting address of table with nickname letters

	clr tmp2						; prepare offset for character table reading
	add ZL, tmp3
	adc ZH, tmp2

	lpm	tmp1, Z						; load letter address
	rcall flash2regfile				;
	rcall left_loop					; shift buffer with loaded letter

	inc tmp3
	cpi tmp3, 6						; check if reached string length
	brne type_nickname

	ldi tmp1,180
	rcall scan_loop
	ldi tmp1,180
	rcall scan_loop
; ------------------------------ alien 1
	rcall clear_sec
	rcall copy_from_sec
	ldi tmp1, 48
	rcall scan_loop

	ldi tmp1, 0
	ldi tmp2, 1
	rcall flash2regfile
	rcall up_loop

	ldi tmp1,200
	rcall scan_loop
	ldi tmp1,200
	rcall scan_loop
; ------------------------------ alien 2
	rcall clear_sec
	rcall copy_from_sec
	ldi tmp1, 48
	rcall scan_loop

	ldi tmp1,8
	ldi tmp2,1
	rcall flash2regfile
	rcall down_loop

	ldi tmp1,200
	rcall scan_loop
	ldi tmp1,200
	rcall scan_loop
; ------------------------------ a message as described in "message" table
	rcall clear_sec
	rcall copy_from_sec
	ldi tmp1, 32
	rcall scan_loop

	clr tmp3
type_message:
	ldi ZH, high (message * 2)		; starting address of table with message letters
	ldi ZL, low (message * 2)		; starting address of table with message letters

	clr tmp2						; prepare offset for character table reading
	add ZL, tmp3
	adc ZH, tmp2

	lpm	tmp1, Z						; load letter address
	rcall flash2regfile				;
	rcall left_loop					; shift buffer with loaded letter

	inc tmp3
	cpi tmp3, 50					; check if reached string length
	brne type_message

	ldi tmp1,150
	rcall scan_loop
	ldi tmp1,150
	rcall scan_loop

rjmp main_loop



; **************************************************
; * scan matrix line by line
; * repeat tmp1 times
; **************************************************

scan_loop:
	push tmp2

repeat_scan:
	sbr pa_data,0b00000001				; enable row 08 (topmost)
		mov tmp2,row8					; load row data from buffer
		rcall data_output
	sbr pd_data,0b00010000
		mov tmp2,row7
		rcall data_output
	sbr pd_data,0b00000010
		mov tmp2,row6
		rcall data_output
	sbr pd_data,0b00100000
		mov tmp2,row5
		rcall data_output
	sbr pb_data,0b00010000
		mov tmp2,row4
		rcall data_output
	sbr pd_data,0b00000001
		mov tmp2,row3
		rcall data_output
	sbr pb_data,0b00000100
		mov tmp2,row2
		rcall data_output
	sbr pb_data,0b10000000
		mov tmp2,row1
		rcall data_output

	dec tmp1							; decrease tmp1 (frame_cnt)
	brne repeat_scan					; if not zero, keep scanning

	pop tmp2
	ret

; **************************************************
; * turn appropriate columns on
; * output all data to ports
; * let row shine for a while
; **************************************************

data_output:
	sbrc tmp2,7							; LED is on if corresponding data bit is clear
	sbr pb_data,0b00000001				; if not, LED is switched off (inverse logic)
	sbrc tmp2,6
	sbr pb_data,0b00000010
	sbrc tmp2,5
	sbr pb_data,0b00100000
	sbrc tmp2,4
	sbr pa_data,0b00000010
	sbrc tmp2,3
	sbr pb_data,0b01000000
	sbrc tmp2,2
	sbr pd_data,0b00000100
	sbrc tmp2,1
	sbr pd_data,0b00001000
	sbrc tmp2,0
	sbr pb_data,0b00001000

	out PORTA,pa_data					; output all data
	out PORTB,pb_data					;
	out PORTD,pd_data					;

	clr pa_data							; "prepare" port data registers for next row
	clr pb_data							;
	clr pd_data							;

	clr tmp2							;
wait:									; small delay for leds to shine...
	dec tmp2							;
	brne wait							;

	ret

; **************************************************
; * copy parts of flash table to secondary buffer
; * tmp2:tmp1 represents the address offset
; **************************************************

flash2regfile:
	clr YH								;
	ldi YL,0x11							; register file pointer => start of secondary buffer

	ldi ZH,high (data_table * 2)		; starting address of flash table
	ldi ZL,low (data_table * 2)			; starting address of flash table
	add ZL,tmp1							; add address offset
	adc ZH,tmp2							; add address offset

init_load:
	ldi tmp1,8							; counter for bytes to be transfered
load_loop:
	lpm									; load from flash memory
	adiw ZL,1							;
	st -Y,r0							; store in register file
	dec tmp1							; decrease byte counter
	brne load_loop						; repeat until counter=0
ret

; **************************************************
; * scroll old frame out - new frame in (left)
; * scroll old frame out - new frame in (right)
; * scroll old frame out - new frame in (up)
; * scroll old frame out - new frame in (down)
; **************************************************

copy_from_sec:
	mov row8,alt_row8
	mov row7,alt_row7
	mov row6,alt_row6
	mov row5,alt_row5
	mov row4,alt_row4
	mov row3,alt_row3
	mov row2,alt_row2
	mov row1,alt_row1
ret
; ***************
clear_sec:
	ser tmp1
	mov alt_row8,tmp1
	mov alt_row7,tmp1
	mov alt_row6,tmp1
	mov alt_row5,tmp1
	mov alt_row4,tmp1
	mov alt_row3,tmp1
	mov alt_row2,tmp1
	mov alt_row1,tmp1
ret
; ***************
left:
	rol alt_row8
	rol row8
	rol alt_row7
	rol row7
	rol alt_row6
	rol row6
	rol alt_row5
	rol row5
	rol alt_row4
	rol row4
	rol alt_row3
	rol row3
	rol alt_row2
	rol row2
	rol alt_row1
	rol row1

	ldi tmp1,scroll_speed
	rcall scan_loop
ret
; ***************
right:
	ror alt_row8
	ror row8
	ror alt_row7
	ror row7
	ror alt_row6
	ror row6
	ror alt_row5
	ror row5
	ror alt_row4
	ror row4
	ror alt_row3
	ror row3
	ror alt_row2
	ror row2
	ror alt_row1
	ror row1

	ldi tmp1,scroll_speed
	rcall scan_loop
ret
; ***************
up:
	mov row8,row7
	mov row7,row6
	mov row6,row5
	mov row5,row4
	mov row4,row3
	mov row3,row2
	mov row2,row1
	mov row1,alt_row8
	mov alt_row8,alt_row7
	mov alt_row7,alt_row6
	mov alt_row6,alt_row5
	mov alt_row5,alt_row4
	mov alt_row4,alt_row3
	mov alt_row3,alt_row2
	mov alt_row2,alt_row1
	ser tmp1
	mov alt_row1,tmp1

	ldi tmp1,scroll_speed
	rcall scan_loop
ret
; ***************
down:
	mov row1,row2
	mov row2,row3
	mov row3,row4
	mov row4,row5
	mov row5,row6
	mov row6,row7
	mov row7,row8
	mov row8,alt_row1
	mov alt_row1,alt_row2
	mov alt_row2,alt_row3
	mov alt_row3,alt_row4
	mov alt_row4,alt_row5
	mov alt_row5,alt_row6
	mov alt_row6,alt_row7
	mov alt_row7,alt_row8
	ser tmp1
	mov alt_row8,tmp1

	ldi tmp1,scroll_speed
	rcall scan_loop
ret
; ***************
left_loop:
	ldi tmp2,8
left_loop1:
	rcall left
	dec tmp2
	brne left_loop1
ret
; ***************
right_loop:
	ldi tmp2,8
right_loop1:
	rcall right
	dec tmp2
	brne right_loop1
ret
; ***************
up_loop:
	ldi tmp2,8
up_loop1:
	rcall up
	dec tmp2
	brne up_loop1
ret
; ***************
down_loop:
	ldi tmp2,8
down_loop1:
	rcall down
	dec tmp2
	brne down_loop1
ret
