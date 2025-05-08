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
;6)DONE Continue the code after the first flow has been finished to allow administrator to go back to check tickets sold.
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
;4) More

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
    ; --- Gruvbox Color Theme ---
    ; Define Gruvbox colors for more consistent theming
    gruvboxBg         EQU black     ; Background color (black)
    gruvboxFg         EQU lightGray ; Default foreground (light gray)
    gruvboxRed        EQU lightRed  ; Error messages
    gruvboxGreen      EQU green     ; Success messages
    gruvboxYellow     EQU yellow    ; Headers
    gruvboxBlue       EQU blue      ; Accent color
    gruvboxPurple     EQU magenta   ; Secondary accent
    gruvboxAqua       EQU cyan      ; Prompts
    gruvboxOrange     EQU brown     ; Tertiary accent
    
    ; Color theme aliases (replacing the previous color definitions)
    cBgColor         EQU gruvboxBg
    bgColor          EQU gruvboxBg
    cFgDefault       EQU gruvboxFg
    fgDefault        EQU gruvboxFg
    cFgHeader        EQU gruvboxYellow
    cFgPrompt        EQU gruvboxAqua
    cFgSuccess       EQU gruvboxGreen
    cFgError         EQU gruvboxRed
    cFgAccent1       EQU gruvboxPurple
    cFgAccent2       EQU gruvboxBlue
    cFgArt           EQU gruvboxGreen

    ; --- ASCII Art for User Login ---
    userLoginArt BYTE "    _    _               _                _       ", 0Dh, 0Ah
                BYTE "   | |  | |             | |              (_)      ", 0Dh, 0Ah
                BYTE "   | |  | |___  ___ _ __| |     ___   ___ _ _ __  ", 0Dh, 0Ah
                BYTE "   | |  | / __|/ _ \ '__| |    / _ \ / __| | '_ \ ", 0Dh, 0Ah
                BYTE "   | |__| \__ \  __/ |  | |___| (_) | (__| | | | |", 0Dh, 0Ah
                BYTE "    \____/|___/\___|_|  |______\___/ \___|_|_| |_|", 0Dh, 0Ah, 0

    ; --- ASCII Art for Admin Login ---
    adminLoginArt BYTE "    _       _           _       _        _             ", 0Dh, 0Ah
                 BYTE "   / \   __| |_ __ ___ (_)_ __ (_)      / \   _ __ ___ ", 0Dh, 0Ah
                 BYTE "  / _ \ / _` | '_ ` _ \| | '_ \| |     / _ \ | '__/ _ \", 0Dh, 0Ah
                 BYTE " / ___ \ (_| | | | | | | | | | | |    / ___ \| | |  __/", 0Dh, 0Ah
                 BYTE "/_/   \_\__,_|_| |_| |_|_|_| |_|_|   /_/   \_\_|  \___|", 0Dh, 0Ah, 0

    ; --- ASCII Art for Tickets ---
    ticketAsciiArt BYTE "  _______________________", 0Dh, 0Ah
                  BYTE " /                       \\", 0Dh, 0Ah
                  BYTE "/    TravelOn Bus        \\", 0Dh, 0Ah
                  BYTE "|  =====================  |", 0Dh, 0Ah
                  BYTE "|     T I C K E T        |", 0Dh, 0Ah
                  BYTE "|  =====================  |", 0Dh, 0Ah
                  BYTE "|                         |", 0Dh, 0Ah
                  BYTE "|                         |", 0Dh, 0Ah
                  BYTE "|_________________________|", 0Dh, 0Ah, 0

    ; --- ASCII Art for Promo ---
    promoAsciiArt BYTE "    ____                           ", 0Dh, 0Ah
                 BYTE "   / __ \_________  ____ ___  ___  ", 0Dh, 0Ah
                 BYTE "  / /_/ / ___/ __ \/ __ `__ \/ _ \ ", 0Dh, 0Ah
                 BYTE " / ____/ /  / /_/ / / / / / /  __/ ", 0Dh, 0Ah
                 BYTE "/_/   /_/   \____/_/ /_/ /_/\___/  ", 0Dh, 0Ah, 0
                 
    ; --- ASCII Art for Payment Success ---
    paymentSuccessArt BYTE "   _____                               __", 0Dh, 0Ah
                     BYTE "  / ___/___  _________  __________  ___/ /", 0Dh, 0Ah
                     BYTE "  \__ \/ _ \/ ___/ __ \/ ___/ ___/ / _  / ", 0Dh, 0Ah
                     BYTE " ___/ /  __/ /__/ /_/ / /  / /__/ /  __/  ", 0Dh, 0Ah
                     BYTE "/____/\___/\___/\____/_/   \___/_/\___/   ", 0Dh, 0Ah, 0

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
ticketHistory     BYTE NUM_USERS DUP(MAX_TICKETS DUP(7 DUP(0)))  ; Updated to 7 bytes per ticket
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
salesTargetMsg    BYTE "Sales Target: RM", 0
remainingSalesMsg BYTE "Remaining to Target: RM", 0
targetMetMsg      BYTE "Sales Target Met/Exceeded!", 0Dh, 0Ah, 0
promoNoneMsg      BYTE " (Promo: None)", 0
promoElderlyMsg   BYTE " (Promo: Elderly)", 0
promoKidMsg       BYTE " (Promo: Kid)", 0
salesData         BYTE 0    ; Flag to track if any sales occurred
totalSales        DWORD 0   ; Total sales amount in cents
salesTarget       DWORD 100000 ; Sales target in cents (RM 1000.00)
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
  ; --- Seat Selection ---
