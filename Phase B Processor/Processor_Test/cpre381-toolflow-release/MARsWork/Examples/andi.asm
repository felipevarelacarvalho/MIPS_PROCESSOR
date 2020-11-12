# data section
.data

# code/instruction section
.text
addi $1,  $0,  2		# add 2 to register 1
addi $10, $0,  1		# add 1 to register 10
addi $2,  $0, -1		# add -1 to register 2
addi $3,  $0, -8		# add -8 to register 3
addi $4,  $0,  0		# add 0 to register 4 

andi  $1,  $1,  0		# and a positive number($2) and 0 together
andi  $10, $10, 0		# and a positive number($10) and a negative number together
andi  $1,  $1,  1		# and a positive number($1) and a positive number together
andi  $2,  $2,  -8		# and a negative number($2) and a negative number together
andi  $2,  $2,  0		# and a negative number($2) and zero together


addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt