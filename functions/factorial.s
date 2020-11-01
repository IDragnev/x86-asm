# An iterative implementation of factorial

.section .data

.section .text
.globl factorial

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

loop_start:
    cmpq $1, %rbx         # if n <= 1, we are done
    jle end_factorial

    imulq %rbx, %rax      # acc *= n
    decq %rbx             # n -= 1
    jmp loop_start

end_factorial:
    movq %rbp, %rsp       # clear local variable storage; SP --> [callers' BP]
    popq %rbp             # restore BP; SP --> [return addr]
    ret
