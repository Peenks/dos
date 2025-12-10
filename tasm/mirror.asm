.model small
.stack 100h

.data
msg db "Justin Chris",0

.code
main proc
    mov ax, @data
    mov ds, ax

    mov bx, 10        ; repeat 10 times

repeat_line:
    mov si, offset msg

; ---- PRINT NORMAL TEXT ----
print_normal:
    mov dl, [si]
    cmp dl, 0
    je move_to_right
    mov ah, 02h
    int 21h
    inc si
    jmp print_normal

; ---- PRINT SPACES ----
move_to_right:
    mov ah, 02h
    mov dl, ' '
    mov cx, 40
print_spaces:
    int 21h
    loop print_spaces

; ---- FIND END OF STRING ----
    mov si, offset msg
find_end:
    cmp byte ptr [si], 0
    je back_one
    inc si
    jmp find_end

back_one:
    dec si        ; now SI = last character

; ---- PRINT IN REVERSE ----
print_reverse:
    mov dl, [si]
    mov ah, 02h
    int 21h

    cmp si, offset msg
    je do_newline
    dec si
    jmp print_reverse

; ---- NEW LINE ----
do_newline:
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    dec bx
    jnz repeat_line

; ---- EXIT PROGRAM ----
    mov ax, 4C00h
    int 21h
main endp

end main