seatLayout BYTE " Business Class", 0Dh, 0Ah
          BYTE "   1  2     3  4", 0Dh, 0Ah
          BYTE "A [ ][ ]   [ ][ ]", 0Dh, 0Ah
          BYTE "B [ ][ ]   [ ][ ]", 0Dh, 0Ah
          BYTE "  Economy Class", 0Dh, 0Ah
          BYTE "C [ ][ ]   [ ][ ]", 0Dh, 0Ah
          BYTE "D [ ][ ]   [ ][ ]", 0Dh, 0Ah
          BYTE "E [ ][ ]   [ ][ ]", 0Dh, 0Ah, 0
              wrongClassMsg BYTE "This seat is not in your selected class!", 0Dh, 0Ah, 0
  
    selectedSeat BYTE 3 DUP(0) ; Store selected seat
    invalidSeatMsg BYTE "Invalid seat selection! Please try again.", 0Dh, 0Ah, 0
    seatTakenMsg     BYTE "This seat is already taken for this date. Please select another seat.", 0Dh, 0Ah, 0
seatBookings     BYTE MAX_TICKETS DUP(4 DUP(0))  ; Format: Month(1) Day(1) SeatRow(1) SeatNum(1)
dynamicSeatLayout BYTE 255 DUP(0)  ; Buffer for dynamic seat layout
    

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
    paymentPrompt BYTE "Enter Payment Amount (in cents, e.g., 4770 for RM47.70): ", 0 ; Modified prompt
    receiptMsg BYTE "----- Receipt -----", 0Dh, 0Ah, 0
    destMsg    BYTE "Destination: ", 0
    seatsMsg   BYTE "Seat: ", 0    ; Remove the hardcoded A1
    departureMsg BYTE "Departure: ", 0
    departMsg  BYTE "Depart: 08:00", 0Dh, 0Ah, 0
    arriveMsg  BYTE "Arrive: 12:00", 0Dh, 0Ah, 0
    sstMsg     BYTE "SST (6%): RM", 0
    totalMsg   BYTE "Total Amount: RM", 0
    amountPaidMsg BYTE "Amount Paid: RM", 0  ; New message for amount paid

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
    cmp al, 0                  ; Check if user type is invalid/exit
    je exit_program            ; Exit if we got 0 (exit code)
    cmp al, 2                  ; Check if admin login
    je start                   ; If admin (2), go back to start after logout
    
    ; If user login (1), proceed with the reservation flow
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

    call info_display         ; This now includes logout options
    jmp start                 ; Return to start after logout

exit_program:
    INVOKE ExitProcess, 0     ; Exit the program
main ENDP

; --- Administrator Module ---
check_user_type PROC
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor ; Reset to default for the screen
    call Clrscr

    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    mov edx, OFFSET adminLoginHeader
    call WriteString
    call Crlf
    
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET userTypePrompt
    call WriteString
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    call ReadInt
    
    ; Save user choice in a register for validation
    mov ebx, eax
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Reset after input
    call SetTextColor
    
    cmp ebx, 2 ; Admin choice
    je admin_login
    cmp ebx, 1 ; User choice
    je user_flow
    
    ; Invalid choice
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    call WaitMsg ; Wait for user to press a key
    call Clrscr
    jmp check_user_type ; Try again

admin_login:
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    call Clrscr

    ; Display Admin ASCII Art
    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    mov edx, OFFSET adminLoginArt
    call WriteString
    call Crlf

    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET adminPrompt
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    mov edx, OFFSET username
    mov ecx, SIZEOF username
    call ReadString
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Reset after input
    call SetTextColor
    
    mov edx, OFFSET username
    mov esi, OFFSET secretPhrase
    call strcmp
    jnc admin_dashboard
    
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET wrongPhraseMsg
    call WriteString
    call Crlf
    call ReadChar
    jmp check_user_type

admin_dashboard:
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    call Clrscr

    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    mov edx, OFFSET adminWelcomeMsg
    call WriteString
    call Crlf

    ; Check if there's any sales data to display
    cmp salesData, 0
    je no_sales_data

    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov edx, OFFSET salesHeaderMsg
    call WriteString

    mov edx, OFFSET totalSalesMsg
    call WriteString
    mov eax, totalSales
    call print_price
    call Crlf

    mov edx, OFFSET salesTargetMsg
    call WriteString
    mov eax, salesTarget
    call print_price
    call Crlf

    mov eax, salesTarget
    sub eax, totalSales
    jc target_already_met

    mov edx, OFFSET remainingSalesMsg
    call WriteString
    call print_price
    call Crlf
    jmp display_ticket_details

target_already_met:
    mov eax, (gruvboxBg * 16) + gruvboxGreen
    call SetTextColor
    mov edx, OFFSET targetMetMsg
    call WriteString
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor

display_ticket_details:
    call Crlf
    mov edx, OFFSET ticketCountMsg
    call WriteString
    movzx eax, totalTicketCount
    call WriteDec
    call Crlf

    mov edx, OFFSET businessCountMsg
    call WriteString
    movzx eax, businessCount
    call WriteDec
    call Crlf
    
    mov edx, OFFSET economyCountMsg
    call WriteString
    movzx eax, economyCount
    call WriteDec
    call Crlf
    call Crlf

    mov ecx, NUM_USERS
    xor esi, esi
    mov bl, 0

check_user_tickets:
    cmp userTicketCount[esi], 0
    je next_user
    push ecx
    push esi
    mov eax, esi
    mov ebx, 20
    mul ebx
    add eax, OFFSET valid_users
    mov edx, eax
    mov eax, (gruvboxBg * 16) + gruvboxAqua ; User name in prompt color
    call SetTextColor
    call WriteString
    mov al, ':'
    call WriteChar
    call Crlf
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Reset to default for ticket details
    call SetTextColor
    xor ecx, ecx
    movzx ecx, userTicketCount[esi]
    mov edi, 3 ; Each ticket record is now 3 bytes
    mov eax, esi
    mul edi
    mov ebx, MAX_TICKETS
    mul ebx ; EAX = user_index * MAX_TICKETS * 3 (start offset in bytes)
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

    ; Display Promo Type
    mov al, [edi + 2]   ; Get promo choice byte
    cmp al, 1
    je show_elderly_promo
    cmp al, 2
    je show_kid_promo

show_none_promo: ; Default case if 0 or other value
    mov edx, OFFSET promoNoneMsg
    call WriteString
    jmp next_ticket_display

show_elderly_promo:
    mov edx, OFFSET promoElderlyMsg
    call WriteString
    jmp next_ticket_display

show_kid_promo:
    mov edx, OFFSET promoKidMsg
    call WriteString

next_ticket_display:
    mov al, ' ' ; Add space after promo info
    call WriteChar
    add edi, 3          ; Move to next ticket (3 bytes)
    pop ecx
    loop display_tickets

    call Crlf
    mov bl, 1           ; Set flag that tickets were found

    pop esi
    pop ecx

