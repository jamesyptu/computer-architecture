.data
EXIT = 60
EXIT_SUCCESS = 0

# dzielna
dividend:	.quad 0xAAAAAAAAAAAAAAAA, 0xFFFFFFFFFFFFFFFF
# długość w bajtach
dividend_len = .-dividend

# dzielnik
divisor:     .quad 0xFFFFFFFFFFFFFFFF
divisor_len = .-divisor

first:    .fill 256       # dzielna
quotient: .fill 128       # suma cząstkowa

# --------------------------------------
# ---------------- MAIN ----------------
# --------------------------------------
.text
.global main
main:

# przepisanie
xorq    %r9, %r9
leaq    dividend, %rbx
movq    divisor(,%r9,8), %r14
call    iloraz

check:
movq    $EXIT, %rax
movq    $EXIT_SUCCESS, %rdi
syscall

# --------------------------------------
# -------------- ILORAZ ----------------
# --------------------------------------
.type iloraz, @function
iloraz:
pushq   %rbp
movq    %rsp, %rbp

# zaokrąglanie mnoznej
xorq    %rdx, %rdx
movq    $dividend_len, %rax
movq    $8, %rcx
idiv    %rcx
movq    %rax, %r9

leaq    first, %rdi
movq    %rbx, %rsi
movq    %rax, %rcx
rep     movsq

# --------------------------------------
# dzielenie: rdx|rax : r14  = rax , rdx
movq    %r9, %rcx         # maksymalny indeks FIRST
leaq    first, %r8
leaq    quotient, %r10
xorq    %rsi, %rsi        # licznik quotient

# outer_loop:
cmpq    $0, %rcx
jle     end_iloraz
decq    %rcx
movq    (%r8,%rcx,8), %rdx    # A
# ---
iloraz_loop:
cmpq    $0, %rcx
jle     end_iloraz
decq    %rcx
movq    (%r8,%rcx,8), %rax    # B
idiv    %r14
movq    %rax, (%r10,%rsi,8)
incq    %rsi
jmp     iloraz_loop

end_iloraz:
movq    %rbp, %rsp
popq    %rbp
ret
