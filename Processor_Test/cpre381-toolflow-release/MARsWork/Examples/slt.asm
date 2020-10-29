# data section
.data

# code/instruction section
.text

addi $1, $0, 1		#add positive number to $1
addi $2, $0, -1		#add negative number to $2
addi $3, $0, 0		#add zero to $3

sltu $4, $1, $2		#check if positive < negative, should return 0
slt $5, $2, $1		#check if negavtive < positive, should return 1
slt $6, $3, $1		#check if 0 < positive, should return 1
slt $7, $2, $3		#check if negative < 0, should return 1
slt $8, $1, $3		#check if positive < 0, should return 0
slt $9, $3, $2		#check if 0 < negative, should return 0

addi  $2,  $0,  10  # Place "10" in $v0 to signal an "exit" or "halt"
syscall             # Actually cause the halt