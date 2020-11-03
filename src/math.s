# Math functions

.section .data

.section .text
.globl factorial
.globl rfactorial
.globl power

#
# Function:
# fact(n: u64) = n!
#
# Uses the System V AMD64 ABI
#
# Parameters:
# 1. %rdi - n
#
.type factorial, @function
factorial:
    pushq %rbp            # save caller's BP
    movq %rsp, %rbp       # BP --> [caller's BP]

    movq $1, %rax         # result = 1

fact_loop_start:
    cmpq $1, %rdi         # if n <= 1, we are done
    jle end_factorial

    mulq %rdi             # result *= n
    decq %rdi             # n -= 1
    jmp fact_loop_start

end_factorial:
    leave
    ret

#
# Function:
# rfact(n: u64) = n!
#
# Uses the System V AMD64 ABI
#
# Parameters:
# 1. %rdi - n
#
.type rfactorial, @function
rfactorial:
    pushq %rbp            # save caller's BP
    movq %rsp, %rbp       # BP --> [caller's BP]

    movq $1, %rax         # result = 1
    cmpq $1, %rdi         # if n <= 1, we are done
    jle rfact_end

    decq %rdi             # n -= 1
    call rfactorial       # %rax = (n - 1)!

    incq %rdi             # restore n
    mulq %rdi             # result *= n

rfact_end:
    leave
    ret

#
# Function:
# pow(base: i64, power: u64) -> i64
#
# Uses the System V AMD64 ABI
#
# Parameters:
# 1. %rdi - base
# 2. %rsi - power
#
.type power, @function
power:
    pushq %rbp             # save caller BP
    movq %rsp, %rbp        # BP --> [caller BP]

    movq $1, %rax          # result = 1
    cmpq $0, %rsi          # if power == 0, we are done
    je end_power

    movq %rdi, %rax        # result = base

power_loop_start:
    cmpq $1, %rsi          # if power == 1, we are done
    je end_power

    imulq %rdi             # result *= base
    decq %rsi              # power -= 1
    jmp power_loop_start

end_power:
    leave
    ret
