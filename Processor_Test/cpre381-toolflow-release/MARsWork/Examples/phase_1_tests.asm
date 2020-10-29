#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

addi  		$1,  $0,  3 		# Place “3” in $1
addi  		$2,  $0,  1 		# Place “-1” in $2
add  		$3,  $1,  $2 		# Place “2” in $3 (issue)
add  		$4,  $3,  $1 		# Place “5” in $4
add  		$5,  $4,  $2 		# Place “4” in $5
addiu 		$6,  $0,  4			# Place “4” in $6
addu  		$7,  $3,  $4		# Place “7”	in $7 

sub	  		$8,  $1,   $2		# Place “4”	in $8 
subu  		$9,  $8,   $1		# Place “1”in $9 

and	  		$10, $1, $3			# Place “1”	in $10 	
andi  		$11, $1, 3			# Place “3”	in $11
lui	  		$12,	3			# Place “3”	in $12 		
# lw	  		$13,	0x60($2)	# Place “-1”in $13 	(issue #2)

nor	  		$14, $12, $10		# Place “1111-1100”	in $14
xor	  		$15, $4, $3			# Place “3”	in $15
xori		$16, $3, 3			# Place “5”	in $16
or			$17, $12, $10		# Place “3”	in $17 
ori			$18, $3, 3			# Place “3”	in $18 

slt			$19, $1, $2			# Place “0”	in $19
slti		$20, $3, 2			# Place “1”	in $20 
sltiu		$21, $3, 3			# Place “1”	in $21
sltu		$22, $3, $6			# Place “1”	in $22
sll			$23, $1, 4			# Place “48” or “b110000” in $23 
srl			$24, $4, 1			# Place “1” or “b0001” in $24 
sra			$25, $2, 4			# Place “x0FFF FFFF FFFF FFFF”	in $25 

sllv		$26, $17, $6		# Place “48” or “b110000” in $26
srlv		$27, $26, $3		# Place “24” or "b11000”  in $27
srav		$28, $5, $6			# Place “x0FFF FFFF FFFF FFFF”	in $28 
# sw			$29, 0x60($3)		# Place “1”	in $29 

addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt