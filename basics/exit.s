# A simple program that exits and returns a status
# code back to the Linux kernel

.section .data

.section .text
.globl _start
_start:
movl $1, %eax    # the exit syscall number
movl $0, %ebx    # the exit code of the program

int $0x80        # generate a software interrupt
