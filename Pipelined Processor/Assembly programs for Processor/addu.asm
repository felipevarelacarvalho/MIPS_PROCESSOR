#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text
addi  $1,  $0,  -1 		# Place “1” in $1
addi  $2,  $0,  -1		# Place “1” in $2
addu   $3,  $1,  $2		# Place the sum of $1 and $2 in $3
addu   $4,  $2,  $3		# Place the sum of $2 and $3 in $4
addu   $5,  $3,  $4		# Place the sum of $3 and $4 in $5
addu   $6,  $4,  $5		# Place the sum of $4 and $5 in $6
addu   $7,  $5,  $6		# Place the sum of $5 and $6 in $7

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt