INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096


; Add external declarations for Irvine32 functions
ExitProcess PROTO, dwExitCode:DWORD
WriteString PROTO
ReadString PROTO
WriteChar PROTO
ReadChar PROTO
WriteDec PROTO
ReadInt PROTO
Crlf PROTO
WriteInt PROTO

.data
    NUM_USERS = 5
    valid_users BYTE "Roziyani", 0, (20-8) DUP(0)    ; Pad to 20 bytes
                BYTE "Amos", 0, (20-4) DUP(0)         ; Pad to 20 bytes
                BYTE "Dell", 0, (20-4) DUP(0)         ; Pad to 20 bytes
                BYTE "Jason", 0, (20-5) DUP(0)        ; Pad to 20 bytes
                BYTE "Luian", 0, (20-5) DUP(0)        ; Pad to 20 bytes

    valid_passwords BYTE "Rz2023##", 0, (20-8) DUP(0)   ; Pad to 20 bytes
                   BYTE "Am@s456", 0, (20-7) DUP(0)     ; Pad to 20 bytes
                   BYTE "D3ll789", 0, (20-7) DUP(0)     ; Pad to 20 bytes
                   BYTE "Js0n#2k", 0, (20-7) DUP(0)     ; Pad to 20 bytes
                   BYTE "Lu!@n25", 0, (20-7) DUP(0)     ; Pad to 20 bytes

    invalidLoginMsg BYTE "Invalid username or password! Please try again.", 0Dh, 0Ah, 0
   ; --- Registration & Login ---
    username BYTE 20 DUP(0)
    password BYTE 20 DUP(0)
    loginMsg BYTE "Enter Username: ", 0
    passMsg  BYTE "Enter Password: ", 0
    successMsg BYTE "Login Successful!", 0Dh, 0Ah, 0
    asterisk BYTE "*", 0      ; Asterisk character for masking
    MAX_PASSWORD_LENGTH = 20  ; Maximum password length
    welcomeMsg BYTE "Welcome to TravelOn Bus reservation system, ", 0

    ; --- Destination & Date ---
    destPrompt BYTE "Enter Destination (1=Kuala Lumpur, 2=Kuantan, 3=Johor Bahru): ", 0
    departVenuePrompt BYTE "Enter Departure Venue (1=Kuala Lumpur, 2=Kuantan, 3=Johor Bahru): ", 0
    departChoice BYTE 0
    invalidDepartMsg BYTE "Error: Departure and destination cannot be the same!", 0Dh, 0Ah, 0
    datePrompt BYTE "Enter Date (MMDD): ", 0
    destChoice BYTE 0
    dateInput BYTE 5 DUP(0)
    destNames BYTE "KL", 0, "KT", 0, "JB", 0
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
    businessClassDesc BYTE "=== Business Class Experience ===", 0Dh, 0Ah
                 BYTE "* Luxurious reclining seats with extra legroom", 0Dh, 0Ah
                 BYTE "* Premium entertainment system with unlimited access", 0Dh, 0Ah
                 BYTE "* Gourmet meals and premium refreshments", 0Dh, 0Ah
                 BYTE "* Priority boarding and exclusive service", 0Dh, 0Ah
                 BYTE "* Personal power outlet and USB charging", 0Dh, 0Ah
                 BYTE "* Complimentary Wi-Fi access", 0Dh, 0Ah, 0

economyClassDesc BYTE "=== Economy Class Experience ===", 0Dh, 0Ah
                BYTE "* Comfortable standard seating", 0Dh, 0Ah
                BYTE "* Basic entertainment system access", 0Dh, 0Ah
                BYTE "* Complimentary meals and beverages", 0Dh, 0Ah
                BYTE "* Standard boarding process", 0Dh, 0Ah
                BYTE "* Shared power outlets available", 0Dh, 0Ah, 0

