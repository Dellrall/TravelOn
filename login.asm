 .data
    username_prompt db "Username: ", 0
    password_prompt db "Password: ", 0
    registration_success db "Registration successful!", 10, 0
    login_success db "Login successful!", 10, 0
    login_failure db "Login failed!", 10, 0
    max_username_length equ 32
    max_password_length equ 32
    username_buffer resb max_username_length + 1 ; +1 for null terminator
    password_buffer resb max_password_length + 1
    stored_username db "testuser", 0 ; Example stored username
    stored_password db "password", 0   ; Example stored password

section .bss
    input_buffer resb 256

section .text
    global _start

_start:
    ; Registration (simplified, no actual storage)
    call register
    ; Login
    call login
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

register:
    push rbp
    mov rbp, rsp

    ; Username prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, username_prompt
    mov rdx, username_prompt_len
    syscall

    ; Read username
    mov rax, 0
    mov rdi, 0
    mov rsi, username_buffer
    mov rdx, max_username_length
    syscall

    ; Password prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, password_prompt
    mov rdx, password_prompt_len
    syscall

    ; Read password
    mov rax, 0
    mov rdi, 0
    mov rsi, password_buffer
    mov rdx, max_password_length
    syscall

    ; Registration success message
    mov rax, 1
    mov rdi, 1
    mov rsi, registration_success
    mov rdx, registration_success_len
    syscall

    mov rsp, rbp
    pop rbp
    ret

login:
    push rbp
    mov rbp, rsp

    ; Username prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, username_prompt
    mov rdx, username_prompt_len
    syscall

    ; Read username
    mov rax, 0
    mov rdi, 0
    mov rsi, username_buffer
    mov rdx, max_username_length
    syscall

    ; Password prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, password_prompt
    mov rdx, password_prompt_len
    syscall

    ; Read password
    mov rax, 0
    mov rdi, 0
    mov rsi, password_buffer
    mov rdx, max_password_length
    syscall

    ; Compare username
    mov rsi, username_buffer
    mov rdi, stored_username
    call string_compare
    cmp rax, 0
    jne login_fail

    ; Compare password
    mov rsi, password_buffer
    mov rdi, stored_password
    call string_compare
    cmp rax, 0
    jne login_fail

    ; Login success
    mov rax, 1
    mov rdi, 1
    mov rsi, login_success
    mov rdx, login_success_len
    syscall
    jmp login_end

login_fail:
    ; Login failure
    mov rax, 1
    mov rdi, 1
    mov rsi, login_failure
    mov rdx, login_failure_len
    syscall

login_end:
    mov rsp, rbp
    pop rbp
    ret

string_compare:
    push rbp
    mov rbp, rsp

    xor rax, rax ; Result (0 if equal, non-zero if not)
    mov rcx, 0   ; Counter
compare_loop:
    mov al, byte [rsi + rcx]
    cmp al, byte [rdi + rcx]
    jne compare_not_equal
    cmp al, 0 ; Check for null terminator
    je compare_equal
    inc rcx
    jmp compare_loop

compare_equal:
    mov rax, 0 ; Strings are equal
    jmp compare_end

compare_not_equal:
    mov rax, 1 ; Strings are not equal

compare_end:
    mov rsp, rbp
    pop rbp
    ret

username_prompt_len equ $- username_prompt
password_prompt_len equ $- password_prompt
registration_success_len equ $- registration_success
login_success_len equ $- login_success
login_failure_len equ $- login_failure