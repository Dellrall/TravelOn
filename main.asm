INCLUDE Irvine32.inc

.data
    ; --- Registration & Login ---
    username BYTE 20 DUP(0)
    password BYTE 20 DUP(0)
    loginMsg BYTE "Enter Username: ", 0
    passMsg  BYTE "Enter Password: ", 0
    successMsg BYTE "Login Successful!", 0Dh, 0Ah, 0
    asterisk BYTE "*", 0      ; Asterisk character for masking
    MAX_PASSWORD_LENGTH = 20  ; Maximum password length
    welcomeMsg BYTE "Welcome to TravelOn Bus reservation system", 0

    ; --- Destination & Date ---
    destPrompt BYTE "Enter Destination (1=KL, 2=PH, 3=JB): ", 0
    datePrompt BYTE "Enter Date (MMDD): ", 0
    destChoice BYTE 0
    dateInput BYTE 5 DUP(0)
    destNames BYTE "KL", 0, "PH", 0, "JB", 0
    invalidDateMsg BYTE "Invalid date format. Please enter MMDD format (e.g., 0411)", 0Dh, 0Ah, 0
    confirmDateMsg BYTE "Selected date is: ", 0
    daysOfWeek    BYTE "Sunday", 0, "Monday", 0, "Tuesday", 0, "Wednesday", 0
              BYTE "Thursday", 0, "Friday", 0, "Saturday", 0
    dayMsg        BYTE " (", 0
    dayMsgEnd     BYTE ")", 0Dh, 0Ah, 0
    confirmPrompt BYTE "Proceed with this date? (1=Yes, 0=No): ", 0

    ; --- Service Type ---
    servicePrompt BYTE "Service Type (1=Business, 2=Economy): ", 0
    serviceChoice BYTE 0

    ; --- Promo ---
    promoPrompt BYTE "Apply Promo? (1=Elderly, 2=Kid, 0=None): ", 0
    promoChoice BYTE 0

    ; --- Pricing ---
    basePriceBusiness WORD 5000      ; RM50.00
    basePriceEconomy  WORD 3000      ; RM30.00
    discountElderly   WORD 1000      ; RM10.00
    discountKid       WORD 500       ; RM5.00
    baseFinal WORD 0
    sstAmount WORD 0
    paymentAmount WORD 0

    ; --- Display Messages ---
    paymentPrompt BYTE "Enter Payment Amount: RM", 0
    receiptMsg BYTE "----- Receipt -----", 0Dh, 0Ah, 0
    destMsg    BYTE "Destination: ", 0
    seatsMsg   BYTE "Seat: A1", 0Dh, 0Ah, 0
    departMsg  BYTE "Depart: 08:00", 0Dh, 0Ah, 0
    arriveMsg  BYTE "Arrive: 12:00", 0Dh, 0Ah, 0
    sstMsg     BYTE "SST (6%): RM", 0
    totalMsg   BYTE "Total Paid: RM", 0
    newline    BYTE 0Dh, 0Ah, 0

.code
main PROC
    call registration_login
    call dest_date_selection
    call service_type_selection
    call promo_application
    call payment_processing
    call info_display
    exit
main ENDP

; --- Module 1: Registration ---
registration_login PROC
    ; Input Username (unchanged)
    mov edx, OFFSET loginMsg
    call WriteString
    mov edx, OFFSET username
    mov ecx, SIZEOF username
    call ReadString

    ; Check for null username (unchanged)
    mov al, username
    cmp al, 0
    je username_empty
username_valid:

    ; Input Password with masking
    mov edx, OFFSET passMsg
    call WriteString
    
    ; Initialize
    mov edi, OFFSET password  ; Destination for password
    xor ecx, ecx             ; Character count
    
read_char:
    call ReadChar            ; Read a single character
    
    ; Check if Enter key was pressed (0Dh)
    cmp al, 0Dh
    je end_password
    
    ; Check if backspace (08h)
    cmp al, 08h
    je handle_backspace
    
    ; Check if maximum length reached
    cmp ecx, MAX_PASSWORD_LENGTH
    jae read_char
    
    ; Store character and display asterisk
    mov [edi], al           ; Store actual character
    inc edi                 ; Move to next position
    inc ecx                 ; Increment counter
    
    push eax                ; Save actual character
    mov al, '*'            ; Load asterisk
    call WriteChar         ; Display asterisk
    pop eax                ; Restore actual character
    jmp read_char

handle_backspace:
    ; Handle backspace only if there are characters
    cmp ecx, 0
    je read_char
    
    ; Move cursor back, write space, move cursor back again
    dec edi                ; Move back in buffer
    dec ecx                ; Decrease counter
    
    ; Clear last character on screen
    mov al, 08h           ; Backspace
    call WriteChar
    mov al, ' '           ; Space
    call WriteChar
    mov al, 08h           ; Backspace
    call WriteChar
    jmp read_char

end_password:
    mov byte ptr [edi], 0   ; Null terminate the string
    call Crlf               ; New line after password entry

    ; Check for null password
    cmp ecx, 0
    je password_empty

    ; Continue with password hashing (unchanged)
    mov esi, OFFSET password    
    xor eax, eax               
    mov ecx, SIZEOF password   
hash_loop:
    mov al, [esi]              
    test al, al                
    je hash_done              
    xor ah, al                
    inc esi                   
    loop hash_loop