serviceClassHeader BYTE "Welcome to TravelOn Bus Service Class Selection", 0Dh, 0Ah
                  BYTE "Choose your preferred travel experience:", 0Dh, 0Ah, 0

     ; --- Seat Selection ---
    seatPrompt BYTE "Select your seat (e.g., A1) or enter 'B' to go back: ", 0
    seatLayout BYTE "     Business Class", 0Dh, 0Ah
              BYTE "   1  2     3  4", 0Dh, 0Ah
              BYTE "A [ ][ ]   [ ][ ]", 0Dh, 0Ah
              BYTE "B [ ][ ]   [ ][ ]", 0Dh, 0Ah
              BYTE "     Economy Class", 0Dh, 0Ah
              BYTE "C [ ][ ]   [ ][ ]", 0Dh, 0Ah
              BYTE "D [ ][ ]   [ ][ ]", 0Dh, 0Ah
              BYTE "E [ ][ ]   [ ][ ]", 0Dh, 0Ah, 0
              wrongClassMsg BYTE "This seat is not in your selected class!", 0Dh, 0Ah, 0
    businessSeats BYTE "AB"    ; Rows for business class
    economySeats  BYTE "CDE"   ; Rows for economy class
    selectedSeat BYTE 3 DUP(0) ; Store selected seat
    invalidSeatMsg BYTE "Invalid seat selection! Please try again.", 0Dh, 0Ah, 0
    seatTakenMsg BYTE "This seat is already taken! Please select another.", 0Dh, 0Ah, 0

    ; --- Promo ---
    promoPrompt BYTE "Apply Promo? (1=Elderly, 2=Kid, 0=None): ", 0
    promoChoice BYTE 0

    ; --- Pricing ---
    basePriceBusiness WORD 5000      ; RM50.00
    basePriceEconomy  WORD 3000      ; RM30.00
    discountElderly   WORD 1000      ; RM10.00
    discountKid       WORD 500       ; RM5.00
    baseTotalMsg    BYTE "Base Total: RM", 0
    totalAmountMsg  BYTE "Total Amount: RM", 0
    baseFinal WORD 0
    sstAmount WORD 0
    paymentAmount WORD 0
       paymentMerchantPrompt BYTE "Select Payment Method:", 0Dh, 0Ah
                         BYTE "1. Visa", 0Dh, 0Ah
                         BYTE "2. MasterCard", 0Dh, 0Ah
                         BYTE "3. UnionPay", 0Dh, 0Ah
                         BYTE "4. American Express", 0Dh, 0Ah
                         BYTE "Enter choice (1-4): ", 0
    invalidMerchantMsg BYTE "Invalid selection. Please try again.", 0Dh, 0Ah, 0
    insufficientMsg BYTE "Insufficient payment amount. Please enter at least RM", 0
    changeMsg BYTE "Your change: RM", 0
    merchantChoice BYTE 0
    selectedMerchant BYTE "Payment Method: ", 0
    merchantVisa BYTE "Visa", 0
    merchantMastercard BYTE "MasterCard", 0
    merchantUnionPay BYTE "UnionPay", 0
    merchantAmex BYTE "American Express", 0
    inputAmount DWORD 0
    changeAmount DWORD 0

    ; --- Display Messages ---
    paymentPrompt BYTE "Enter Payment Amount: RM", 0
    receiptMsg BYTE "----- Receipt -----", 0Dh, 0Ah, 0
    destMsg    BYTE "Destination: ", 0
    seatsMsg   BYTE "Seat: ", 0    ; Remove the hardcoded A1
    departureMsg BYTE "Departure: ", 0
    departMsg  BYTE "Depart: 08:00", 0Dh, 0Ah, 0
    arriveMsg  BYTE "Arrive: 12:00", 0Dh, 0Ah, 0
    sstMsg     BYTE "SST (6%): RM", 0
    totalMsg   BYTE "Total Paid: RM", 0
    newline    BYTE 0Dh, 0Ah, 0
cityNames    BYTE "Kuala Lumpur", 0, 7 DUP(0)     ; 20 bytes (13 + 7 padding)
            BYTE "Kuantan", 0, 12 DUP(0)          ; 20 bytes (8 + 12 padding)
            BYTE "Johor Bahru", 0, 9 DUP(0)       ; 20 bytes (11 + 9 padding)



