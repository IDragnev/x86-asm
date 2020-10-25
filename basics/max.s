# Find the maximum of an array of integers
# and exit with exit code = its value

# Variables:
# %edi - the index of the current item
# %ebx - the max so far
# %eax - the current item

# Memory locations:
# data_items - the array, terminated by 0

.section .data

data_items:
.long 3,67,34,222,45,75,54,34,44,33,121,12,0

.section .text

.globl _start
_start:
movl $0, %edi                      # index = 0
movl data_items(,%edi,4), %eax     # current = data_items[0]
movl %eax, %ebx                    # max = current

loop_start:
cmpl $0, %eax                      # break if array end was reached
je loop_exit

incl %edi                          # index += 1
movl data_items(, %edi, 4), %eax   # current = data_items[4 * index]
cmpl %ebx, %eax                    # if current <= max proceed with next item
jle loop_start

movl %eax, %ebx                    # max = current
jmp loop_start                     # proceed with next item

loop_exit:
movl $1, %eax                      # the exit syscall number
int $0x80                          # generate software interrupt
