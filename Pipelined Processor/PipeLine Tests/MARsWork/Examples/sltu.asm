# data section
.data

# code/instruction section
.text

addi $1, $0, 1		#add positive number to $1
addi $2, $0, 2		#add negative number to $2
addi $3, $0, 0		#add zero to $3

sltu $4, $1, $2		#check if 1 < 2, should return 1
sltu $5, $2, $1		#check if 2 < 1, should return 0
#sltu $6, $3, $1		#check if 0 < 1, should return 1
#sltu $7, $2, $3		#check if 2 < 0, should return 0
#sltu $8, $1, $3		#check if 1 < 0, should return 0
#sltu $9, $3, $2		#check if 0 < 2, should return 1

addi  $2,  $0,  10  # Place "10" in $v0 to signal an "exit" or "halt"
syscall             # Actually cause the halt