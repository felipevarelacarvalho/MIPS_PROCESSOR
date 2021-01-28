# data section
.data

# code/instruction section
.text
addi $7, $0, 4
addi $8, $0, 5
addi $9, $0, 6

addi $1, $0, 15
addi $2, $0, 7
addi $3, $0, 24

sllv $4, $1, $7
sllv $5, $2, $8
sllv $6, $3, $9


addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt