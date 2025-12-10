.model small
.stack 100h

.data
color_table db 4, 2           ; 1 = red, 2 = green
current_color db 4            ; default color = red

.code
main proc
    mov ax, @data             ; load data segment
    mov ds, ax                ; set DS

    mov ax, 0013h             ; enter mode 13h
    int 10h

    mov ax, 0A000h            ; video memory segment
    mov es, ax

    mov ax, 0                 ; mouse reset
    int 33h

    mov ax, 2                 ; hide mouse cursor
    int 33h

    call paint_start          ; begin paint loop

    mov ax, 0003h             ; return to text mode
    int 10h

    mov ax, 4C00h             ; exit program
    int 21h
main endp


paint_start proc
main_key_loop:
    mov ah, 0                 ; wait for key
    int 16h                   ; AL = pressed key

    cmp al, 1Bh               ; ESC key?
    je paint_exit             ; if yes, exit loop

    call change_color         ; update color if key = 1 or 2
    call mouse_paint          ; paint while key isn't pressed

    jmp main_key_loop         ; repeat

paint_exit:
    ret
paint_start endp


change_color proc
    sub al, '1'               ; convert '1'→0, '2'→1
    cmp al, 0                 ; below 0?
    jl cc_invalid             ; ignore invalid input
    cmp al, 1                 ; above 1?
    jg cc_invalid             ; ignore invalid input

    mov bl, al                ; BL = index (0 or 1)
    mov al, color_table[bx]   ; AL = color value
    mov current_color, al     ; update active color

cc_invalid:
    ret
change_color endp


mouse_paint proc
paint_loop:
    mov ax, 3                 ; get mouse info
    int 33h                   ; BX = buttons, CX = X, DX = Y

    test bx, 1                ; is left button pressed?
    jz skip_draw              ; if no, skip drawing

    mov ax, dx                ; AX = Y
    mov bx, 320               ; 320 bytes per scanline
    mul bx                    ; AX = Y * 320
    add ax, cx                ; AX = Y*320 + X
    mov di, ax                ; DI = video offset

    mov al, current_color     ; get current color
    mov es:[di], al           ; draw pixel

skip_draw:
    mov ah, 1                 ; check if key waiting
    int 16h
    jnz paint_done            ; if key press pending → exit

    jmp paint_loop            ; continue painting

paint_done:
    ret
mouse_paint endp

end main