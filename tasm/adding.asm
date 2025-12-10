.model tiny
.code
org 100h

jmp main       ; Jump to main procedure

; Data segment embedded within code
num1    db  ?           ; first number
num2    db  ?           ; second number
result  dw  ?           ; result of addition
msg1    db  'Enter a number: $'
msg2    db  'Sum is: $'
minus   db  '-$'
newline db  13,10,'$'
temp    db  0           ; temporary storage for sign

main:
    ; Initialize data segment
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Clear the result
    mov result, 0

input_loop:
    ; display prompt
    mov dx, offset msg1
    mov ah, 9
    int 21h
    
    ; input a number
    call input
    mov num1, al        ; store the input number

    ; add number to running sum
    mov al, num1
    cbw                 ; convert byte to word (sign extend al to ax)
    mov bx, ax          ; save number in bx
    mov ax, result      ; load current result
    add ax, bx          ; add new number to result
    mov result, ax      ; store new result

    ; display result message
    mov dx, offset msg2
    mov ah, 9
    int 21h
    
    ; display result
    mov ax, result
    call output

    ; ask if the user wants to continue
    mov dx, offset newline
    mov ah, 9
    int 21h

    ; Display 'Do you want to enter another? (Y/N):'
    mov dx, offset prompt_continue
    mov ah, 9
    int 21h

    ; Get user input for continue or exit
    mov ah, 1           ; Function to read character input
    int 21h
    cmp al, 'Y'         ; Check if user wants to continue
    je input_loop       ; If 'Y', loop back for another input
    cmp al, 'y'         ; Check for lowercase 'y'
    je input_loop       ; If 'y', loop back for another input

    ; Exit the program if not 'Y' or 'y'
    mov ax, 4c00h
    int 21h

input proc
    xor bx, bx          ; clear bx to store result
    mov temp, 0         ; reset sign flag
    
    ; read first character (might be sign or digit)
    mov ah, 1
    int 21h
    
    ; check for minus sign
    cmp al, '-'
    jne not_minus
    mov temp, 1         ; set negative flag
    mov ah, 1           ; read next character (first digit)
    int 21h
    
not_minus:
    ; convert first digit
    and al, 0fh         ; convert ascii to number
    mov bl, al          ; store in bl
    
    ; read next character
    mov ah, 1
    int 21h
    
    ; check if it's enter (carriage return)
    cmp al, 13
    je finish_num
    
    ; process second digit
    and al, 0fh         ; convert ascii to number
    mov cl, al          ; save second digit in cl
    
    ; multiply first digit by 10
    mov al, bl
    mov bl, 10
    mul bl              ; ax = al * bl
    add al, cl          ; add second digit
    mov bl, al          ; store result in bl
    
    ; clear the enter key
    mov ah, 1
    int 21h
    
finish_num:
    mov al, bl          ; get final number in al
    
    ; make negative if needed
    cmp temp, 1
    jne done_input
    neg al              ; negate if negative
    
done_input:
    ret
input endp

output proc
    ; check if number is negative
    test ax, ax
    jns positive
    
    push ax
    mov dx, offset minus  ; display minus sign
    mov ah, 9
    int 21h
    pop ax
    neg ax                ; make number positive
    
positive:
    ; convert to decimal
    mov cx, 0           ; digit counter
    mov bx, 10
    
divide:
    xor dx, dx          ; clear dx for division
    div bx              ; divide by 10
    push dx             ; push remainder
    inc cx              ; increment counter
    test ax, ax
    jnz divide
    
    ; display digits
display_num:
    pop dx
    add dl, '0'         ; convert to ascii
    mov ah, 2
    int 21h
    loop display_num
    
    ; display newline
    mov dx, offset newline
    mov ah, 9
    int 21h
    ret
output endp

prompt_continue db 'Do you want to enter another? (Y/N): $'

end main