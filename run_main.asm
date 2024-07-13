	.section	   .rodata
scnafIntFormat:    .string	" %hhu"
scanfStrFormat:    .string " %s"


    .text
    .globl  run_main
    .type   run_main, @function
run_main:
    pushq   %r12                                # save additional registers that the program will use
    pushq   %r13
    pushq   %r14
    pushq   %rbp                                # save previous RBP value
    movq    %rsp, %rbp                          # sets %rbp to point to the beggining of the stack frame

    xorq    %r12, %r12                          # initialize registers to 0
    xorq    %r13, %r13
    xorq    %r14, %r14                             
    subq    $520, %rsp                          # allocates 1 byte of data per char (255 total), plus another byte for the string length(allocates for both strings - 255*2 + 2 in total)

    # scan the first string's length
    movq    $scnafIntFormat, %rdi               # initializes scanf format
    leaq    (%rsp), %rsi                        # %rsi will contain the address in which the received number will be stored, first address of the stack frame
    movq    $0, %rax                            # nullify return value of the scanf function
    call    scanf                               # calls scanf, will store its value in the stack, after the space allocated for the string
    movq    (%rsp), %r12                        # %r12 now contains to the length of the first string (begins at %rsp, where we stored the length)

    # scan the string iteslf
    movq    $scanfStrFormat, %rdi               # initializes scanf format for string
    leaq    1(%rsp), %rsi                       # %rsi will contain a pointer to the stack frame, right before the integer we recorded previously
    movq    $0, %rax                            # nullify return value of the scanf function
    call    scanf
    movb    %r12b, (%rsp)                       # %rsp was changed, restore it's value to be str 1 length 
    
    leaq    (%rsp), %r12                        # saves first string pointer to %r12

    # scan the second string's length
    movq    $scnafIntFormat, %rdi               # initializes scanf format
    leaq    256(%rsp), %rsi                     # %rsi will contain the address in which the received number will be stored, address on byte 256 of the stack frame
    movq    $0, %rax                            # nullify return value of the scanf function
    call    scanf                               # calls scanf, will store its value in the stack, after the space allocated for the string
    movq    256(%rsp), %r13                     # %r13 will store the size of the string

    # scan the string iteslf
    movq    $scanfStrFormat, %rdi               # initializes scanf format for string
    leaq    257(%rsp), %rsi                     # %rsi will contain a pointer to the stack frame, right before the integer we recorded previously
    movq    $0, %rax                            # nullify return value of the scanf function
    call    scanf
    movb    %r13b, 256(%rsp)                    # %rsp + 256 was changed, restore it's referenced value to be str 2 length

    leaq    256(%rsp), %r13                     # saves second string pointer to %r13

    /**
    At this point, both strings are initialized, %r12 holds first pstring, %r13 holds second pstring
    (both were chosen due to them being callee saved)
    */
    movq    $scnafIntFormat, %rdi               # initializes %rdi for the scanf function
    leaq    -16(%rsp), %rsp                     # allocate temporairy space on the stack
    leaq    (%rsp), %rsi                        
    movq    $0, %rax                            # nullify return value of the scanf function
    call    scanf
    movq    (%rsp), %rdi                        # move user's selection to %rdi - first input to fucntion

    leaq    (%r12), %rsi                        # sets first string as second parameter
    leaq    (%r13), %rdx                        # sets seconds string as third parameter
    call    funcSelect

    movq    %rbp, %rsp                         # sets %rsp to point at the beggining of the stack
    popq    %rbp                               # returns %rbp its previous value, %rsp now points to the treturn address
    popq    %r14
    popq    %r13
    popq    %r12

    movq    $0, %rax                           # main function returns 0
    ret