next_user:
    inc esi
    dec ecx
    jnz check_user_tickets

    ; If no tickets found
    test bl, bl
    jnz show_admin_options
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET noSalesMsg
    call WriteString
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    jmp show_admin_options  ; Continue to show options even if no tickets

no_sales_data:
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET noSalesMsg
    call WriteString
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    call Crlf

show_admin_options:
    call Crlf
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET adminOptionsMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    call ReadInt
    
    cmp al, 1
    je admin_exit_to_menu
    cmp al, 2
    je exit_program_admin
    
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    jmp show_admin_options

admin_exit_to_menu:
    mov al, 2    ; Return 2 to indicate admin flow was completed
    ret          ; Return to main procedure

exit_program_admin:
    mov al, 0    ; Return 0 to indicate program should exit
    ret

user_flow:
    mov al, 1    ; Return 1 in AL to indicate normal user flow
    ret
check_user_type ENDP

; --- Module 1: Registration ---
registration_login PROC
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor ; Ensure default color at start of proc
    call Clrscr
    
    ; Display User Login ASCII Art
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET userLoginArt
    call WriteString
    call Crlf

reg_login_start:
    ; Input Username
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET loginMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    mov edx, OFFSET username
    mov ecx, SIZEOF username
    call ReadString

    ; Check for null username
    cmp eax, 0
    je reg_username_empty

  ; Input Password with masking
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET passMsg
    call WriteString
    
    ; Initialize password input
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input (asterisks)
    call SetTextColor
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
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Ensure input color is maintained
    call SetTextColor
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
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Ensure input color is maintained
    call SetTextColor
    jmp reg_read_char

reg_end_password:
    mov byte ptr [edi], 0   ; Null terminate the password string
    call Crlf
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Reset color after password input
    call SetTextColor

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
    pop edi                    ; Restore registers from stack
    pop esi
    pop ecx                    ; Restore counter
    add esi, 20               ; Move to next username (20 bytes per entry)
    add edi, 20               ; Move to next password
    dec ecx                   ; Decrease counter
    jnz check_user            ; Continue if more users to check
    
    ; If we get here, no match was found
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
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
    mov eax, (gruvboxBg * 16) + gruvboxGreen
    call SetTextColor
    mov edx, OFFSET successMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov edx, OFFSET welcomeMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
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
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
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
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
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
    jg invalid_dest
    
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
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
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
    movzx esi, bl         ; Clear upper bits of ESI
    lea edi, daysInMonth  ; Get address of days array
    movzx ebx, BYTE PTR [edi + esi]  ; Get max days for this month
    
    ; Validate day
    cmp al, 1
    jl invalid_day
    cmp al, bl
    jg invalid_day

    ; Display the confirmation
    Call Crlf
    mov edx, OFFSET dateConfirmMsg
    call WriteString
    
    ; Find and display month name
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

  
  

seat_selection:
    ; Update and display the dynamic seat layout with taken seats
    call update_seat_layout
    mov edx, OFFSET dynamicSeatLayout
    call WriteString
    call Crlf

    mov edx, OFFSET seatPrompt
    call WriteString
    
    ; Read seat selection
    mov edx, OFFSET selectedSeat
    mov ecx, 3
    call ReadString
    
    ; Check if user wants to go back
    mov al, [selectedSeat]
    cmp al, 'B'
    jne not_back_command
    mov al, [selectedSeat + 1]
    test al, al
    je service_input

not_back_command:
    ; Validate seat format
    call validate_seat
    jc invalid_seat

    ; Check if seat is available
    call check_seat_availability
    jc seat_taken

    ; Check service class match
    call check_service_match
    jc wrong_class

    ; Store booking if everything is valid
    call store_booking
    ret

seat_taken:
    mov edx, OFFSET seatTakenMsg
    call WriteString
    jmp seat_selection

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
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor ; Ensure default color at start of proc

    ; Display Promo ASCII Art
    mov eax, (gruvboxBg * 16) + gruvboxPurple
    call SetTextColor
    mov edx, OFFSET promoAsciiArt
    call WriteString
    call Crlf

    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET promoPrompt
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    call ReadInt
    
    mov promoChoice, al
    
    ; Display brief confirmation of promo selection
    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    
    cmp al, 0
    je promo_none
    cmp al, 1
    je promo_elderly
    cmp al, 2
    je promo_kid
    jmp promo_none ; Default case
    
