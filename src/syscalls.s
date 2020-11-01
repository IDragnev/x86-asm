# Functions for the Linux system calls 
#
# They all use the System V AMD64 ABI
#

.section .data

.section .text

.globl exit

#
# exit(status_code)
#
# Parameters:
# 1. %rdi - status_code
#
.type exit, @function
exit:
    movq $1, %rax     # the exit syscall number
    movq %rdi, %rbx   # the exit code of the program
    int $0x80         # generate a software interrupt
