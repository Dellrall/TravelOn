INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096

;Whats left:
;1)ONHOLD Multiple Seats selection
;2)ONHOLD Seats selected element(if user have previously selected those seats, that seat will be taken)
;3)ONHOLD Total seats price total calculation(all combine into the total)
;4)ONHOLD Information display module showing all the seats selected
;5)ONHOLD User ability to print tickets and print it out for each seats paid for
;6) Continue the code after the first flow has been finished to allow administrator to go back to check tickets sold.
;7) Add section which would require the user to enter their name for each of the selected for tickets details.
;8) Redesign the administrator dashboard(Include information like promo selected, premium user selection)
;9) Add some flair to the promo module
;10) DONE Fix the damn user login issue, and ties information and tickets data to each user
;11) Duplication Prevention: Making sure that the seats selection module changes and store data for previous seats that have been selected
;12) Add festive/holidays prompt for specific date selected, make them to have the seats pre-selected.
;13) Feedback form: if user wanted to give back, there would a selection for it, user might get a random free gift or nothing at all.
;14) Ticket cancellation: For if user wish to cancel their tickets, they would be able to receive a refund
;15) More

;Add if still got time
;1) Persistence data (if possible) 
;2) Ability to register user(if possible)
;3) Redesign the whole UI(if possible)
;4) More

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
      invalidChoiceMsg BYTE "Invalid choice. Please try again.", 0Dh, 0Ah, 0
    NUM_USERS = 5
    valid_users  BYTE "Roziyani", 0, (20-9) DUP(0)     ; 9 chars + null + 10 padding = 20
            BYTE "Amos", 0, (20-5) DUP(0)          ; 4 chars + null + 15 padding = 20
            BYTE "Dell", 0, (20-5) DUP(0)          ; 4 chars + null + 15 padding = 20
            BYTE "Jason", 0, (20-6) DUP(0)         ; 5 chars + null + 14 padding = 20
            BYTE "Luian", 0, (20-6) DUP(0)         ; 5 chars + null + 14 padding = 20

valid_passwords  BYTE "Rz2023##", 0, (20-9) DUP(0)  ; 8 chars + null + 11 padding = 20
                BYTE "Am@s456", 0, (20-8) DUP(0)    ; 7 chars + null + 12 padding = 20
                BYTE "D3ll789", 0, (20-8) DUP(0)    ; 7 chars + null + 12 padding = 20
                BYTE "Js0n#2k", 0, (20-8) DUP(0)    ; 7 chars + null + 12 padding = 20
                BYTE "Lu!@n25", 0, (20-8) DUP(0)    ; 7 chars + null + 12 padding = 20

    invalidLoginMsg BYTE "Invalid username or password! Please try again.", 0Dh, 0Ah, 0

    ; --- Administrator Module ---
; Add this structure for ticket history (add to .data section)
MAX_TICKETS = 50  ; Maximum number of tickets per user
ticketHistory     BYTE NUM_USERS DUP(MAX_TICKETS DUP(0))  ; Store seat info for each user
userTicketCount   BYTE NUM_USERS DUP(0)                    ; Count of tickets per user
currentUserIndex  DWORD 0                                  ; Store current user index
adminLoginHeader BYTE "=== TravelOn Bus System Login ===", 0Dh, 0Ah, 0
userTypePrompt    BYTE "Select User Type (1=User, 2=Administrator): ", 0
adminPrompt       BYTE "Enter Secret Phrase: ", 0
secretPhrase      BYTE "Chicken Jockey", 0
wrongPhraseMsg    BYTE "Invalid Secret Phrase. Access Denied.", 0Dh, 0Ah, 0
adminWelcomeMsg   BYTE "=== Administrator Dashboard ===", 0Dh, 0Ah, 0
noSalesMsg        BYTE "No ticket sales data available.", 0Dh, 0Ah, 0
salesHeaderMsg    BYTE "Ticket Sales Report", 0Dh, 0Ah
                  BYTE "==================", 0Dh, 0Ah, 0
