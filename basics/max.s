# Find the maximum of an array of integers
# and exit with exit code = its value

# Variables:
# %rdi - the index of the current item
# %rbx - the max so far
# %rax - the current item

# Memory locations:
# array - the array of integers
# array_size - the size of the array

.section .data

array_size:
.8byte 5

array:
.8byte 3,67,34,222,45,250,251

.section .text

.globl _start
_start:
    movq $0, %rdi                      # index = 0
    movq array(,%rdi,8), %rax          # current = array[8*0]
    movq %rax, %rbx                    # max = current

loop_start:
    cmpq array_size, %rdi              # break if index >= size
    jge loop_exit

    movq array(,%rdi, 8), %rax         # current = array[8 * index]
    incq %rdi                          # index += 1
    cmpq %rbx, %rax                    # if current <= max proceed with next item
    jle loop_start

    movq %rax, %rbx                    # max = current
    jmp loop_start                     # proceed with next item

loop_exit:
    movq $1, %rax                      # the exit syscall number
    int $0x80                          # generate software interrupt