.code
main PROC
    call registration_login
    call Crlf           ; Add space between modules
    call Crlf           ; Double space for better visibility

    call dest_date_selection
    call Crlf
    call Crlf

    call service_type_selection
    call Crlf
    call Crlf

    call promo_application
    call Crlf
    call Crlf

    call payment_processing
    call Crlf
    call Crlf

    call info_display
    call Crlf

    INVOKE ExitProcess, 0    ; Replace 'exit' with this
main ENDP

; --- Module 1: Registration ---
registration_login PROC
reg_login_start:
    ; Input Username
    mov edx, OFFSET loginMsg
    call WriteString
    mov edx, OFFSET username
    mov ecx, SIZEOF username
    call ReadString

    ; Check for null username
    cmp eax, 0
    je reg_username_empty

  ; Input Password with masking
    mov edx, OFFSET passMsg
    call WriteString
    
    ; Initialize password input
    mov edi, OFFSET password
    xor ecx, ecx             ; Character count
    
reg_read_char:
    call ReadChar            ; Read a single character
    
    ; Check if Enter key was pressed (0Dh)
    cmp al, 0Dh
    je reg_end_password
    
    ; Check if backspace (08h)
    cmp al, 08h
    je reg_handle_backspace
    
    ; Check if maximum length reached
    cmp ecx, MAX_PASSWORD_LENGTH
    jae reg_read_char
    
    ; Store actual character and display asterisk
    mov [edi], al           ; Store the actual character typed
    inc edi                 ; Move to next position
    inc ecx                 ; Increment counter
    
    ; Display asterisk instead of actual character
    push eax                ; Save actual character
    mov al, '*'            
    call WriteChar         ; Show asterisk
    pop eax                ; Restore actual character
    jmp reg_read_char

reg_handle_backspace:
    ; Handle backspace only if there are characters
    cmp ecx, 0
    je reg_read_char
    
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
    jmp reg_read_char

reg_end_password:
    mov byte ptr [edi], 0   ; Null terminate the password string
    call Crlf

    ; Check for null password
    cmp ecx, 0
    je reg_password_empty

    ; Validate credentials
    mov ecx, NUM_USERS          ; Number of users to check
    mov esi, OFFSET valid_users ; Point to first user
    mov edi, OFFSET valid_passwords ; Point to first password

check_user:
    push ecx                    ; Save counter
    push esi                    ; Save user pointer
    push edi                    ; Save password pointer

    ; Compare username
    mov edx, OFFSET username
    call strcmp                 ; Compare strings
    jnz next_credential        ; If not equal, try next user

    ; Username matches, now check password
    pop edi                    ; Get password pointer back for password comparison
    push edi                   ; Save it again for potential next iteration
    mov edx, OFFSET password
    mov esi, edi              ; Point ESI to current password
    call strcmp                ; Compare password
    je login_successful        ; If equal, login successful

next_credential:
    pop edi                    ; Restore pointers from stack
    pop esi
    pop ecx                    ; Restore counter
    add esi, 20               ; Move to next username (20 bytes per entry)
    add edi, 20               ; Move to next password
    dec ecx                   ; Decrease counter
    jnz check_user            ; Continue if more users to check
    
    ; If we get here, no match was found
    mov edx, OFFSET invalidLoginMsg
    call WriteString
    call Crlf
    jmp reg_login_start       ; Start over


login_successful:
    ; Clean up stack
    pop edi
    pop esi
    pop ecx

    ; Display success messages
    mov edx, OFFSET successMsg
    call WriteString
    
    mov edx, OFFSET welcomeMsg
    call WriteString
    mov edx, OFFSET username
    call WriteString
    call Crlf
    ret

reg_username_empty:
    jmp reg_login_start

reg_password_empty:
    mov edx, OFFSET passMsg
    call WriteString
    jmp reg_login_start