promo_elderly:
    mov edx, OFFSET promoElderlyMsg
    jmp show_promo_confirm
    
promo_kid:
    mov edx, OFFSET promoKidMsg
    jmp show_promo_confirm
    
promo_none:
    mov edx, OFFSET promoNoneMsg
    
show_promo_confirm:
    call WriteString
    call Crlf
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Reset to default
    call SetTextColor
    ret
promo_application ENDP

; --- Module 5: Payment & SST ---
payment_processing PROC
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor ; Ensure default color at start of proc
    
    ; Get base price based on service class
    movzx eax, serviceChoice
    cmp al, 1
    je business_price
    mov ax, basePriceEconomy
    jmp apply_promo
business_price:
    mov ax, basePriceBusiness

apply_promo:
    ; Apply any applicable promo discount
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
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov edx, OFFSET baseTotalMsg
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
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET sstMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    movzx eax, sstAmount
    call print_price
    call Crlf

    ; Total = baseFinal + SST
    movzx eax, baseFinal
    movzx ebx, sstAmount
    add eax, ebx
    mov paymentAmount, ax

    ; Display total amount
    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    mov edx, OFFSET totalAmountMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    movzx eax, paymentAmount
    call print_price
    call Crlf
    call Crlf

merchant_select:
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET paymentMerchantPrompt
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    call ReadInt
    
    cmp al, 1
    jl invalid_merchant
    cmp al, 4
    jg invalid_merchant
    mov merchantChoice, al
    jmp get_payment

invalid_merchant:
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET invalidMerchantMsg
    call WriteString
    jmp merchant_select

get_payment:
    ; Display total amount again for reference
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov edx, OFFSET totalAmountMsg
    call WriteString
    movzx eax, paymentAmount
    call print_price
    call Crlf

payment_input:
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET paymentPrompt
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    call ReadInt       ; Read integer (cents) directly into EAX
    mov inputAmount, eax

    ; Compare with required amount
    movzx ebx, paymentAmount
    cmp eax, ebx      ; Compare input amount (EAX) with required amount (EBX)
    jl insufficient_payment  ; Jump if input is less than required

    ; If we get here, payment is sufficient
    sub eax, ebx      ; Calculate change
    mov changeAmount, eax

    ; Display change amount if any
    cmp eax, 0
    je payment_exact

    ; Show change amount
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov edx, OFFSET changeMsg
    call WriteString
    mov eax, changeAmount
    call print_price   ; This will format it correctly as RM XX.XX
    call Crlf
    jmp payment_done

insufficient_payment:
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET insufficientMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    movzx eax, paymentAmount
    call print_price ; Display required amount in RM format
    call Crlf
    jmp payment_input      ; Ask for payment again

payment_exact:
    ; Payment is exact amount
    mov changeAmount, 0    ; Ensure change is zero
    call Crlf

payment_done:
    ; Record sales data
    mov salesData, 1        ; Mark that we have sales data
    movzx eax, paymentAmount ; Get the actual ticket price (includes SST)
    add totalSales, eax     ; Add actual ticket price to total sales
    inc totalTicketCount    ; Increment total ticket count

    ; Record ticket type
    movzx eax, serviceChoice
    cmp al, 1
    jne record_economy
    inc businessCount
    jmp sales_recorded
record_economy:
    inc economyCount
sales_recorded:
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Reset to default color
    call SetTextColor
    ret

payment_processing ENDP

