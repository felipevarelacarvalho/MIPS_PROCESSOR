# data section
.data

# code/instruction section
.text
addi $7, $0, 2
addi $8, $0, 3
addi $9, $0, 4

addi $1, $0, 7
addi $2, $0, 16
addi $3, $0, 24

srlv $4, $1, $7
srlv $5, $2, $8
srlv $6, $3, $9

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt