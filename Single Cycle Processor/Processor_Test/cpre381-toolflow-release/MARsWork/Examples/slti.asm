# data section
.data

# code/instruction section
.text

addi $1, $0, 1		#add positive number to $1
addi $2, $0, -1		#add negative number to $2
addi $3, $0, 0		#add zero to $3

slti $4, $1, -1		#check if positive < negative, should return 0
slti $5, $2, 1		#check if negavtive < positive, should return 1
slti $6, $3, 1		#check if 0 < positive, should return 1
slti $7, $2, 0		#check if negative < 0, should return 1
slti $8, $1, 0		#check if positive < 0, should return 0
slti $9, $3, -1		#check if 0 < negative, should return 0

addi  $2,  $0,  10  # Place "10" in $v0 to signal an "exit" or "halt"
syscall             # Actually cause the halt

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt