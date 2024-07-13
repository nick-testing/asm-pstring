    .section .rodata
.exception:     .string "invalid input!\n"

    .text

    /**
    psterlen function receives a pstring pointer, returns pstring length
    */
    .globl  pstrlen
    .type   pstrlen, @function
pstrlen:
        xorq    %rax, %rax                      # callee saved pointer, can be overwritten, nullify it
        movb    (%rdi), %al                     # move contents of %rdi(the size of the Pstring) to the first byte of %rax
        ret

    /**
    receives pstring, char for replacement and replacing char. Swaps all old character
    instances with replacement char
    %rdi - Pstring
    %rsi - old char
    %rdx - replacement char
    */
    .globl replaceChar
    .type replaceChar, @function
replaceChar:
    pushq   %rdi                                # store the pstring address on the stack
    call    pstrlen                             # get the string's length
    movq    %rax, %rcx
    xorq    %r8, %r8 		                    # %r8 will serve as loop iterator
    leaq    1(%rdi), %rdi                       # change rdi to point to first character

    /**
    loop that iterates over the pstring, swaps all instances of desired char with replacement char
    */
.Lloop1:
    cmpq   %r8, %rcx                            # runs while i < length
    je     .Lend

    cmpb   (%rdi), %sil                         # jumps to swap portion if pstring[i] == replacementChar
    je     .LincSwapCase

    leaq   1(%rdi), %rdi                        # move %rdi to the next char
    incq   %r8                                  # increment i
    jmp    .Lloop1

.LincSwapCase:
    movb    %dl, (%rdi)                         # replace the original character with desired char
    leaq    1(%rdi), %rdi                       # move %rdi to the next char
    incq    %r8                                 # increment i
    jmp     .Lloop1

.Lend:
    popq    %rax                                # pop the string address to return register
    ret

    /**
    receives two Pstring pointers, a sub-string start and end index, copies the 
    sub-string of the second pstring(src) to the first pstring(dst)
    %rdi - dst pstring
    %rsi - src pstring
    %rdx - i (start index)
    %rcx - j (end index)
    */
    .globl pstrijcpy
    .type pstrijcpy, @function
pstrijcpy:
    pushq   %r12                                # backup callee register
    leaq    (%rdi), %r12
    
    # initialize a few storage registers
    xorq    %r8, %r8
    xorq    %r9, %r9
    
    /**
    Input check
    */
    # move length of the pstrings to %r8 and %r9 respectively
    movb    (%rdi), %r8b                        
    movb    (%rsi), %r9b
    subq    $1, %r8                             # subtracts 1 from the length of both pstrings, to account for array indexing from 0 to len - 1
    subq    $1, %r9

    # compares received i with length of both strings
    cmpq    %r8, %rdx                           # compare i to strlen1, if greater than -> print error
    jg      .LprintException
    cmpq    %r9, %rdx                           # compare i to strlen2, if greater than -> print error
    jg      .LprintException
    cmpq    $-1, %rdx                           # check if i is negative
    jle    .LprintException

    cmpq    %r8, %rcx                           # compare j to strlen1, if greater than -> print error
    jg      .LprintException
    cmpq    %r9, %rcx                           # compare j to strlen2, if greater than -> print error
    jg      .LprintException
    cmpq    $-1, %rcx                           # check if j is negative
    jle     .LprintException

    # check if j < i:
    cmpq    %rdx, %rcx
    jl      .LprintException  

    # Loop preparations
    leaq    1(%rdi), %rdi                       # move %rdi to point on the first char of the sequence
    leaq    (%rdi, %rdx), %rdi                  # move %rdi i bytes, to the start of the sub string

    # set %rsi to point to start of pstring 2 sub-string
    leaq    1(%rsi), %rsi
    leaq    (%rsi,%rdx), %rsi

    movq    %rdx, %r8 		                    # loop will iterate over %r8. for i in range(i, j + 1)
.Lloop2:
    cmpq   %r8, %rcx                            # compare j - i, if i > j, break.
    jb     .Lend2                           

    movb    (%rsi), %r9b                        # store the the character from the replacing substring temporarily in %r9
    movb    %r9b, (%rdi)                        # swap the old character of the first pstring with the new, stored character

    # increment all the loop variables
    leaq    1(%rdi), %rdi                       # move %rdi to next character of first pstring
    leaq    1(%rsi), %rsi                       # move %rsi to next character of second pstring
    incq    %r8                                 # increment the iterator i; i++
    jmp     .Lloop2

.LprintException:
    movq	$.exception, %rdi
    movq    $0, %rax
    call	printf
.Lend2:
    movq    %r12, %rax                          # return the altered (or non altered) pstring
    popq    %r12
    ret

    /**
    swapCase function receives a pstring pointer, swaps every lowercase letter to uppercase and vice versa
    %rdi holds pointer to pstring.
    */
    .globl swapCase
    .type swapCase, @function