; --- Module 6: Display Receipt ---
info_display PROC
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor ; Reset to default color
    call Clrscr
    
    ; Display Ticket ASCII Art
    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    mov edx, OFFSET ticketAsciiArt
    call WriteString
    call Crlf
    
    ; Display Receipt Header
    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    mov edx, OFFSET receiptMsg
    call WriteString
    call Crlf

    ; Show Departure
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET departureMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    movzx eax, departChoice      ; Get departure choice (1-3)
    dec eax                      ; Convert to 0-based index
    mov ebx, 20                  ; Each city entry is 20 bytes
    mul ebx                      ; Calculate offset
    add eax, OFFSET cityNames    ; Get address of city name
    mov edx, eax
    call WriteString
    call Crlf

    ; Show Destination
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET destMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    movzx eax, destChoice        ; Get destination choice (1-3)
    dec eax                      ; Convert to 0-based index
    mov ebx, 20                  ; Each city entry is 20 bytes
    mul ebx                      ; Calculate offset
    add eax, OFFSET cityNames    ; Get address of city name
    mov edx, eax
    call WriteString
    call Crlf

    ; Display Date
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET dateDisplayMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    
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
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET seatsMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxYellow ; Make the seat number stand out
    call SetTextColor
    mov edx, OFFSET selectedSeat  ; Display the actual selected seat
    call WriteString
    call Crlf

    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov edx, OFFSET departMsg     ; Display departure time
    call WriteString
    mov edx, OFFSET arriveMsg     ; Display arrival time
    call WriteString

    ; SST
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET sstMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    movzx eax, sstAmount
    call print_price
    call Crlf

    ; Total Paid
    mov eax, (gruvboxBg * 16) + gruvboxYellow
    call SetTextColor
    mov edx, OFFSET totalMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxGreen ; Highlight total in green
    call SetTextColor
    movzx eax, paymentAmount
    call print_price
    call Crlf

    ; Display payment method
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET selectedMerchant
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    
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
    
    ; Display Amount Paid (actual user input)
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET amountPaidMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov eax, inputAmount
    call print_price
    call Crlf

    ; Display change if any
    mov eax, changeAmount
    cmp eax, 0
    je receipt_done
    
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET changeMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg
    call SetTextColor
    mov eax, changeAmount
    call print_price
    call Crlf

