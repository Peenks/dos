.model small                 ; use small EXE memory model
.code

start:
    mov ax,0B800h            ; load video memory segment for text mode
    mov es,ax                ; set ES = video memory

    mov cx,80                ; repeat 80 times (80 columns)
    xor di,di                ; start at offset 0 in video memory

L:
    mov byte ptr es:[di],'A' ; put 'A' character on screen
    mov bx,0FFFFh            ; set delay counter

D:
    dec bx                   ; decrease delay counter
    jnz D                    ; loop until BX becomes zero

    mov byte ptr es:[di],' ' ; erase the 'A' after delay
    add di,2                 ; move to next screen cell (character + attribute)
    loop L                   ; repeat for next column

    mov ax,4C00h             ; exit program
    int 21h

end start                    ; end program and set entry point