registration_login ENDP

; String comparison helper procedure
strcmp PROC
    ; EDX = input string, ESI = stored string
    push ecx
    push edx            ; Save original EDX
    push esi            ; Save original ESI

compare_loop:
    mov al, [edx]      ; Get character from input
    mov bl, [esi]      ; Get character from stored string
    
    ; Convert to uppercase for case-insensitive comparison (optional)
    cmp al, bl
    jne strings_not_equal
    
    ; If both strings end here, they match
    cmp al, 0          ; Check for end of string
    je strings_equal
    
    ; Move to next character
    inc edx
    inc esi
    jmp compare_loop

strings_equal:
    pop esi            ; Restore registers
    pop edx
    pop ecx
    clc                ; Clear carry flag to indicate match
    ret

strings_not_equal:
    pop esi            ; Restore registers
    pop edx
    pop ecx
    stc                ; Set carry flag to indicate no match
    ret
strcmp ENDP

; --- Module 2: Destination ---
dest_date_selection PROC
    ; Get departure venue
depart_input:
    mov edx, OFFSET departVenuePrompt
    call WriteString
    call ReadInt
    
    ; Validate departure input
    cmp al, 1
    jl invalid_depart    ; If less than 1
    cmp al, 3
    jg invalid_depart    ; If greater than 3
    mov departChoice, al
    jmp get_destination

invalid_depart:
    jmp depart_input    ; Ask again for valid input

    ; Get destination
get_destination:
    mov edx, OFFSET destPrompt
    call WriteString
    call ReadInt
    
    ; Validate destination input
    cmp al, 1
    jl invalid_dest     ; If less than 1
    cmp al, 3
    jg invalid_dest     ; If greater than 3
    
    ; Check if destination equals departure
    mov bl, departChoice
    cmp al, bl
    je same_venue_error
    
    mov destChoice, al
    jmp valid_dest

same_venue_error:
    mov edx, OFFSET invalidDepartMsg
    call WriteString
    jmp depart_input    ; Go back to departure selection

invalid_dest:
    jmp get_destination  ; Ask again for valid destination

valid_dest:
    ; Continue with date input as before
date_input:
    mov edx, OFFSET datePrompt
    call WriteString
    mov edx, OFFSET dateInput
    mov ecx, SIZEOF dateInput
    call ReadString

    ; Rest of the date validation code remains the same...
    ; ... (keep existing date validation code)

date_confirmed:
    ret
dest_date_selection ENDP


; --- Module 3: Service ---
service_type_selection PROC
    ; Display service class header and descriptions
    call Crlf
    mov edx, OFFSET serviceClassHeader
    call WriteString
    call Crlf

    ; Display Business Class description
    mov edx, OFFSET businessClassDesc
    call WriteString
    call Crlf

    ; Display Economy Class description
    mov edx, OFFSET economyClassDesc
    call WriteString
    call Crlf

service_input:
    mov edx, OFFSET servicePrompt
    call WriteString
    call ReadInt
    
    ; Validate service choice (1 or 2)
    cmp al, 1
    jl invalid_service
    cmp al, 2
    jg invalid_service
    mov serviceChoice, al

    ; Display appropriate seat layout
    call Crlf
    mov edx, OFFSET seatLayout
    call WriteString
    call Crlf
  

seat_selection:
    mov edx, OFFSET seatPrompt
    call WriteString
    
    ; Read seat selection
    mov edx, OFFSET selectedSeat
    mov ecx, 3          ; Max length (2 chars + null)
    call ReadString
    
    ; Check if user wants to go back
    mov al, [selectedSeat]
    cmp al, 'B'
    je service_input    ; Loop back to service selection
    
    ; Validate seat format (e.g., A1, B2, etc.)
    call validate_seat
    jc invalid_seat     ; If carry flag set, invalid seat
    
    ; Check if seat matches selected service class
    call check_service_match
    jc wrong_class      ; If carry flag set, wrong class
    
    ret                 ; Valid seat selected

