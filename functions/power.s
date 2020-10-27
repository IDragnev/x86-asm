# A simple program which calls a `power`
# function (using the C calling convention)

.section .data

.section .text
.globl _start

#
# Function: pow(base, power) -> base ^ power
# PRECONDITIONS:
#  1. power must be >= 1
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
pushq %rbp              # save callee BP
movq %rsp, %rbp         # BP --> [callee BP]
subq $8, %rsp           # allocate space for acc on the stack

movq 16(%rbp), %rbx     # %rbx = base
movq 24(%rbp), %rcx     # %rcx = power

movq %rbx, -8(%rbp)     # acc = base

power_loop_start:
cmpq $1, %rcx           # if power == 1, we are done
je end_power

movq -8(%rbp), %rax     # temp = acc
imulq %rbx, %rax        # temp *= base
movq %rax, -8(%rbp)     # acc = temp

decq %rcx               # power -= 1
jmp power_loop_start

end_power:
movq -8(%rbp), %rax     # result = acc
movq %rbp, %rsp         # remove local variables from the stack; SP --> [callee BP]
popq %rbp               # retore BP
ret

_start:
pushq $3              # arg 2
pushq $2              # arg 1
call power
addq $16, %rsp        # remove args from the stack
pushq %rax            # save the return value on the stack

pushq $2              # arg 2
pushq $5              # arg 1
call power
addq $16, %rsp        # remove args from the stack, SP --> [ret1]
popq %rbx             # %rbx = ret1
addq %rax, %rbx       # exit code = ret1 + ret2

movq $1, %rax         # the exit syscall number
int $0x80             # generate a software interrupt