totalSalesMsg     BYTE "Total Sales: RM", 0
ticketCountMsg    BYTE "Total Tickets Sold: ", 0
businessCountMsg  BYTE "Business Class Tickets: ", 0
economyCountMsg   BYTE "Economy Class Tickets: ", 0
salesData         BYTE 0    ; Flag to track if any sales occurred
totalSales        DWORD 0   ; Total sales amount in cents
totalTicketCount  BYTE 0    ; Total number of tickets sold
businessCount     BYTE 0    ; Number of business class tickets
economyCount      BYTE 0    ; Number of economy class tickets
adminOptionsMsg   BYTE "Options:", 0Dh, 0Ah
                 BYTE "1. Return to User Mode", 0Dh, 0Ah
                 BYTE "2. Exit System", 0Dh, 0Ah
                 BYTE "Select option (1-2): ", 0

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
    invalidDateMsg BYTE "Invalid date format. Please enter MMDD format (e.g., 0411)", 0Dh, 0Ah, 0
    confirmDateMsg BYTE "Selected date is: ", 0
    dayMsgEnd     BYTE 0Dh, 0Ah, 0
    confirmPrompt BYTE "Proceed with this date? (1=Yes, 0=No): ", 0
    daysInMonth    BYTE 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31  ; Days in each month for 2025
monthNames     BYTE "January", 0, "February", 0, "March", 0, "April", 0
              BYTE "May", 0, "June", 0, "July", 0, "August", 0
              BYTE "September", 0, "October", 0, "November", 0, "December", 0
invalidMonthMsg BYTE "Invalid month. Please enter a month between 01-12.", 0Dh, 0Ah, 0
invalidDayMsg   BYTE "Invalid day for the selected month.", 0Dh, 0Ah, 0
dateConfirmMsg  BYTE "You have selected: ", 0
dateSuffix   BYTE "st", 0, "nd", 0, "rd", 0, "th", 0  ; Suffixes for dates
yearDisplay  BYTE ", 2025", 0                          ; Current year

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
  
    selectedSeat BYTE 3 DUP(0) ; Store selected seat
    invalidSeatMsg BYTE "Invalid seat selection! Please try again.", 0Dh, 0Ah, 0
    

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
    dateDisplayMsg BYTE "Date: ", 0
    paymentPrompt BYTE "Enter Payment Amount: RM", 0
    receiptMsg BYTE "----- Receipt -----", 0Dh, 0Ah, 0
    destMsg    BYTE "Destination: ", 0
    seatsMsg   BYTE "Seat: ", 0    ; Remove the hardcoded A1
    departureMsg BYTE "Departure: ", 0
    departMsg  BYTE "Depart: 08:00", 0Dh, 0Ah, 0
    arriveMsg  BYTE "Arrive: 12:00", 0Dh, 0Ah, 0
    sstMsg     BYTE "SST (6%): RM", 0
    totalMsg   BYTE "Total Paid: RM", 0
  
cityNames    BYTE "Kuala Lumpur", 0, 7 DUP(0)     ; 20 bytes (13 + 7 padding)
            BYTE "Kuantan", 0, 12 DUP(0)          ; 20 bytes (8 + 12 padding)
            BYTE "Johor Bahru", 0, 9 DUP(0)       ; 20 bytes (11 + 9 padding)

            logoutOptionsMsg   BYTE "Options:", 0Dh, 0Ah
                  BYTE "1. Logout", 0Dh, 0Ah
                  BYTE "2. Exit System", 0Dh, 0Ah
                  BYTE "Select option (1-2): ", 0




.code
main PROC
start:  
    call check_user_type 
     cmp al, 2                  ; Check if admin login
    je start                   ; If admin, go back to start after logout

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

     call info_display         ; This now includes logout options0
    jmp start                 ; Return to start after logout
main ENDP

; --- Administrator Module ---
check_user_type PROC
    call Clrscr
    mov edx, OFFSET adminLoginHeader
    call WriteString
    call Crlf
    
    mov edx, OFFSET userTypePrompt
    call WriteString
    call ReadInt
    
    cmp al, 2
    je admin_login
    cmp al, 1
    je user_flow
    
    ; Invalid choice, ask again
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    jmp check_user_type

admin_login:
    call Clrscr
    mov edx, OFFSET adminPrompt
    call WriteString
    
    ; Read secret phrase
    mov edx, OFFSET username    ; Reuse username buffer for phrase
    mov ecx, SIZEOF username
    call ReadString
    
    ; Compare with secret phrase
    mov edx, OFFSET username
    mov esi, OFFSET secretPhrase
    call strcmp
    jnc admin_dashboard    ; If match (carry clear), show dashboard
    
    ; Wrong phrase
    mov edx, OFFSET wrongPhraseMsg
    call WriteString
    call Crlf
    call ReadChar         ; Wait for key press
    jmp check_user_type
admin_dashboard:
    call Clrscr
    mov edx, OFFSET adminWelcomeMsg
    call WriteString
    call Crlf
    
    ; Add sales summary first
    mov edx, OFFSET salesHeaderMsg
    call WriteString
    mov edx, OFFSET ticketCountMsg
    call WriteString
    movzx eax, totalTicketCount 
    call WriteDec
    call Crlf
    
    ; Check if sales data exists
    mov ecx, NUM_USERS          ; Number of users to check
    xor esi, esi               ; User index counter
    mov bl, 0                  ; Flag for any tickets found

    ; Start checking tickets for each user

check_user_tickets:
    cmp userTicketCount[esi], 0 
    je next_user
    
    ; Display user name
    push ecx
    push esi
    
    ; Calculate user name address
    mov eax, esi
    mov ebx, 20         ; Each username entry is 20 bytes
    mul ebx
    add eax, OFFSET valid_users
    mov edx, eax
    call WriteString
    
    ; Display user's tickets
    mov al, ':'
    call WriteChar
    call Crlf
    
    ; Display each ticket
    xor ecx, ecx
    movzx ecx, userTicketCount[esi]
    mov edi, MAX_TICKETS
    mov eax, esi
    mul edi
    lea edi, ticketHistory[eax]
    
display_tickets:
    push ecx
    mov al, '['
    call WriteChar
    mov al, [edi]       ; Seat letter
    call WriteChar
    mov al, [edi + 1]   ; Seat number
    call WriteChar
    mov al, ']'
    call WriteChar
    mov al, ' '
    call WriteChar
    add edi, 2          ; Move to next ticket
    pop ecx
    loop display_tickets
    
    call Crlf
    mov bl, 1           ; Set flag that tickets were found
    
    pop esi
    pop ecx
    
next_user:
    inc esi
    loop check_user_tickets
    
    ; If no tickets found
    test bl, bl
    jnz show_admin_options
    mov edx, OFFSET noSalesMsg
    call WriteString
    
show_admin_options:
    call Crlf
    mov edx, OFFSET adminOptionsMsg
    call WriteString
    call ReadInt
    
    cmp al, 1
    je check_user_type  ; Return to user type selection
    cmp al, 2
    je exit_system
    
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    jmp show_admin_options

no_sales_data:
    mov edx, OFFSET noSalesMsg
    call WriteString
    call Crlf
    jmp show_admin_options

exit_system:
    INVOKE ExitProcess, 0

user_flow:
    ret    ; Continue with normal user flow
check_user_type ENDP

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
 ; Store current user index
    mov eax, NUM_USERS
    sub eax, ecx        ; Calculate user index based on loop counter
    mov currentUserIndex, eax
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
    
