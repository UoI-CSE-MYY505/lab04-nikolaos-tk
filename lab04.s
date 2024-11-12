
.globl str_ge, recCheck

.data

maria:    .string "Maria"
markos:   .string "Markos"
marios:   .string "Marios"
marianna: .string "Marianna"

.align 4  # make sure the string arrays are aligned to words (easier to see in ripes memory view)

# These are string arrays
# The labels below are replaced by the respective addresses
arraySorted:    .word maria, marianna, marios, markos

arrayNotSorted: .word marianna, markos, maria

.text

            la   a0, arrayNotSorted
            li   a1, 4
            jal  recCheck

            li   a7, 10
            ecall

# a0 - address of string 1
# a1 - address of string 2
# strings are null terminated.
str_ge:
            lbu  t0, 0(a0)     # load current char of first string to register t0
            lbu  t1, 0(a1)	   # load current char of second string to register t1
            sub  t2, t0,   t1  # result: 0 if equal,
                               # >0 if char @a0 "higher", <0 if char @a1 "higher"
            addi a0, a0,   1   # move to next char of first string
            addi a1, a1,   1   # move to next char of second string
            add  t3, t1,   t0  # if the sum is equal to either one, one must be 0
            beq  t3, t0,   ret_strcmp  # any string finished, leave
            # I could have compared each of t0, t1 to zero. Still 2 instructions (beq's)
            beq  t2, zero, str_ge  # still equal, loop
ret_strcmp:
            srli a0, t2, 31  # get the sign bit. If 1, negative, so strictly less
            xori a0, a0, 1   # Invert it. So a0 is 1 if greater or equal.
            jr   ra
 
# ----------------------------------------------------------------------------
# recCheck(array, size)
# if size == 0 or size == 1
#     return 1
# if str_ge(array[1], array[0])      # if first two items in ascending order,
#     return recCheck(&(array[1]), size-1)  # check from 2nd element onwards
# else
#     return 0

# a0, the string array start address
# a1, the string array size
recCheck:
            slti t0, a1,   2
            beq  t0, zero, checkFirstTwo
            addi a0, zero, 1  # return 1
            jr   ra
checkFirstTwo:
			# push
            addi sp, sp,   -12
            sw   ra, 8(sp)  # store return address
            sw   a0, 4(sp)  # store first string
            sw   a1, 0(sp)  # store second string
            lw   a1, 0(a0)  # load first string to register a1
            lw   a0, 4(a0)  # load second string to register a2
            jal  str_ge
            beq  a0, zero, return  # return 0, a0 is already 0
			
            # do recursion
            lw   a0, 4(sp)     # load array start address (original a0) to register a0
            lw   a1, 0(sp)	   # load array size (original a1) to register a1
            addi a0, a0,   4   # get next string of array
            addi a1, a1,   -1  # decrease array size by 1
            jal  recCheck	   # recursion call
return:
			# pop
            lw   ra, 8(sp)     # load return address from stack
            addi sp, sp,   12 
            jr   ra
