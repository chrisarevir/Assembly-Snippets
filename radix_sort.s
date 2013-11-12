##############################################################################
# File: radix_sort.s
# Skeleton for ECE 15B, Project 2
##############################################################################

	.data
student:
	.asciiz "" 	# Place your name in the quotations in place of Student
	.globl	student
nl:	.asciiz "\n"
	.globl nl
sort_print:
	.asciiz "[Info] Sorted values\n"
	.globl sort_print
initial_print:
	.asciiz "[Info] Initial values\n"
	.globl initial_print
read_msg: 
	.asciiz "[Info] Reading input data\n"
	.globl read_msg
code_start_msg:
	.asciiz "[Info] Entering your section of code\n"
	.globl code_start_msg

arg1:	.word 6                 # Provide the number of inputs
arg2:	.word 268632064			# Provide the base address of array where data will be stored (Assuming 0x10030000 as base address)

## Specify your input data-set in any order you like. I'll change the data set to verify
data1:	.word 8
data2:	.word 7
data3:	.word 3
data4:	.word 5
data5:	.word 6
data6:	.word 3

	.text

	.globl main
main:                       # main has to be a global label
	addi	$sp, $sp, -4	# Move the stack pointer
	sw 	$ra, 0($sp)         # save the return address
			
	li	$v0, 4              # print_str (system call 4)
	la	$a0, student		# takes the address of string as an argument 
	syscall	

	jal process_arguments
	jal read_data			# Read the input data

	j	ready

process_arguments:
	la	$t0, arg1
	lw	$a0, 0($t0)
	la	$t0, arg2
	lw	$a1, 0($t0)
	jr	$ra	

### This instructions will make sure you read the data correctly
read_data:
	move $t1, $a0
	li $v0, 4
	la $a0, read_msg
	syscall
	move $a0, $t1

	la $t0, data1
	lw $t4, 0($t0)
	sw $t4, 0($a1)
	la $t0, data2
	lw $t4, 0($t0)
	sw $t4, 4($a1)
	la $t0, data3
	lw $t4, 0($t0)
	sw $t4, 8($a1)
	la $t0, data4
	lw $t4, 0($t0)
	sw $t4, 12($a1)
	la $t0, data5
	lw $t4, 0($t0)
	sw $t4, 16($a1)
	la $t0, data6
	lw $t4, 0($t0)
	sw $t4, 20($a1)

	jr	$ra


######################### 
## your code goes here ##
#########################

zeroarray:	.space	40	# Up to ten elements can be put here
onearray:	.space 	40	# Up to ten elements can be put here
radix_sort:	
	# $a3 word width (bytes long) [currently 4]
	# $a2 log_2 of radix (how many bytes looked at?)
	# $a1 holds the base for array of numbers
	# $a0 holds the number of elements in array
	# $t0-1 are the bases for arrays that had 0-1 as values
	
	
	addi 	$a2,$0,1	# log_2 radix = 1
	addi	$a3,$0,4	# word width is 4 bytes long currently

	addi	$t0,$0,0	# set t0 = 0
	addi	$t1,$0,1	# t1 =  1
radixmask:
	beq	$t0,$a2,code  	# stop loop when equal to radix mask!
	addi	$t1,$t1,$t1	# basically... 2^n
	addi	$t0,$t0,1	# increment the counter
	j	radixmask       # JUMP
code:
	addi	$t2,$0,0	# t2 = i = 0
	la	$t3, ($a1)      # t3 is a pointer for array $a1

	addi	$s0,$0,0	# For loop length checker
	addi	$s1,$0,1	# s1 is always 1
	addi	$s2,$0,2	# s2 is always 2
	addi	$s3,$t1,-1	# s3 is radix mask
	addi	$s4,$0,4	# s4 is ALWAYS 4
	
	addi	$t5,$0,0	# holds the count of zeros
	addi	$t6,$0,0	# holds the count of ones

	la	$t7, zeroarray	# t7 is the pointer to the zero array
	la	$t8, onearray	# t8 is the pointer to the one array
	addi	$t0,$0,1
count:
	bgt	$t2,$a0,sort	# stop counting, start a sort
	lw	$t4,0($t3)      # load the digits wherever the pointer is pointing to
	and	$t9,$t4,$s3     # finding out whether or not it will be a zero or not
	srav	$t9,$t9,$s0

	div	$t9,$s2         # going to use mod function to figure out previous comment
	mfhi	$t9         # MOD!!!!!
	beq	$t9,$s1,mv2zero	# increase one's count and copy value to temp array0! (if equal!)