date_input:
    mov edx, OFFSET datePrompt
    call WriteString
    mov edx, OFFSET dateInput
    mov ecx, SIZEOF dateInput
    call ReadString

    ; Validate input length (should be 4 characters)
    cmp eax, 4
    jne invalid_date_format

    ; Convert month (first two characters)
    mov al, [dateInput]     ; First digit
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, [dateInput + 1] ; Second digit
    sub bl, '0'
    add al, bl             ; AL now contains month number (1-12)
    
    ; Validate month
    cmp al, 1
    jl invalid_month
    cmp al, 12
    jg invalid_month
    
    push eax               ; Save month number
    
    ; Convert day (last two characters)
    mov al, [dateInput + 2] ; Third digit
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, [dateInput + 3] ; Fourth digit
    sub bl, '0'
    add al, bl             ; AL now contains day number
    
    ; Get days in month
    pop ebx                ; Restore month number
    dec ebx                ; Convert to 0-based index
    push ebx               ; Save for later use
    movzx esi, bl
    mov bl, [daysInMonth + esi]  ; Get max days for this month
    
    ; Validate day
    cmp al, 1
    jl invalid_day
    cmp al, bl
    jg invalid_day
    
  ; Display the confirmation
    Call Crlf
    mov edx, OFFSET dateConfirmMsg
    call WriteString
    
    ; Find and display month name (corrected version)
    mov ebx, OFFSET monthNames
    mov ecx, [esp]        ; Get month index from stack (0-based)
    
find_month:
    cmp ecx, 0
    je found_month
    
    ; Skip current month name
find_next:
    cmp BYTE PTR [ebx], 0
    je skip_null
    inc ebx
    jmp find_next
skip_null:
    inc ebx        ; Skip the null terminator
    dec ecx
    jmp find_month
    
found_month:
    ; Display month name
    mov edx, ebx
    call WriteString
    
    ; Display space
    mov al, ' '
    call WriteChar
    
    ; Display day with suffix
    movzx eax, BYTE PTR [dateInput + 2]
    sub al, '0'
    mov bl, 10
    mul bl
    movzx ebx, BYTE PTR [dateInput + 3]
    sub bl, '0'
    add al, bl          ; AL now contains day number
    
    ; Display the day number
    push eax            ; Save day number
    call WriteDec
    
    ; Determine suffix
    pop eax             ; Restore day number
    push eax            ; Save it again
    
    ; Special cases for 11th, 12th, 13th
    cmp al, 11
    je use_th
    cmp al, 12
    je use_th
    cmp al, 13
    je use_th
    
    ; Get last digit for other numbers
    mov bl, 10
    div bl              ; AH contains last digit
    mov al, ah
    
    ; Choose suffix based on last digit
    cmp al, 1
    je use_st
    cmp al, 2
    je use_nd
    cmp al, 3
    je use_rd
    jmp use_th
    
use_st:
    mov edx, OFFSET dateSuffix
    jmp show_suffix
use_nd:
    mov edx, OFFSET dateSuffix + 3
    jmp show_suffix
use_rd:
    mov edx, OFFSET dateSuffix + 6
    jmp show_suffix
use_th:
    mov edx, OFFSET dateSuffix + 9
show_suffix:
    call WriteString
    
    ; Display year
    mov edx, OFFSET yearDisplay
    call WriteString
    call Crlf
    
    ; Ask for confirmation
    mov edx, OFFSET confirmPrompt
    call WriteString
    call ReadInt
    
    ; Store result temporarily
    mov bl, al
    pop eax             ; Clean up day number from stack
    
    ; Now check the confirmation
    cmp bl, 1
    je date_confirmed
    cmp bl, 0
    je date_input
    
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    jmp date_input

invalid_month:
    mov edx, OFFSET invalidMonthMsg
    call WriteString
    jmp date_input

invalid_day:
    mov edx, OFFSET invalidDayMsg
    call WriteString
    jmp date_input

invalid_date_format:
    mov edx, OFFSET invalidDateMsg
    call WriteString
    jmp date_input

date_confirmed:
    pop ebx     ; Balance the stack by removing the saved month number
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
    
      ; Check if user wants to go back (single 'B' character)
    mov al, [selectedSeat]
    cmp al, 'B'
    jne not_back_command
    mov al, [selectedSeat + 1]  ; Check if there's a second character
    test al, al                 ; If null terminator, it's a back command
    je service_input            ; Loop back to service selection
    
