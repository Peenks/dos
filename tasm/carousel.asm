.model small                 ; use EXE memory model
.stack 100h                  ; define stack space

.data
msg db " 10% Discount off today! "   ; message to scroll
len equ ($ - msg)                    ; length of message

.code
main proc
    mov ax, @data           ; load data segment address
    mov ds, ax              ; set DS to data segment

    mov si, 0               ; starting index for scrolling

main_loop:
    mov cx, 80              ; print 80 characters
    mov di, si              ; DI = current scroll offset

print_loop:
    mov dl, [msg + di]      ; load next character
    mov ah, 02h             ; BIOS print char
    int 21h                 ; print it

    inc di                  ; move to next character
    cmp di, len             ; reached end of message?
    jb skip_reset
    mov di, 0               ; wrap back to start
skip_reset:
    loop print_loop         ; repeat until 80 chars printed

    mov ah, 02h             ; print newline (CR)
    mov dl, 13
    int 21h
    mov dl, 10             ; print newline (LF)
    int 21h

    mov cx, 200            ; outer delay counter
delay_outer:
        mov dx, 500        ; inner delay counter
    delay_inner:
        dec dx             ; countdown DX
        jnz delay_inner    ; loop inner delay
    loop delay_outer       ; loop outer delay

    mov ax, 3              ; clear screen (video mode 3)
    int 10h

    inc si                 ; shift message left
    cmp si, len            ; beyond end?
    jb main_loop           ; continue normally
    mov si, 0              ; wrap scroll index
    jmp main_loop          ; repeat forever

main endp
end main