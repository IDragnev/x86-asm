# Algorithms on arrays of 64-bit integers

.section .data

.section .text

.globl max

#
# Function:
# max(array_start, array_size) -> max_value
#
# Returns 0 if `array_start` is null or `array_size` <= 0.
#
# Uses the System V AMD64 ABI
#
# Parameters:
# 1. %rdi - array_start
# 2. %rsi - array_size
#
# Register variables:
# 1. %r8 - the array index
# 2. %r9 - current array element
# 3. %rax - max
#
.type max, @function
max:
    movq $0, %rax               # max = 0
    cmpq $0, %rdi               # if array_start is null, we are done
    je max_exit

    movq $0, %r8                # index = 0

max_loop_start:
    cmpq %rsi, %r8              # if index >= array_size, we are done
    jge max_exit

    movq (%rdi, %r8, 8), %r9    # current = array[8 * index]
    incq %r8                    # index += 1

    cmpq %rax, %r9              # if current <= max, proceed with next item
    jle max_loop_start

    movq %r9, %rax              # else max = current
    jmp max_loop_start

max_exit:
    ret
