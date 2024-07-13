    .section  .rodata

.printLen:      .string	"first pstring length: %d, second pstring length: %d\n"                 # print parameters for case 50 and 60
.scanfStr:      .string	" %c %c"                                                                # Scan 2 characters from the user(scanf puts them in %rsi and %rdx)
.scanfInt:      .string	" %hhu %hhu"                                                            # Scan 2 shorts
.swapChar:      .string	"old char: %c, new char: %c, first string: %s, second string: %s\n"
.stringPlusLen: .string	"length: %d, string: %s\n"
.swappedStr:    .string "length: %d, string: %s\n"
.indexCmp:      .string "compare result: %d\n"
.exception:     .string "invalid option!\n"

# Jump table
    .align 16
.jmpTable:
    .quad   .L50                                # User option 50
    .quad   .Ldefault                           # Invalid case - option 51
    .quad   .L52                                # User option 52
    .quad   .L53                                # User option 53
    .quad   .L54                                # User option 54
    .quad   .L55                                # User option 55
    .quad   .Ldefault                           # Invalid case - option 56
    .quad   .Ldefault                           # Invalid case - option 57
    .quad   .Ldefault                           # Invalid case - option 58
    .quad   .Ldefault                           # Invalid case - option 59
    .quad   .L50                                # User option 60 - same as 50

    .text
    .globl  funcSelect
    .type   funcSelect, @function
funcSelect:
    pushq	%r12                                # backup %r12
    pushq   %r13                                # backs up %r13
    pushq   %rbp                                # Save the stack pointer
    movq    %rsp, %rbp
    
    # %rdi contains user selection, %rsi contains first pstring pointer, %rdx contains second string pointer
    movq    %rsi, %r12                          # backup first pstring, allows overwriting %rsi
    movq    %rdx, %r13                          # backup second pstring, allows overwriting %rdx

    leaq    -50(%rdi), %rax                     # Offsets the user selection by 50 - %rax holds a number between 1-10(hopefuly)
    cmpq    $10, %rax                           # compares 10 to the content of %rax, executes code accordingly
    ja      .Ldefault                           # in case %rax > 10, jump straight to default case aka incorrect input
    jmp     *.jmpTable(, %rax, 8)               # if %rax <= 10, goto the appropriate spot in .jmpTable

.L50:
    movq	%r12 ,%rdi                          # first pstring will be sent to pstrlen as an argument
    call	pstrlen
    pushq   %rax                                # save return value of pstrlen

    movq	%r13, %rdi                          # second pstring will be sent to pstrlen as an argument
    call	pstrlen			    
    # %rax contains length of second pstring now.

    popq    %rsi                                # second printf argument will hold the first pstring
    movq	%rax, %rdx		                    # third printf argument will hold second pstring
    movq	$.printLen, %rdi
    movq	$0, %rax
    call	printf
	jmp     .end

.L52:
    # Backup registers
    pushq   %r14
    pushq   %r15
    # Nullify register values
    xorq    %r14, %r14
    xorq    %r15, %r15

    subq    $16, %rsp                           # Allocates 8 bytes on the stack for input chars
    
    # Scan characters
    movq    $.scanfStr, %rdi
    leaq    (%rsp), %rsi                        # will scan first char into end of stack frame
    leaq    1(%rsp), %rdx                       # scan and put replacing char into the stack frame
    movq    $0, %rax                            # nullify return value of the scanf function
    call    scanf
    movq    (%rsp), %r14                        # Save character that'll be replaced
    movq    1(%rsp), %r15                       # save the replacing character

    # Replacing character in first Pstring
    movq    %r12, %rdi		                    # first arguemnt is first pstring address
    movq    %r14, %rsi                          # second argument is old char
    movq    %r15, %rdx                          # Third argument is replacing char
    movq    $0, %rax                            
    call    replaceChar
    movq    %rax, %r12                          # %r12 (storing the pointer to first pstring) no longer needed - overwrite
    leaq    1(%r12), %r12                       # move the pstring pointer to point on the first character instead of char len
    
    # Replacing character in second Pstring
    movq	%r13, %rdi
    movq 	%r14, %rsi
    movq 	%r15, %rdx
    movq    $0, %rax
    call	replaceChar
    movq    %rax, %r13
    leaq    1(%r13), %r13                       # move the pstring pointer to point on the first character instead of char len


    /**
    %r12 holds pointer to the altered first pstring
    %r13 holds pointer to the altered second pstring
    */

    # print the replaced strings
    movq	$.swapChar, %rdi		            # Initialize correct printf format
    movq  	%r14, %rsi
    movq    %r15, %rdx
    movq  	%r12, %rcx
    movq  	%r13, %r8
	movq	$0, %rax                            
    call	printf

    # Reset callee registers to previous values
    addq    $2, %rsp
    pop   	%r15
    pop   	%r14

	jmp	    .end                