invalid_service:
    jmp service_input

invalid_seat:
    mov edx, OFFSET invalidSeatMsg
    call WriteString
    jmp seat_selection

wrong_class:
    mov edx, OFFSET wrongClassMsg   ; Use predefined string instead of inline
    call WriteString
    jmp seat_selection

validate_seat PROC
    ; Check if first character is a valid row letter
    mov al, [selectedSeat]     ; Get first character (row)
    cmp al, 'A'
    jl invalid_format
    cmp al, 'E'
    jg invalid_format

    ; Check if second character is a valid number (1-4)
    mov al, [selectedSeat + 1] ; Get second character (number)
    cmp al, '1'
    jl invalid_format
    cmp al, '4'
    jg invalid_format

    ; Check if there's no third character (should be null terminator)
    mov al, [selectedSeat + 2]
    test al, al
    jnz invalid_format

    ; If we get here, seat format is valid
    clc                        ; Clear carry flag to indicate valid
    ret

invalid_format:
    stc                        ; Set carry flag to indicate invalid
    ret
validate_seat ENDP

check_service_match PROC
    ; Check if selected seat matches service class
    mov al, [selectedSeat]    ; Get row letter
    mov bl, serviceChoice
    cmp bl, 1              ; Business class?
    je check_business
    
check_economy:
    ; Check if seat is in economy section (C-E)
    cmp al, 'C'
    jl wrong_section
    cmp al, 'E'
    jg wrong_section
    clc                    ; Clear carry flag - valid
    ret

check_business:
    ; Check if seat is in business section (A-B)
    cmp al, 'A'
    jl wrong_section
    cmp al, 'B'
    jg wrong_section
    clc                    ; Clear carry flag - valid
    ret

wrong_section:
    stc                    ; Set carry flag - invalid
    ret
check_service_match ENDP

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

    ; Display base amount
    mov edx, OFFSET baseTotalMsg    ; Changed from inline string
    call WriteString
    movzx eax, baseFinal
    call print_price
    call Crlf

    ; Calculate SST (6%)
    movzx eax, baseFinal
    xor edx, edx
    mov ecx, 6
    mul ecx
    mov ecx, 100
    div ecx              ; EAX = SST
    mov sstAmount, ax

    ; Display SST amount
    mov edx, OFFSET sstMsg
    call WriteString
    movzx eax, sstAmount
    call print_price
    call Crlf

    ; Total = baseFinal + SST
    movzx eax, baseFinal
    movzx ebx, sstAmount
    add eax, ebx
    mov paymentAmount, ax

    ; Display total amount
    mov edx, OFFSET totalAmountMsg    ; Changed from inline string
    call WriteString
    movzx eax, paymentAmount
    call print_price
    call Crlf
    call Crlf

     ; Select payment merchant
merchant_select:
    mov edx, OFFSET paymentMerchantPrompt
    call WriteString
    call ReadInt
    cmp al, 1
    jl invalid_merchant
    cmp al, 4
    jg invalid_merchant
    mov merchantChoice, al
    jmp get_payment

invalid_merchant:
    mov edx, OFFSET invalidMerchantMsg
    call WriteString
    jmp merchant_select

get_payment:
    ; Display total amount again for reference
    mov edx, OFFSET totalAmountMsg
    call WriteString
    movzx eax, paymentAmount
    call print_price
    call Crlf

payment_input:
    ; Get payment amount
    mov edx, OFFSET paymentPrompt
    call WriteString
    call ReadInt       ; Read integer part (whole ringgit)
    mov ebx, 100      ; Convert to cents
    mul ebx           ; EAX = ringgit * 100 (now in cents)
    mov inputAmount, eax

    ; Compare with required amount
    movzx ebx, paymentAmount
    cmp eax, ebx
    jl insufficient_payment

    ; If we get here, payment is sufficient
    ; Calculate change
    sub eax, ebx      ; eax = input - required
    mov changeAmount, eax

    ; Display change amount if any
    cmp eax, 0
    je payment_exact
    
    ; Show change amount
    mov edx, OFFSET changeMsg
    call WriteString
    mov eax, changeAmount
    call print_price   ; This will format it correctly as RM XX.XX
    call Crlf
    jmp payment_done

