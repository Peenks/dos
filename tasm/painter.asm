; Painter with invisible mouse cursor
; Mode 13h, left-click to paint, 1/2/3 = colors, ESC = exit

.model small
.stack 100h

.data
color_table    db 4, 2, 1      ; Red, Green, Blue
current_color  db 4            ; default = red (color index 0)

.code
main proc
    mov ax, @data
    mov ds, ax

    ; --- Enter graphics mode 13h ---
    mov ax, 0013h
    int 10h

    ; ES = video memory
    mov ax, 0A000h
    mov es, ax

    ; --- Initialize mouse ---
    mov ax, 0
    int 33h          ; mouse reset

    ; --- Hide mouse cursor ---
    mov ax, 2
    int 33h

    call paint_start

    ; --- Return to text mode 03h ---
    mov ax, 0003h
    int 10h

    mov ax, 4C00h
    int 21h
main endp


; ======================================================
; PAINT START
; ======================================================
paint_start proc
main_key_loop:

    mov ah, 0
    int 16h           ; wait for key, AL = ASCII

    cmp al, 1Bh       ; ESC
    je paint_exit

    call change_color
    call mouse_paint

    jmp main_key_loop

paint_exit:
    ret
paint_start endp


; ======================================================
; CHANGE COLOR (1,2,3)
; ======================================================
change_color proc
    sub al, '1'       ; '1'->0, '2'->1, '3'->2
    cmp al, 0
    jl cc_invalid
    cmp al, 2
    jg cc_invalid

    mov bl, al
    mov al, color_table[bx]
    mov current_color, al

cc_invalid:
    ret
change_color endp


; ======================================================
; MOUSE PAINT LOOP
; ======================================================
mouse_paint proc
paint_loop:

    ; get mouse status
    mov ax, 3
    int 33h           ; BX=buttons, CX=X, DX=Y

    test bx, 1
    jz skip_draw      ; left button NOT pressed

    ; compute offset = Y * 320 + X
    mov ax, dx        ; AX = Y
    mov bx, 320
    mul bx            ; AX = Y*320

    add ax, cx        ; + X
    mov di, ax

    ; draw pixel
    mov al, current_color
    mov es:[di], al

skip_draw:
    ; if key is waiting → return
    mov ah, 1
    int 16h
    jnz paint_done

    jmp paint_loop

paint_done:
    ret
mouse_paint endp

end main