mv2one:	
	addi	$t5,$t5,1	# increase the one count
	sw	$t4,0($t7)      # temporarily copy the value into an array
	add	$t7,$t7,4       # increase the pointer
	add	$t2,$t2,$a2     # increase i
	add	$t3,$t3,4       # go to next value in original array
	j 	count
mv2zero:
	addi 	$t6,$t6,1	# increase the zero count
	sw	$t4,0($t8)      # temporarily copy the value into an array
	add	$t8,$t8,4       # increase the pointer
	add 	$t2,$t2,$a2	# increase i
	add	$t3,$t3,4       # go to next value in original array
	j	count
sort:
	addi	$t2,$0,0
	la	$t7, zeroarray	# t7 is the pointer to the zero array
	la	$t8, onearray	# t8 is the pointer to the one array

	mult	$a0,$s4
	mflo	$s3
	sub	$s3,$0,$s3
	add	$t3,$t3,$s3
	
forloop1:
	beq	$t2,$t5,sortp2	# Stop when there are no more useful elements in temp0 array
	lw	$t9,0($t7)      # get number in temp0 array
	sw	$t9,0($a1)      # save it as the new value in original array
	addi	$t7,$t7,4	# increment pointer
	addi	$a1,$a1,4	# increment pointer
	addi	$t2,$t2,1	# increment i
	j 	forloop1        # JUMP!!!!!!
sortp2:
	addi 	$t2,$0,0	# reset i
forloop2:
	beq	$t2,$t6,reset	# Reset process for next bit	
	lw	$t9,0($t8)      # get number from temp1 array
	sw	$t9,0($a1)      # save it as the new value in original array
	addi	$t8,$t8,4	# increment pointer
	addi	$a1,$a1,4	# increment pointer
	addi	$t2,$t2,1	# increment i
	j 	forloop2        # JUMP!!!!!!!
reset:
	sll	$a2,$a2,1       # Used for next bit &&'ing
	add	$t0,$t0,$t0     # 2^i
	add	$t2,$0,$0       # Reset i

	mult	$a0,$s4
	mflo	$s3
	sub	$s3,$0,$s3
	add	$a1,$a1,$s3

	
	la	$t3, ($a1)      # t3 is reset to base of array
	addi	$t4,$0,0	# a[i] doesn't *yet* have a value
	addi	$t5,$0,0	# reset 0 count
	addi	$t6,$0,0	# reset 1 count
	la	$t7, zeroarray	# t7 is the pointer to the zero array
	la	$t8, onearray	# t8 is the pointer to the one array
	addi	$t9,$0,0	# Nothing to && yet
	addi	$s0,$s0,1	# increment length checker
	beq	$s0,$a3,done	# fully exit on equal
	j	count

done:
	jr	$ra


##################################
#Dont modify code below this line
##################################
ready:
	jal	initial_values	# print operands to the console
	
	move 	$t2, $a0
	li 	$v0, 4
	la 	$a0, code_start_msg
	syscall
	move 	$a0, $t2

	jal	radix_sort		# call radix sort algorithm

	jal	sorted_list_print


                            # Usual stuff at the end of the main
	lw	$ra, 0($sp)         # restore the return address
	addi	$sp, $sp, 4
	jr	$ra                 # return to the main program

print_results:
	add 	$t0, $0, $a0    # No of elements in the list
	add 	$t1, $0, $a1    # Base address of the array
	move 	$t2, $a0        # Save a0, which contains element count

loop:	
	beq 	$t0, $0, end_print
	addi 	$t0, $t0, -1
	lw 	$t3, 0($t1)
	
	li 	$v0, 1
	move 	$a0, $t3
	syscall

	li 	$v0, 4
	la 	$a0, nl
	syscall

	addi 	$t1, $t1, 4
	j 	loop
end_print:
	move 	$a0, $t2 
	jr 	$ra	

initial_values: 
	move 	$t2, $a0
        addi	$sp, $sp, -4	# Move the stack pointer
	sw 	$ra, 0($sp)         # save the return address

	li 	$v0,4
	la 	$a0,initial_print
	syscall
	
	move 	$a0, $t2
	jal 	print_results
 	
	move 	$a0, $t2
	lw	$ra, 0($sp)         # restore the return address
	addi	$sp, $sp, 4

	jr 	$ra

sorted_list_print:
	move 	$t2, $a0
	addi	$sp, $sp, -4	# Move the stack pointer
	sw 	$ra, 0($sp)         # save the return address

	li 	$v0,4
	la 	$a0,sort_print
	syscall
	
	move 	$a0, $t2
	jal 	print_results
	
	lw	$ra, 0($sp)         # restore the return address
	addi	$sp, $sp, 4	
	jr 	$ra