not_back_command:
    ; Continue with seat validation
    
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
    ; Record sales data
    mov salesData, 1    ; Mark that we have sales data
    mov eax, inputAmount
    add totalSales, eax    ; Add to total sales
    inc totalTicketCount       ; Increment total ticket count
    
    ; Record ticket type
    movzx eax, serviceChoice
    cmp al, 1
    jne record_economy
    inc businessCount
    jmp sales_recorded
record_economy:
    inc economyCount
sales_recorded:
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

      ; Display Date
    mov edx, OFFSET dateDisplayMsg
    call WriteString
    
    ; Display month name
    mov ebx, OFFSET monthNames
    movzx ecx, BYTE PTR [dateInput]    ; Get first digit of month
    sub cl, '0'
    mov al, 10
    mul cl
    movzx ecx, BYTE PTR [dateInput + 1] ; Get second digit
    sub cl, '0'
    add al, cl
    dec al                              ; Convert to 0-based index
    
    ; Find correct month name
    xor ecx, ecx
    mov cl, al
find_month_name:
    cmp ecx, 0
    je show_month
    
next_month:
    cmp BYTE PTR [ebx], 0
    je skip_month
    inc ebx
    jmp next_month
skip_month:
    inc ebx
    dec ecx
    jmp find_month_name
    
show_month:
    mov edx, ebx
    call WriteString
    
    ; Display space
    mov al, ' '
    call WriteChar
    
    ; Display day with suffix
    movzx eax, BYTE PTR [dateInput + 2]
    sub al, '0'
    mov bl, 10
    mul bl
    movzx ebx, BYTE PTR [dateInput + 3]
    sub bl, '0'
    add al, bl
    
    ; Display the day number
    push eax
    call WriteDec
    
    ; Add appropriate suffix
    pop eax
    
    ; Check for special cases (11th, 12th, 13th)
    cmp al, 11
    je use_th_suffix
    cmp al, 12
    je use_th_suffix
    cmp al, 13
    je use_th_suffix
    
    ; Get last digit
    mov bl, 10
    div bl              ; AH contains last digit
    mov al, ah
    
    ; Choose suffix
    cmp al, 1
    je use_st_suffix
    cmp al, 2
    je use_nd_suffix
    cmp al, 3
    je use_rd_suffix
    jmp use_th_suffix
    
use_st_suffix:
    mov edx, OFFSET dateSuffix
    jmp show_date_suffix
use_nd_suffix:
    mov edx, OFFSET dateSuffix + 3
    jmp show_date_suffix
use_rd_suffix:
    mov edx, OFFSET dateSuffix + 6
    jmp show_date_suffix
use_th_suffix:
    mov edx, OFFSET dateSuffix + 9
    
show_date_suffix:
    call WriteString
    
    ; Display year
    mov edx, OFFSET yearDisplay
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
 call Crlf
    
   ; Store ticket information for current user
mov esi, currentUserIndex
movzx eax, userTicketCount[esi]    ; Get current count
mov edi, 2                     ; Each ticket takes 2 bytes
mul edi                        ; EAX = count * 2
mov edi, MAX_TICKETS
push eax                       ; Save the offset
mov eax, currentUserIndex
mul edi                        ; EAX = userIndex * MAX_TICKETS
lea edi, ticketHistory[eax]    ; Point to user's storage
pop eax                        ; Restore the offset
add edi, eax                   ; Point to next free slot

    ; Store seat information
    mov al, [selectedSeat]
    mov [edi + ecx], al       ; Store seat letter
    mov al, [selectedSeat + 1]
    mov [edi + ecx + 1], al   ; Store seat number
    inc BYTE PTR userTicketCount[esi] ; Increment ticket count for user

show_logout_options:
    mov edx, OFFSET logoutOptionsMsg
    call WriteString
    call ReadInt
    
    cmp al, 1
    je do_logout
    cmp al, 2
    je do_exit
    
    ; Invalid choice
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    jmp show_logout_options

do_logout:
    jmp check_user_type    ; Return to user type selection

do_exit:
    INVOKE ExitProcess, 0

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
