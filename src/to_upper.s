# A program which converts all ASCII lowercase characters of
# an input text file to uppercase.
#
# Arguments:
# 1. input file path [STDIN if not supplied]
# 2. output file path [STDOUT if not supplied]
#
# Exit codes:
# 0 - success
# 1 - invalid number of arguments (args > 2)
# 2 - failed to open input file for reading
# 3 - failed to open output file for writing
#

.include "x64-linux-def.s"

.section .data

# expected args = [prog_name (implicit), in_file, out_file]
.equ ARGS_CNT, 3
.equ ARGS_CNT_NO_OUT, 2
.equ ARGS_CNT_NO_IN_OUT, 1

# exit codes
.equ ERR_NUM_ARGS, 1
.equ ERR_OPEN_IN, 2
.equ ERR_OPEN_OUT, 3

# flags for the open syscall
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

.section .bss
.equ BUFFER_SIZE, 500
.lcomm BUFFER_START, BUFFER_SIZE

# BP Offsets.
.equ BPO_ARGV_2, 24   # output file name
.equ BPO_ARGV_1, 16   # input file name
.equ BPO_ARGV_0, 8    # program name
.equ BPO_ARGC, 0      # argc
.equ BPO_FD_IN, -8    # the descriptor for the input file
.equ BPO_FD_OUT, -16  # the descriptor for the output file

.section .text
.globl _start
_start:
    movq %rsp, %rbp

    movq BPO_ARGC(%rbp), %r11        # load argc in %r11

    movq $ERR_NUM_ARGS, %rdi         # exit in case args are more than expected
    cmpq $ARGS_CNT, %r11
    jg exit

    subq $16, %rsp                   # allocate space for the file descriptors on the stack
    movq $STDIN, BPO_FD_IN(%rbp)     # fd_in defaults to STDIN
    movq $STDOUT, BPO_FD_OUT(%rbp)   # fd_out defaults to STDOUT

    cmpq $ARGS_CNT_NO_IN_OUT, %r11
    je read_loop_begin

    cmpq $ARGS_CNT_NO_OUT, %r11
    je open_input_file

# Open output file for writing. Create it if needed, truncate it if it already exists.
    movq $SYS_OPEN, %rax
    movq BPO_ARGV_2(%rbp), %rdi       # path
    movq $O_CREAT_WRONLY_TRUNC, %rsi  # flags
    movq $0666, %rdx                  # -rw-rw-rw-
    syscall

    movq $ERR_OPEN_OUT, %rdi          # exit if out file could not be opened
    cmpq $0, %rax
    jl exit

    movq %rax, BPO_FD_OUT(%rbp)       # save fd_out on the stack

open_input_file:
    movq $SYS_OPEN, %rax
    movq BPO_ARGV_1(%rbp), %rdi   # path
    movq $O_RDONLY, %rsi          # flags
    movq $0666, %rdx              # mode (doesn't really matter for reading)
    syscall

    movq $ERR_OPEN_IN, %rdi       # exit if input file could not be opened
    cmpq $0, %rax
    jl exit

    movq %rax, BPO_FD_IN(%rbp)    # save fd_in on the stack

read_loop_begin:
    movq $SYS_READ, %rax
    movq BPO_FD_IN(%rbp), %rdi   # fd
    movq $BUFFER_START, %rsi     # buff
    movq $BUFFER_SIZE, %rdx      # count
    syscall                      # %rax = number of bytes read

    cmpq $0, %rax                # if no bytes were read, stop
    jle end_loop

# Convert read bytes to uppercase
    movq $BUFFER_START, %rdi     # buffer
    movq %rax, %rsi              # size
    call to_upper                # %rax = size

# Write converted bytes to the output file
    movq BPO_FD_OUT(%rbp), %rdi  # fd
    movq $BUFFER_START, %rsi     # buff
    movq %rax, %rdx              # count
    movq $SYS_WRITE, %rax
    syscall

    jmp read_loop_begin

# Close the files and exit.
end_loop:
    movq $SYS_CLOSE, %rax
    movq BPO_FD_OUT(%rbp), %rdi  # fd
    syscall

    movq $SYS_CLOSE, %rax
    movq BPO_FD_IN(%rbp), %rdi   # fd
    syscall

    movq $0, %rdi                # exit with success

exit:
    movq $SYS_EXIT, %rax
    syscall

#
# Function:
# to_upper(buff_start: u64, buff_size: u64) -> buff_size
#
# Converts the ASCII the bytes at [buff_start, buff_start + buff_size) to uppercase.
#
# Uses the System V AMD64 ABI
#
# Parameters:
# 1. %rdi - buff_start
# 2. %rsi - buff_size
#
# Register variables:
# 1. %r11 - buff index
# 2. %al (LSB of %rax) - current byte
#

.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPER_CONVERSION, ('A' - 'a')

to_upper:
    movq $0, %r11                 # index = 0

to_upper_loop_start:
    cmpq %rsi, %r11               # if index >= size, we are done
    jge to_upper_loop_end

    movb (%rdi, %r11, 1), %al     # current = buff_start[index * 1]

    cmpb $LOWERCASE_A, %al        # skip non-lowercase bytes
    jl convert_next_byte
    cmpb $LOWERCASE_Z, %al
    jg convert_next_byte

    addb $UPPER_CONVERSION, %al   # convert current byte
    movb %al, (%rdi, %r11, 1)     # buff_start[index * 1] = converted_byte

convert_next_byte:
    incq %r11                     # index += 1
    jmp to_upper_loop_start

to_upper_loop_end:
    movq %rsi, %rax
    ret
