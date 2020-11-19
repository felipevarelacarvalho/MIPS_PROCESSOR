# Test #1 Doing individual instruction tests with the pipelined processor
# Trevor Rowland, Muhamed Stilic, Felipe Carvalhos
# CPR E 381

# data section
.data

# code/instruction section
.text

addi 		$7, $0, 0x10010000	# initialize dmem
li 			$sp, 0x7fffeffc  	# set the stack pointer

addi  		$1,  $0,  3 		# Place “3” in $1
addi  		$2,  $0,  1 		# Place “1” in $2

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

add  		$3,  $1,  $2 		# Place “4” in $3
addiu 		$4,  $0,  3			# Place “3” in $4
addu  		$5,  $2,  $1		# Place “4”	in $5 

sw	  		$1,  4($7)			# store a positive number into the register

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

lw	  		$2,  4($7)			# load a positive number into the register

addi		$0,  $0,  0			# Place stall

sub	  		$6,  $3,   $4		# Place “1”	in $6 
subu  		$7,  $5,   $4		# Place “1” in $7 

and	  		$8, $5, $4			# Place “4”	in $8	
andi  		$9, $3, 3			# Place “3”	in $9
lui	  		$10,	3			# Place “3”	in $10 		

nor	  		$11, $6, $4			# Place “4”	in $11 
xor	  		$12, $4, $3			# Place “6”	in $12
xori		$13, $3, 3			# Place "6”	in $16

addi		$0,  $0,  0			# Place stall

or			$14, $10, $9		# Place “7”	in $14 
ori			$15, $8, 3			# Place “7”	in $15 

slt			$16, $9, $8			# Place “1”	in $16
slti		$17, $7, 2			# Place “1”	in $17 
sltiu		$18, $13, 3			# Place “0”	in $18
sltu		$19, $12, $11		# Place “1”	in $19

sll			$20, $11, 3			# Place “40” or “b100000” in $20 
srl			$21, $11, 1			# Place “2” or “b010” in $21 
sra			$22, $8, 2			# Place "1" “0001”	in $22 

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

sllv		$23, $17, $16		# Place “2” or “b010” in $23
srlv		$24, $21, $16		# Place “1” or "b001”  in $24
srav		$25, $21, $19		# Place "1" or “b001”	in $25 

bne  		$18, $19, part1		# Since branch is not equal from _ and _, it goes to part1

part1:

beq	 		$16, $17, part2		# Since branch is equal from _ and _, it goes to part2

part2:

j main 							# Jumps to main
add 		$26, $0, 1			# need to atleast be doing something

main:    						#assume value a is already in $t0, b in $t1
li 			$sp, 0x7fffeffc  	#set the stack pointer 
addi 		$t0, $0, 2			#starts temp
addi 		$t1 ,$0, 3			#second temp

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

add 		$a0,$0,$t0   		# it's the same function as move the value
add 		$a1,$0,$t1			# same function 

jal 		addthem      		# call procedure

add 		$t3,$0,$v0   		# move the return value from $v0 to where we want

addi  		$2,  $0,  10      	# Place "10" in $v0 to signal an "exit" or "halt"
syscall                 		# Actually cause the halt

addthem:
addi 		$sp,$sp,-4     		# Moving Stack pointer

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

sw 			$t0, 0($sp)      	# Store previous value

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

add 		$t0,$a0,$a1     	# Procedure Body

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

add 		$v0,$0,$t0      	# Result

lw 			$t0, 0($sp)      	# Load previous value
addi 		$sp,$sp,4      	    # Moving Stack pointer 
jr 			$ra              	# return (Copy $ra to PC)


addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt
