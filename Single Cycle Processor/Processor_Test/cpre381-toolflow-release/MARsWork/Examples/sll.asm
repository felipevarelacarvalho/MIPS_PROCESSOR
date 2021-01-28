# data section
.data

# code/instruction section
.text
addi $1, $0, 15
addi $2, $0, 7
addi $3, $0, 24

sll $4, $1, 4
sll $5, $2, 5
sll $6, $3, 6

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt