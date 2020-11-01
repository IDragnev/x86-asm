# Math functions

.section .data

.section .text
.globl factorial
.globl rfactorial
.globl power

#
# Function:
# fact(n) = n!, where n >= 0 (returns 1 for n < 0)
#
# Uses the C calling convention
#
# Register variables:
# 1. %rax - acc
# 2. %rbx - n
#
.type factorial, @function
factorial:
    pushq %rbp            # save caller's BP
    movq %rsp, %rbp       # BP --> [caller's BP]

    movq $1, %rax         # acc = 1
    movq 16(%rbp), %rbx   # %rbx = n

fact_loop_start:
    cmpq $1, %rbx         # if n <= 1, we are done
    jle end_factorial

    imulq %rbx, %rax      # acc *= n
    decq %rbx             # n -= 1
    jmp fact_loop_start

end_factorial:
    leave
    ret

#
# Function:
# rfact(n) = n!, where n >= 0 (returns 1 for n < 0)
#
# Uses the C calling convention
#
.type rfactorial, @function
rfactorial:
    pushq %rbp            # save caller's BP
    movq %rsp, %rbp       # BP --> [caller's BP]

    movq 16(%rbp), %rax   # result = n
    cmpq $0, %rax         # if n <= 0, return 1
    jg rfact_positive_n

    movq $1, %rax         # result = 1
    jmp rfact_end 

rfact_positive_n:
    cmpq $1, %rax         # if n == 1, we are done
    je rfact_end

    decq %rax
    pushq %rax            # recursive call with n - 1
    call rfactorial       # %rax = (n - 1)!

    movq 16(%rbp), %rbx   # load n in %rbx since the rec. call overwrote %rax
    imulq %rbx, %rax      # result *= n

rfact_end:
    leave    
    ret

#
# Function:
# pow(base, power) -> base ^ power
#
# Uses the C calling convention
#
# PRECONDITIONS:
#  1. power must be >= 0
#
# Register variables:
#  %rbx - base
#  %rcx - power
#  %rax - temp
#
# Local variables:
#  1. acc - accumulator for the return value
#
.type power, @function
power:
    pushq %rbp              # save caller BP
    movq %rsp, %rbp         # BP --> [caller BP]
    subq $8, %rsp           # allocate space for acc on the stack

    movq 24(%rbp), %rcx     # %rcx = power
    cmpq $0, %rcx           # if power == 0, return 1
    je power_early_ret

    movq 16(%rbp), %rbx     # %rbx = base
    movq %rbx, -8(%rbp)     # acc = base

power_loop_start:
    cmpq $1, %rcx           # if power == 1, we are done
    je end_power

    movq -8(%rbp), %rax     # temp = acc
    imulq %rbx, %rax        # temp *= base
    movq %rax, -8(%rbp)     # acc = temp

    decq %rcx               # power -= 1
    jmp power_loop_start

power_early_ret:
    movq $1, -8(%rbp)       # acc = 1

end_power:
    movq -8(%rbp), %rax     # result = acc
    movq %rbp, %rsp         # remove local variables from the stack; SP --> [caller BP]
    popq %rbp               # retore BP
    ret
