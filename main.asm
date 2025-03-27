.model small
.stack 100h
.data
    ; Registration & Login Data
    username db 20 dup(0), '$'  ; Buffer for username (max 20 chars)
    password db 20 dup(0), '$'  ; Buffer for password
    loginMsg db 'Enter Username: $'
    passMsg  db 'Enter Password: $'
    successMsg db 'Login Successful!', 0Dh, 0Ah, '$'

    ; Destination & Date Data
    destPrompt db 'Enter Destination (1=NY, 2=LA, 3=SF): $'
    datePrompt db 'Enter Date (MMDD): $'
    destChoice db 0
    dateInput db 5 dup(0), '$'  ; MMDD + null

    ; Service Type Data
    servicePrompt db 'Service Type (1=Business, 2=Economy): $'
    serviceChoice db 0

    ; Promo Data
    promoPrompt db 'Apply Promo? (1=Elderly, 2=Kid, 0=None): $'
    promoChoice db 0

    ; Payment Data
    paymentPrompt db 'Enter Payment Amount: $'
    paymentAmount dw 0          ; 16-bit for simplicity (e.g., cents)
    basePriceBusiness dw 5000   ; $50.00 in cents
    basePriceEconomy  dw 3000   ; $30.00 in cents
    discountElderly   dw 1000   ; $10.00 off
    discountKid       dw 500    ; $5.00 off

    ; Information Display Data
    receiptMsg db '----- Receipt -----$'
    destMsg    db 'Destination: $'
    seatsMsg   db 'Seat: A1$', 0Dh, 0Ah  ; Hardcoded for simplicity
    departMsg  db 'Depart: 08:00$', 0Dh, 0Ah
    arriveMsg  db 'Arrive: 12:00$', 0Dh, 0Ah
    totalMsg   db 'Total Paid: $'
    newline    db 0Dh, 0Ah, '$'
    destNames  db 'NY$', 'LA$', 'SF$'

.code
main proc
    mov ax, @data
    mov ds, ax

    ; 1. Registration & Login
    call registration_login

    ; 2. Destination & Date Selection
    call dest_date_selection

    ; 3. Service Type Selection
    call service_type_selection

    ; 4. Promo Application
    call promo_application

    ; 5. Payment
    call payment_processing

    ; 6. Information Display
    call info_display

    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

; --- Module 1: Registration & Login ---
registration_login proc
    ; Prompt for username
    mov ah, 09h
    lea dx, loginMsg
    int 21h

    ; Input username (simple, no validation here)
    mov ah, 0Ah
    lea dx, username
    int 21h

    ; Prompt for password
    mov ah, 09h
    lea dx, passMsg
    int 21h

    ; Input password
    mov ah, 0Ah
    lea dx, password
    int 21h

    ; Simulate successful login (no real validation)
    mov ah, 09h
    lea dx, successMsg
    int 21h
    ret
registration_login endp

; --- Module 2: Destination & Date Selection ---
dest_date_selection proc
    ; Prompt for destination
    mov ah, 09h
    lea dx, destPrompt
    int 21h

    ; Get single digit input (1-3)
    mov ah, 01h
    int 21h
    sub al, '0'         ; Convert ASCII to number
    mov destChoice, al

    ; Newline
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Prompt for date
    mov ah, 09h
    lea dx, datePrompt
    int 21h

    ; Get date input (MMDD)
    mov ah, 0Ah
    lea dx, dateInput
    int 21h

    ; Newline
    mov ah, 09h
    lea dx, newline
    int 21h
    ret
dest_date_selection endp

; --- Module 3: Service Type Selection ---
service_type_selection proc
    mov ah, 09h
    lea dx, servicePrompt
    int 21h

    ; Get service type (1 or 2)
    mov ah, 01h
    int 21h
    sub al, '0'
    mov serviceChoice, al

    ; Newline
    mov ah, 09h
    lea dx, newline
    int 21h
    ret
service_type_selection endp

; --- Module 4: Promo Application ---
promo_application proc
    mov ah, 09h
    lea dx, promoPrompt
    int 21h

    ; Get promo choice (0-2)
    mov ah, 01h
    int 21h
    sub al, '0'
    mov promoChoice, al

    ; Newline
    mov ah, 09h
    lea dx, newline
    int 21h
    ret
promo_application endp

; --- Module 5: Payment Processing ---
payment_processing proc
    ; Calculate base price based on service type
    mov al, serviceChoice
    cmp al, 1
    je business_price
    mov ax, basePriceEconomy
    jmp apply_promo
business_price:
    mov ax, basePriceBusiness

apply_promo:
    ; Apply promo discount
    mov bl, promoChoice
    cmp bl, 1
    je elderly_discount
    cmp bl, 2
    je kid_discount
    jmp show_payment

elderly_discount:
    sub ax, discountElderly
    jmp show_payment
kid_discount:
    sub ax, discountKid

show_payment:
    mov paymentAmount, ax

    ; Prompt for payment (display only, assume paid)
    mov ah, 09h
    lea dx, paymentPrompt
    int 21h

    ; Simple output of amount (in cents, no conversion to dollars here)
    mov ax, paymentAmount
    call print_number

    ; Newline
    mov ah, 09h
    lea dx, newline
    int 21h
    ret
payment_processing endp

; --- Module 6: Information Display ---
info_display proc
    ; Display receipt header
    mov ah, 09h
    lea dx, receiptMsg
    int 21h
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Display destination
    mov ah, 09h
    lea dx, destMsg
    int 21h
    movzx bx, destChoice
    dec bx              ; Adjust for 0-based index
    mov ax, 3           ; Each name is 3 bytes (e.g., 'NY$')
    mul bx
    lea dx, destNames
    add dx, ax
    mov ah, 09h
    int 21h
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Display seat, depart, arrive (static for simplicity)
    mov ah, 09h
    lea dx, seatsMsg
    int 21h
    mov ah, 09h
    lea dx, departMsg
    int 21h
    mov ah, 09h
    lea dx, arriveMsg
    int 21h

    ; Display total paid
    mov ah, 09h
    lea dx, totalMsg
    int 21h
    mov ax, paymentAmount
    call print_number

    ; Newline
    mov ah, 09h
    lea dx, newline
    int 21h
    ret
info_display endp

; --- Utility: Print Number (AX) ---
print_number proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx          ; Counter for digits
convert_loop:
    xor dx, dx
    div bx              ; AX = quotient, DX = remainder
    add dl, '0'         ; Convert to ASCII
    push dx             ; Save digit
    inc cx
    test ax, ax
    jnz convert_loop

print_loop:
    pop dx
    mov ah, 02h
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_number endp

end main