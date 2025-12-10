.model small
.code

start:
    mov ax,0B800h
    mov es,ax
    mov cx,80
    xor di,di

L:
 mov byte ptr es:[di],'A'
 mov bx,0FFFFh

D: 
 dec bx
 jnz D
 mov byte ptr es:[di],' '
 add di,2
 loop L
 mov ax,4C00h
 int 21h
 
end start
