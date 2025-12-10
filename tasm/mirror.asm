.model small                 ; use small EXE model
.stack 100h                  ; create stack

.data
msg db "Justin Chris",0      ; string ending with null byte

.code
main proc
    mov ax, @data            ; load data segment address
    mov ds, ax               ; set DS for data access

    mov bx, 10               ; repeat printing 10 times

repeat_line:
    mov si, offset msg       ; SI points to start of string

print_normal:
    mov dl, [si]             ; load current character
    cmp dl, 0                ; end of string?
    je move_to_right         ; if 0, go print spaces
    mov ah, 02h              ; DOS print char
    int 21h                  ; output character
    inc si                   ; move to next character
    jmp print_normal         ; continue printing

move_to_right:
    mov ah, 02h              ; DOS print char
    mov dl, ' '              ; load space character
    mov cx, 40               ; print 40 spaces
print_spaces:
    int 21h                  ; print space
    loop print_spaces        ; repeat 40 times

    mov si, offset msg       ; reset SI to start
find_end:
    cmp byte ptr [si], 0     ; check for null terminator
    je back_one              ; reached end of string
    inc si                   ; move forward
    jmp find_end             ; keep searching

back_one:
    dec si                   ; SI now points to last character

print_reverse:
    mov dl, [si]             ; load character in reverse order
    mov ah, 02h              ; DOS print char
    int 21h                  ; print it

    cmp si, offset msg       ; reached first character?
    je do_newline            ; if yes, go print newline
    dec si                   ; move backward
    jmp print_reverse        ; continue printing backward

do_newline:
    mov ah, 02h              ; DOS print char
    mov dl, 13               ; carriage return
    int 21h
    mov dl, 10               ; line feed
    int 21h

    dec bx                   ; decrease repetition counter
    jnz repeat_line          ; repeat if BX not zero

    mov ax, 4C00h            ; exit to DOS
    int 21h
main endp

end main