#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text
addi $1,  $0,  2		# add 2 to register 1
addi $10, $0,  1		# add 1 to register 10
addi $2,  $0, -1		# add -1 to register 2
addi $3,  $0, -8		# add -8 to register 3
addi $4,  $0,  0		# add 0 to register 4 

xor  $1,  $1,  $4		# xor a positive number($2) and 0($4) together
xor  $10, $10, $4		# xor a positive number($10) and a negative number($4) together
xor  $1,  $1,  $10		# xor a positive number($1) and a positive number($10) together
xor  $2,  $2,  $3		# xor a negative number($2) and a negative number($3) together
xor  $2,  $2,  $4		# xor a negative number($2) and zero($4) together

addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt