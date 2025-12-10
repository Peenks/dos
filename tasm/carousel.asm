.model small
.stack 100h

.data
msg db " THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG "
len equ ($ - msg)

.code
main proc
    mov ax, @data
    mov ds, ax

    mov si, 0

main_loop:

    ; Print exactly 80 columns
    mov cx, 80
    mov di, si

print_loop:
    mov dl, [msg + di]
    mov ah, 02h
    int 21h

    inc di
    cmp di, len
    jb ok
    mov di, 0
ok:
    loop print_loop

    ; newline
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ; ------------------------------------
    ; ✨ BALANCED DELAY — smooth animation
    ; ------------------------------------
    mov cx, 200
delay_outer:
        mov dx, 500
    delay_inner:
        dec dx
        jnz delay_inner
    loop delay_outer

    ; clear screen
    mov ax, 3
    int 10h

    ; rotate left
    inc si
    cmp si, len
    jb main_loop
    mov si, 0
    jmp main_loop

main endp
end main