receipt_done:
    call Crlf
    
    ; Payment Success ASCII Art
    mov eax, (gruvboxBg * 16) + gruvboxGreen
    call SetTextColor
    mov edx, OFFSET paymentSuccessArt
    call WriteString
    call Crlf
    
    ; Store ticket information for current user
    mov esi, currentUserIndex
    movzx eax, userTicketCount[esi]    ; Get current count
    mov edi, 3                     ; Each ticket takes 3 bytes (SeatLetter, SeatNum, Promo)
    mul edi                        ; EAX = count * 3 (byte offset within this user's block)
    mov edi, MAX_TICKETS * 3       ; Size of one user's ticket block in bytes
    push eax                       ; Save the offset within the block
    mov eax, currentUserIndex
    mul edi                        ; EAX = userIndex * (MAX_TICKETS * 3)
    lea edi, ticketHistory[eax]    ; Point to start of user's storage block
    pop eax                        ; Restore the offset within the block
    add edi, eax                   ; Point to next free slot (start of 3-byte record)

    ; Store seat information and promo
    mov al, [selectedSeat]
    mov [edi], al       ; Store seat letter
    mov al, [selectedSeat + 1]
    mov [edi + 1], al   ; Store seat number
    movzx eax, promoChoice ; Get promo choice (0, 1, or 2)
    mov [edi + 2], al   ; Store promo choice

    inc BYTE PTR userTicketCount[esi] ; Increment ticket count for user

show_logout_options:
    call Crlf
    mov eax, (gruvboxBg * 16) + gruvboxAqua
    call SetTextColor
    mov edx, OFFSET logoutOptionsMsg
    call WriteString
    
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Color for user input
    call SetTextColor
    call ReadInt
    
    cmp al, 1
    je do_logout
    cmp al, 2
    je do_exit
    
    ; Invalid choice
    mov eax, (gruvboxBg * 16) + gruvboxRed
    call SetTextColor
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    jmp show_logout_options

do_logout:
    mov eax, (gruvboxBg * 16) + gruvboxFg ; Reset color
    call SetTextColor
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

check_seat_availability PROC
    ; Input: selectedSeat contains seat selection
    ;        dateInput contains selected date
    ; Output: Carry flag set if seat is taken, clear if available
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Convert date input to comparable format
    movzx eax, BYTE PTR [dateInput]      ; First digit of month
    sub al, '0'
    mov bl, 10
    mul bl
    movzx ebx, BYTE PTR [dateInput + 1]  ; Second digit of month
    sub bl, '0'
    add al, bl                           ; AL now contains month number
    mov dl, al                           ; Save month in DL

    movzx eax, BYTE PTR [dateInput + 2]  ; First digit of day
    sub al, '0'
    mov bl, 10
    mul bl
    movzx ebx, BYTE PTR [dateInput + 3]  ; Second digit of day
    sub bl, '0'
    add al, bl                           ; AL now contains day number
    mov dh, al                           ; Save day in DH

    ; Check against existing bookings
    mov esi, OFFSET seatBookings
    mov ecx, MAX_TICKETS

check_booking_loop:
    ; If entry is empty (month = 0), skip it
    cmp BYTE PTR [esi], 0
    je next_booking
    
    ; Compare month
    cmp [esi], dl
    jne next_booking
    
    ; Compare day
    cmp [esi + 1], dh
    jne next_booking
    
    ; Compare seat row
    mov al, [selectedSeat]
    cmp [esi + 2], al
    jne next_booking
    
    ; Compare seat number
    mov al, [selectedSeat + 1]
    cmp [esi + 3], al
    je seat_is_taken

next_booking:
    add esi, 4        ; Move to next booking entry
    loop check_booking_loop
    
    ; Seat is available
    clc               ; Clear carry flag
    jmp check_done

seat_is_taken:
    stc               ; Set carry flag

check_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
check_seat_availability ENDP

update_seat_layout PROC
    ; Creates a dynamic seat layout showing taken seats
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; First, copy the original layout to dynamic layout
    mov esi, OFFSET seatLayout
    mov edi, OFFSET dynamicSeatLayout
    mov ecx, 255
    rep movsb

    ; Get current date in comparable format
    movzx eax, BYTE PTR [dateInput]      ; Month first digit
    sub al, '0'
    mov bl, 10
    mul bl
    movzx ebx, BYTE PTR [dateInput + 1]  ; Month second digit
    sub bl, '0'
    add al, bl                           ; AL = month
    mov dl, al                           ; Store month in DL

    movzx eax, BYTE PTR [dateInput + 2]  ; Day first digit
    sub al, '0'
    mov bl, 10
    mul bl
    movzx ebx, BYTE PTR [dateInput + 3]  ; Day second digit
    sub bl, '0'
    add al, bl                           ; AL = day
    mov dh, al                           ; Store day in DH

    ; Now mark taken seats by scanning the seatBookings array
    mov esi, OFFSET seatBookings
    mov ecx, MAX_TICKETS

update_layout_loop:
    ; Check if this is a valid booking (month != 0)
    cmp BYTE PTR [esi], 0
    je next_seat_update

    ; Compare current date with booking date
    mov al, [esi]      ; Booking month
    cmp al, dl         ; Compare with our month
    jne next_seat_update

    mov al, [esi + 1]  ; Booking day
    cmp al, dh         ; Compare with our day
    jne next_seat_update

    ; If we get here, this booking is for the current date
    ; Now locate the corresponding seat in the dynamicSeatLayout
    mov al, [esi + 2]  ; Get row letter (A-E)
    mov bl, [esi + 3]  ; Get seat number (1-4)

    ; Find the correct location in dynamicSeatLayout
    ; First, calculate the start of the correct row in the layout
    mov edi, OFFSET dynamicSeatLayout

    ; Row A starts at line 3, which is after the header lines
    ; Row B starts at line 4, etc.
    ; Each row has CRLF at the end, so offset is 2 bytes per line
    cmp al, 'A'
    je row_A
    cmp al, 'B'
    je row_B
    cmp al, 'C'
    je row_C
    cmp al, 'D'
    je row_D
    cmp al, 'E'
    je row_E
    jmp next_seat_update ; Invalid row

row_A:
    add edi, 52  ; Offset to beginning of "A [ ][ ]   [ ][ ]"
    jmp find_column
row_B:
    add edi, 68  ; Offset to beginning of "B [ ][ ]   [ ][ ]"
    jmp find_column
row_C:
    add edi, 102  ; Offset to beginning of "C [ ][ ]   [ ][ ]"
    jmp find_column
row_D:
    add edi, 118  ; Offset to beginning of "D [ ][ ]   [ ][ ]"
    jmp find_column
row_E:
    add edi, 134  ; Offset to beginning of "E [ ][ ]   [ ][ ]"

find_column:
    ; Now find the correct column (seat position)
    cmp bl, '1'
    je seat_1
    cmp bl, '2'
    je seat_2
    cmp bl, '3'
    je seat_3
    cmp bl, '4'
    je seat_4
    jmp next_seat_update ; Invalid seat number

seat_1:
    add edi, 3  ; Position at "[ ]" - first seat
    jmp mark_x
seat_2:
    add edi, 6  ; Position at "[ ]" - second seat
    jmp mark_x
seat_3:
    add edi, 12  ; Position at "[ ]" - third seat (after gap)
    jmp mark_x
seat_4:
    add edi, 15  ; Position at "[ ]" - fourth seat

mark_x:
    ; Now we're positioned at the first bracket of the seat
    ; We need to replace the space between brackets with X
    inc edi  ; Move to the space character between [ and ]
    mov BYTE PTR [edi], 'X'  ; Replace space with X

next_seat_update:
    add esi, 4  ; Move to next booking entry
    loop update_layout_loop

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
update_seat_layout ENDP

mark_seat_taken PROC
    ; Input: ESI points to booking entry (month, day, row, number)
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Find the correct location in dynamicSeatLayout
    mov al, [esi + 2]     ; Get row letter (A-E)
    mov bl, [esi + 3]     ; Get seat number (1-4)

    ; Calculate position in layout
    mov edi, OFFSET dynamicSeatLayout

    ; Determine row offset
    cmp al, 'A'
    je row_A_pos
    cmp al, 'B'
    je row_B_pos
    cmp al, 'C'
    je row_C_pos
    cmp al, 'D'
    je row_D_pos
    cmp al, 'E'
    je row_E_pos
    jmp mark_done         ; Invalid row

row_A_pos:
    add edi, 52           ; Position at start of row A
    jmp find_seat_pos
row_B_pos:
    add edi, 68           ; Position at start of row B
    jmp find_seat_pos
row_C_pos:
    add edi, 102          ; Position at start of row C
    jmp find_seat_pos
row_D_pos:
    add edi, 118          ; Position at start of row D
    jmp find_seat_pos
row_E_pos:
    add edi, 134          ; Position at start of row E

find_seat_pos:
    ; Find seat column
    cmp bl, '1'
    je col_1_pos
    cmp bl, '2'
    je col_2_pos
    cmp bl, '3'
    je col_3_pos
    cmp bl, '4'
    je col_4_pos
    jmp mark_done         ; Invalid column

col_1_pos:
    add edi, 3            ; Position at the first "[ ]"
    jmp place_x
col_2_pos:
    add edi, 6            ; Position at the second "[ ]"
    jmp place_x
col_3_pos:
    add edi, 12           ; Position at the third "[ ]" (after gap)
    jmp place_x
col_4_pos:
    add edi, 15           ; Position at the fourth "[ ]"

place_x:
    ; Now we're at the first bracket of the seat
    inc edi               ; Move to space between brackets
    mov BYTE PTR [edi], 'X'  ; Replace with X

mark_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
mark_seat_taken ENDP

store_booking PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    ; Find next free booking slot
    mov esi, OFFSET seatBookings
    mov ecx, MAX_TICKETS

find_slot:
    cmp BYTE PTR [esi], 0
    je slot_found
    add esi, 4
    loop find_slot
    jmp store_done     ; No free slots (shouldn't happen with MAX_TICKETS check)

slot_found:
    ; Store month
    mov al, [dateInput]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, [dateInput + 1]
    sub bl, '0'
    add al, bl
    mov [esi], al

    ; Store day
    mov al, [dateInput + 2]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, [dateInput + 3]
    sub bl, '0'
    add al, bl
    mov [esi + 1], al

    ; Store seat row and number
    mov al, [selectedSeat]
    mov [esi + 2], al
    mov al, [selectedSeat + 1]
    mov [esi + 3], al

store_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
store_booking ENDP
END main