.L53:
    /**
    %r12 holds first pstring which is dst value for the pstrijcpy function
    %r13 holds second pstring which is src value for the pstrijcpy function
    */ 
    
    # Backup callee saved registers
    pushq	%r14
    pushq   %r15
    
    xorq    %r14, %r14
    xorq    %r15, %r15
    subq    $16, %rsp                           # Allocates 8 bytes on the stack for input chars


    # scan indexes from user
    movq    $.scanfInt, %rdi
    leaq    (%rsp), %rsi
    leaq    8(%rsp), %rdx
    movq    $0, %rax
    call    scanf
    movq    (%rsp), %r14                        # Save index i
    movq    8(%rsp), %r15                       # Save index j

    # call pstrijcmp function
    movq 	%r12, %rdi                          # first argument is first pstring(dst)
    movq 	%r13, %rsi                          # second argument is second pstring(src)
    movq 	%r14, %rdx                          # index i
    movq 	%r15, %rcx                          # index j
    call    pstrijcpy
    movq    %rax, %r12                          # save altered dst string in %r12

    # get the length of both pstrings using pstrlen
    movq    %r12, %rdi                          # altered pstring is the only argument to pstrlen
    call    pstrlen
    movq    %rax, %r14                          # save string length in %r14

    movq    %r13, %rdi                          # only argument given is the src pstring
    call    pstrlen
    movq    %rax, %r15                          # save string length in %r15


    # print altered pstring
    movq	$.stringPlusLen, %rdi
    movq    %r14, %rsi                          # %r14 holds dst string length
    movq  	%r12, %rdx                          # %rdx points to the start of the dst pstring
    leaq    1(%rdx), %rdx                       # move %rdx by 1, to point to the string start, not the string length
	movq	$0, %rax
    call	printf

    # print the src string
    movq	$.stringPlusLen, %rdi
    movq    %r15, %rsi                          # %r15 holds dst string length
    movq    %r13, %rdx                          # %rdx points to the start of the dst pstring
    leaq    1(%rdx), %rdx                       # move %rdx by 1, to point to the string start, not the string length
	movq	$0, %rax
    call	printf

    addq $16, %rsp
    # restore callee registers to previous values
    popq   	%r15
    popq   	%r14
    
    jmp     .end
    

.L54:
    /**
    %r12 holds first pstring
    %r13 holds second pstring
    */ 

    # swap letters in the first string
    movq	%r12, %rdi		                    # first pstring is the argument
    call	swapCase
    movq    %rax, %r12                          # moves updated pstring to %r12

    # get the length of the swapped string
    movq    %r12, %rdi
    call    pstrlen

    # print the updated string and its length
    movq	$.swappedStr, %rdi                  
    movq  	%rax, %rsi                          # %rax holds length of the string - pass as second argument
    movq    %r12, %rdx                          # pass updated pstring as second argument
    leaq    1(%rdx), %rdx                       # skip the first field of %rdx, since it contains the length of the string 
    movq	$0, %rax
    call	printf

    # swap letters in the second string
    movq	%r13, %rdi		                    # second pstring is the argument
    call	swapCase
    movq    %rax, %r13                          # updated pstring will reside in %r13

    # get the length of the swapped string
    movq    %r13, %rdi
    call    pstrlen

    # print the updated string and its length
    movq	$.swappedStr, %rdi 
    movq  	%rax, %rsi                          # %rax holds length of the string - pass as second argument
    movq    %r13, %rdx                          # pass updated pstring as second argument
    leaq    1(%rdx), %rdx                       # skip the first field of %rdx, since it contains the length of the string
    movq	$0, %rax
    call	printf

    jmp     .end


.L55:

    /**
    %r12 holds first pstring
    %r13 holds second pstring
    */ 

    subq    $16, %rsp                           # allocate free space on the stack
    pushq	%r14
    pushq   %r15
    xorq    %r14, %r14
    xorq    %r15, %r15
    
    # scan indeces
    movq    $.scanfInt, %rdi
    leaq    (%rsp), %rsi                        # pass memory address to first parameter 
    leaq    8(%rsp), %rdx                       # pass memory address to second parameter
    movq    $0, %rax
    call    scanf

    # call comparison function
    movq 	%r12, %rdi                          # first argument is the pstring
    movq 	%r13, %rsi                          # second argument passed is secong pstring
    movq 	(%rsp), %rdx                        # third argument is starting index
    movq 	8(%rsp), %rcx                       # fourth argument is end index
    movq    $0, %rax
    call    pstrijcmp

    # print the requested format
    movq	$.indexCmp, %rdi
    movq  	%rax, %rsi
    movq	$0, %rax
    call	printf

    leaq    16(%rsp), %rsp                      # De-allocate space on the stack
    jmp     .end


.Ldefault:
    movq    $.exception, %rdi
    movq	$0, %rax
	call	printf


.end:
    movq    %rbp, %rsp
    popq    %rbp
    popq    %r13
    popq    %r12

    movq    $0, %rax                            # return 0
    ret
