# data section
.data

# code/instruction section
.text

sltiu $4, $1, 2		#check if 1 < 2, should return 1
sltiu $5, $2, 1		#check if 2 < 1, should return 0
sltiu $6, $3, 1		#check if 0 < 1, should return 1
sltiu $7, $2, 0		#check if 2 < 0, should return 0
sltiu $8, $1, 0		#check if 1 < 0, should return 0
sltiu $9, $3, 2		#check if 0 < 2, should return 1

addi  $2,  $0,  10  # Place "10" in $v0 to signal an "exit" or "halt"
syscall             # Actually cause the halt