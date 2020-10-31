# A recursive implementation of factorial

.section .data

.section .text
.globl rfactorial

#
# Function:
# fact(n) = n!, where n >= 0 (returns 1 for n < 0)
#
# Uses the C calling convention
#
.type rfactorial, @function
rfactorial:
    pushq %rbp            # save caller's BP
    movq %rsp, %rbp       # BP --> [caller's BP]
    
    movq 16(%rbp), %rax   # result = n
    cmpq $0, %rax         # if n <= 0, return 1
    jg positive_n

    movq $1, %rax         # result = 1
    jmp end_factorial 

positive_n:
    cmpq $1, %rax         # if n == 1, we are done
    je end_factorial
    
    decq %rax
    pushq %rax            # recursive call with n - 1
    call rfactorial       # %rax = (n - 1)!

    movq 16(%rbp), %rbx   # load n in %rbx since the rec. call overwrote %rax
    imulq %rbx, %rax      # result *= n

end_factorial:
    movq %rbp, %rsp       # clear local variable storage; SP --> [callers' BP]
    popq %rbp             # restore BP; SP --> [return addr]
    ret
