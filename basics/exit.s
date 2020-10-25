# A simple program that exits and returns a status
# code back to the Linux kernel

.section .data

.section .text
.globl _start
_start:
movq $1, %rax    # the exit syscall number
movq $0, %rbx    # the exit code of the program

int $0x80        # generate a software interrupt