hash_done:
    mov [password], ah        

    ; Clear registration data
    mov edi, OFFSET username
    mov ecx, SIZEOF username
    xor eax, eax
    rep stosb                 ; Clear username buffer

    mov edi, OFFSET password
    mov ecx, SIZEOF password
    xor eax, eax
    rep stosb                 ; Clear password buffer

    ; Success Message
    mov edx, OFFSET successMsg
    call WriteString
    
    ; Display Welcome Message
    mov edx, OFFSET welcomeMsg
    call WriteString
    mov edx, OFFSET username    ; Display the username
    call WriteString
    call Crlf                  ; New line after welcome message

    ret

username_empty:
    mov edx, OFFSET loginMsg
    call WriteString
    jmp registration_login

password_empty:
    mov edx, OFFSET passMsg
    call WriteString
    jmp registration_login
registration_login ENDP

; --- Module 2: Destination ---
dest_date_selection PROC
    mov edx, OFFSET destPrompt
    call WriteString
    call ReadInt
    ; Add validation here
    cmp al, 1
    jl invalid_dest    ; If less than 1
    cmp al, 3
    jg invalid_dest    ; If greater than 3
    mov destChoice, al
    jmp valid_dest

invalid_dest:
    jmp dest_date_selection  ; Ask again for valid input
valid_dest:
    ; Continue with date input

date_input:
    mov edx, OFFSET datePrompt
    call WriteString
    mov edx, OFFSET dateInput
    mov ecx, SIZEOF dateInput
    call ReadString

    ; Validate length (should be 4 characters)
    cmp eax, 4
    jne invalid_date

    ; Convert and validate month (01-12)
    mov esi, OFFSET dateInput
    xor eax, eax
    mov al, [esi]        ; First digit of month
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, [esi+1]      ; Second digit of month
    sub bl, '0'
    add al, bl           ; AL now contains month number
    
    cmp al, 1
    jl invalid_date
    cmp al, 12
    jg invalid_date

    ; Convert and validate day (01-31)
    xor eax, eax
    mov al, [esi+2]      ; First digit of day
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, [esi+3]      ; Second digit of day
    sub bl, '0'
    add al, bl           ; AL now contains day number

    cmp al, 1
    jl invalid_date
    cmp al, 31
    jg invalid_date
    
    ; Display confirmation
    mov edx, OFFSET confirmDateMsg
    call WriteString
    mov edx, OFFSET dateInput
    call WriteString
    call Crlf

    ; Ask for confirmation
confirm_date:
    mov edx, OFFSET confirmPrompt
    call WriteString
    call ReadInt
    cmp al, 1
    je date_confirmed
    cmp al, 0
    je date_input      ; If not confirmed, ask for date again
    jmp confirm_date   ; If invalid input, ask again

invalid_date:
    mov edx, OFFSET invalidDateMsg
    call WriteString
    jmp date_input

date_confirmed:
    ret
dest_date_selection ENDP

; --- Module 3: Service ---
service_type_selection PROC
    mov edx, OFFSET servicePrompt
    call WriteString
    call ReadInt
    mov serviceChoice, al
    ret
service_type_selection ENDP

; --- Module 4: Promo ---
promo_application PROC
    mov edx, OFFSET promoPrompt
    call WriteString
    call ReadInt
    mov promoChoice, al
    ret
promo_application ENDP

; --- Module 5: Payment & SST ---
payment_processing PROC
    ; Get base price
    movzx eax, serviceChoice
    cmp al, 1
    je business_price
    mov ax, basePriceEconomy
    jmp apply_promo
business_price:
    mov ax, basePriceBusiness

apply_promo:
    movzx ebx, promoChoice
    cmp bl, 1
    je elderly_discount
    cmp bl, 2
    je kid_discount
    jmp save_final
elderly_discount:
    sub ax, discountElderly
    jmp save_final
kid_discount:
    sub ax, discountKid

save_final:
    mov baseFinal, ax

    ; Calculate SST (6%)
    movzx eax, baseFinal
    xor edx, edx
    mov ecx, 6
    mul ecx
    mov ecx, 100
    div ecx              ; EAX = SST
    mov sstAmount, ax

    ; Total = baseFinal + SST
    movzx eax, baseFinal
    movzx ebx, sstAmount
    add eax, ebx
    mov paymentAmount, ax

    ; Display payment amount
    mov edx, OFFSET paymentPrompt
    call WriteString
    call print_price
    call Crlf
    ret
payment_processing ENDP

; --- Module 6: Display Receipt ---
info_display PROC
    mov edx, OFFSET receiptMsg
    call WriteString

    ; Destination
    mov edx, OFFSET destMsg
    call WriteString
    movzx eax, destChoice
    dec eax
    mov ebx, TYPE destNames
    mul ebx
    add eax, OFFSET destNames
    mov edx, eax
    call WriteString
    call Crlf

    ; Seat, Depart, Arrive
    mov edx, OFFSET seatsMsg
    call WriteString
    mov edx, OFFSET departMsg
    call WriteString
    mov edx, OFFSET arriveMsg
    call WriteString

    ; SST
    mov edx, OFFSET sstMsg
    call WriteString
    movzx eax, sstAmount
    call print_price
    call Crlf

    ; Total Paid
    mov edx, OFFSET totalMsg
    call WriteString
    movzx eax, paymentAmount
    call print_price
    call Crlf
    ret
info_display ENDP

; --- Utility: Print RM amount from cents (e.g., 1234 = RM12.34) ---
print_price PROC
    ; Input: EAX = amount in cents
    push ax
    push dx

    xor edx, edx
    mov ebx, 100
    div ebx             ; EAX = RM, EDX = cents

    call WriteDec
    mov dl, '.'
    call WriteChar

    mov eax, edx
    cmp eax, 10
    jae print_cents
    mov dl, '0'
    call WriteChar
print_cents:
    mov eax, edx
    call WriteDec

    pop dx
    pop ax
    ret
print_price ENDP

END main