insufficient_payment:
    mov edx, OFFSET insufficientMsg
    call WriteString
    movzx eax, paymentAmount
    call print_price
    call Crlf
    jmp payment_input      ; Ask for payment again

payment_exact:
    ; Payment is exact amount
    mov changeAmount, 0    ; Ensure change is zero
    call Crlf

payment_done:
    ret

payment_processing ENDP

; --- Module 6: Display Receipt ---
info_display PROC
    mov edx, OFFSET receiptMsg
    call WriteString

    ; Show Departure
    mov edx, OFFSET departureMsg
    call WriteString
    movzx eax, departChoice      ; Get departure choice (1-3)
    dec eax                      ; Convert to 0-based index
    mov ebx, 20                  ; Each city entry is 20 bytes
    mul ebx                      ; Calculate offset
    add eax, OFFSET cityNames    ; Get address of city name
    mov edx, eax
    call WriteString
    call Crlf

    ; Show Destination
    mov edx, OFFSET destMsg
    call WriteString
    movzx eax, destChoice        ; Get destination choice (1-3)
    dec eax                      ; Convert to 0-based index
    mov ebx, 20                  ; Each city entry is 20 bytes
    mul ebx                      ; Calculate offset
    add eax, OFFSET cityNames    ; Get address of city name
    mov edx, eax
    call WriteString
    call Crlf

    ; Seat, Depart, Arrive
    mov edx, OFFSET seatsMsg
    call WriteString
    mov edx, OFFSET selectedSeat  ; Display the actual selected seat
    call WriteString
    call Crlf

    mov edx, OFFSET departMsg     ; Display departure time
    call WriteString
    mov edx, OFFSET arriveMsg     ; Display arrival time
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

    ; Display payment method
    mov edx, OFFSET selectedMerchant
    call WriteString
    
    ; Display the selected merchant based on choice
    movzx eax, merchantChoice
    cmp al, 1
    je display_visa
    cmp al, 2
    je display_mastercard
    cmp al, 3
    je display_unionpay
    cmp al, 4
    je display_amex
    jmp receipt_done

display_visa:
    mov edx, OFFSET merchantVisa
    jmp show_merchant
display_mastercard:
    mov edx, OFFSET merchantMastercard
    jmp show_merchant
display_unionpay:
    mov edx, OFFSET merchantUnionPay
    jmp show_merchant
display_amex:
    mov edx, OFFSET merchantAmex

show_merchant:
    call WriteString
    call Crlf

    ; Display change if any
    mov eax, changeAmount
    cmp eax, 0
    je receipt_done
    mov edx, OFFSET changeMsg
    call WriteString
    mov eax, changeAmount
    call print_price
    call Crlf

receipt_done:
    ret
info_display ENDP

; --- Utility: Print RM amount from cents (e.g., 1234 = RM12.34) ---
print_price PROC
    ; Input: EAX = amount in cents
    push eax            ; Save original value
    push ebx            ; Save registers we'll use
    push edx

    xor edx, edx
    mov ebx, 100
    div ebx             ; EAX = RM, EDX = cents

    ; Print the whole number part
    call WriteDec

    ; Print decimal point
    push edx            ; Save cents
    mov al, '.'         ; Use literal '.' character
    call WriteChar
    pop edx            ; Restore cents

    ; Handle cents (add leading zero if needed)
    mov eax, edx
    cmp eax, 10
    jae print_cents    ; If >= 10, print directly
    
    ; Add leading zero for single digit cents
    push eax           ; Save cents
    mov al, '0'
    call WriteChar
    pop eax           ; Restore cents

print_cents:
    call WriteDec      ; Print cents value

    pop edx            ; Restore registers
    pop ebx
    pop eax
    ret
print_price ENDP
END main