swapCase:
    pushq   %r12                                # backup callee saved register
    xorq    %rsi, %rsi                          # nullify %rsi before using as storage
    xorq    %rdx, %rdx                          # nullify %rdx before using as storage

    leaq    (%rdi), %r12                        # %r12 now holds the pointer to the pstring.
    movb    (%rdi), %sil                        # %rsi will store the length of the string 

    xorq    %r8, %r8 		                    # initialize %r8 before using it to iterate over loop.
    leaq    1(%rdi), %rdi                       # sets the %rdi pointer to point to the first char of the string.


    # The loop will iterate over the string length, changing value of every letter.
.Lloop3:
    cmpq    %r8, %rsi                           # compare i to the length of the string
    je      .Lend3                              # if i == length, break the loop

    movb   (%rdi), %dl                          # store current char in %rdx
    cmpq   $64, %rdx                            # if the char in the i of pstring is larger than 64, jump to letter check
    ja     .LcheckLetter
    jmp    .cont

.LcheckLetter:
    cmpq     $90, %rdx                          # checks if character is between 65 and 90 - an uppercase letter
    jl      .Llowercase

    cmpq     $96, %rdx                          # checks if character is between 91 and 96 - not a letter
    jl      .cont

    cmpq     $122, %rdx                         # checks if char is between 96 and 122 - a lowercase letter
    jl      .Luppercase
    
    jmp     .cont                               # char is not a letter

.Luppercase:
    subq    $32, (%rdi)                         # subtract 32 from the character to make it lowercase
    jmp     .cont

.Llowercase:
    addq    $32, (%rdi)                         # add 32 to the char to make it uppercase

.cont:
    leaq    1(%rdi), %rdi                       # move the string pointer to the next char
    incq    %r8                                 # increment i - i++
    jmp    .Lloop3

.Lend3:
    movq    %r12, %rax                          # set return value to be the altered pstring we saved earlier
    popq    %r12
    ret

    /**
    Receives two pstrings and two indeces, compares each letter of the substrings created by the two indeces.
    return 1 if first substring is larger lexicographically than the second one
    return 0 if two substrings are equal
    return 1 if second substring is larger lexicographically than the first one
    %rdi - first pstring
    %rsi - second pstring
    %rdx - i
    %rcx - j 
    */
    .globl pstrijcmp
    .type pstrijcmp, @function
pstrijcmp:
    # initialize storage registers
    xorq    %r8, %r8
    xorq    %r9, %r9

    movb    (%rdi), %r8b                        # %r8 will store the length of the first pstring 
    movb    (%rsi), %r9b                        # %r9 will store the length of the second pstring
    incq    %rdx                                # adjust i and j so array calculations start from 1 and not from 0
    incq    %rcx

    # compares received i with length of both strings
    cmpq    %r8, %rdx                           # compare i to strlen1, if greater than -> print error
    jg      .LprintException2
    cmpq    %r9, %rdx                           # compare i to strlen2, if greater than -> print error
    jg      .LprintException2
    cmpq    $0, %rdx                            # check if i is negative
    jle    .LprintException2

    # compares received j with length of both strings
    cmpq    %r8, %rcx                           # compare j to strlen1, if greater than -> print error
    jg      .LprintException2
    cmpq    %r9, %rcx                           # compare j to strlen2, if greater than -> print error
    jg      .LprintException2
    cmpq    $0, %rcx                            # check if j is negative
    jle     .LprintException2

    # check if j < i
    cmpq    %rdx, %rcx
    jl      .LprintException2  
    
    # initialize loop
    movq    %rdx, %r8 		                    # %r8 is an iterator for loop, will run from i to j
    leaq    (%rdi, %rdx), %rdi                  # move %rdi's pointer to point to the ith letter
    leaq    (%rsi, %rdx), %rsi                  # move %rsi's pointer to the ith letter of the second pstring

    # the loop will iterate over the substring margins of each pstring
.Lloop4:
    cmpq   %r8, %rcx
    jb     .Lend4                               # if i > j, break

    movb    (%rdi), %dl                         # overwrite first byte of %rdx with current char of the first pstring
    cmpb    (%rsi), %dl                         # compare current char of the first pstring with current char of second pstring
    ja      .Lfirst                             # char from pstring 1 is greater than char from pstring 2
    cmpb    (%rsi), %dl
    jb      .Lsecond                            # char from pstring 2 is greater than char from pstring 1
    
    leaq    1(%rdi), %rdi                       # move %rdi to next char
    leaq    1(%rsi), %rsi                       # move %rsi to next char
    incq    %r8                                 # increment i
    jmp    .Lloop4

    # first string's letter is larger than the second
.Lfirst:
    movq    $1, %rax
    jmp     .Lend4
    
    # second string's letter is larger than the first
.Lsecond:
    movq    $-1, %rax
    jmp     .Lend4


.LprintException2:
    movq	$.exception, %rdi
    movq    $0, %rax
    call	printf
    movq    $-2, %rax

.Lend4:
    ret
