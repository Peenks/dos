.model small                        ; use small memory model (EXE)
.stack 100h                         ; create 256-byte stack

.data
num1    db ?                        ; holds user input number
result  dw 0                        ; running total (word)
msg1    db 'Enter a number: $'      ; prompt message
msg2    db 'Sum is: $'              ; output label
minus   db '-$'                     ; minus sign for negatives
newline db 13,10,'$'                ; newline characters
temp    db 0                        ; flag for negative input
prompt_continue db 13,10,'Do you want to enter another? (Y/N): $' ; prompt

.code
main proc
    mov ax, @data                   ; load data segment address
    mov ds, ax                      ; set DS to data segment

input_loop:
    mov dx, offset msg1             ; load address of input prompt
    mov ah, 9                       ; print string function
    int 21h                         ; display prompt

    call input                      ; read number into AL
    mov num1, al                    ; store input byte

    mov al, num1                    ; load number
    cbw                              ; sign-extend into AX
    add result, ax                  ; add to running sum

    mov dx, offset msg2             ; load "Sum is:" message
    mov ah, 9                       ; print string
    int 21h                         ; display it

    mov ax, result                  ; move sum into AX
    call output                     ; print number

    mov dx, offset prompt_continue  ; load continue prompt
    mov ah, 9                       ; print string
    int 21h                         ; display it

    mov ah, 1                       ; read key
    int 21h                         ; AL = key
    cmp al, 'Y'                     ; check uppercase Y
    je add_newline                  ; jump if Y
    cmp al, 'y'                     ; check lowercase y
    je add_newline                  ; jump if y
    jmp exit_program                ; otherwise exit

add_newline:
    mov dx, offset newline          ; load newline
    mov ah, 9                       ; print string
    int 21h                         ; print newline
    jmp input_loop                  ; loop back

exit_program:
    mov ax, 4C00h                   ; exit code 0
    int 21h                         ; return to DOS

main endp


input proc
    xor bx, bx                      ; clear BX
    mov temp, 0                     ; reset sign flag

    mov ah, 1                       ; read char
    int 21h                         ; AL = key

    cmp al, '-'                     ; check minus
    jne first_digit                 ; skip if not '-'
    mov temp, 1                     ; mark negative
    mov ah, 1                       ; read next char
    int 21h

first_digit:
    and al, 0Fh                     ; convert ASCII to number
    mov bl, al                      ; store first digit

    mov ah, 1                       ; read next key
    int 21h
    cmp al, 13                      ; ENTER pressed?
    je finish                       ; if yes, number is one digit

    and al, 0Fh                     ; convert to number
    mov bh, al                      ; store second digit

    mov al, bl                      ; first digit in AL
    mov bl, 10                      ; multiply by 10
    mul bl                          ; AX = AL * 10
    add al, bh                      ; add second digit
    mov bl, al                      ; final number stored

    mov ah, 1                       ; read and discard ENTER
    int 21h

finish:
    mov al, bl                      ; move number to AL
    cmp temp, 1                     ; was negative?
    jne return_input                ; skip negation
    neg al                          ; make AL negative

return_input:
    ret                             ; return to caller
input endp


output proc
    test ax, ax                     ; check if negative
    jns pos                         ; jump if positive

    push ax                         ; save value
    mov dx, offset minus            ; load "-" string
    mov ah, 9                       ; print string
    int 21h                         ; print '-'
    pop ax                          ; restore number
    neg ax                          ; make positive

pos:
    mov cx, 0                       ; digit counter
    mov bx, 10                      ; divisor = 10

div_loop:
    xor dx, dx                      ; clear DX for division
    div bx                          ; AX / 10, remainder in DX
    push dx                         ; store remainder
    inc cx                          ; count digit
    test ax, ax                     ; done dividing?
    jnz div_loop                    ; loop until AX = 0

print_loop:
    pop dx                          ; get digit
    add dl, '0'                     ; convert to ASCII
    mov ah, 2                       ; print char
    int 21h                         ; display digit
    loop print_loop                 ; repeat until done

    mov dx, offset newline          ; load newline
    mov ah, 9                       ; print string
    int 21h                         ; display newline
    ret                             ; return
output endp

end main                           ; end of program