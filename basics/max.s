# Find the maximum of an array of integers
# and exit with exit code = its value

# Variables:
# %rdi - the index of the current item
# %rbx - the max so far
# %rax - the current item

# Memory locations:
# data_items - the array, terminated by 0

.section .data

data_items:
.8byte 3,67,34,222,45,75,54,34,44,33,121,12,0

.section .text

.globl _start
_start:
movq $0, %rdi                      # index = 0
movq data_items(,%rdi,8), %rax     # current = data_items[8*0]
movq %rax, %rbx                    # max = current

loop_start:
cmpq $0, %rax                      # break if array end was reached
je loop_exit

incq %rdi                          # index += 1
movq data_items(,%rdi, 8), %rax    # current = data_items[8 * index]
cmpq %rbx, %rax                    # if current <= max proceed with next item
jle loop_start

movq %rax, %rbx                    # max = current
jmp loop_start                     # proceed with next item

loop_exit:
movq $1, %rax                      # the exit syscall number
int $0x80                          # generate software interrupt
