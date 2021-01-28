# data section
.data

# code/instruction section
.text

addi $1, $0, 7
addi $2, $0, 16
addi $3, $0, 24

srl $4, $1, 2
srl $5, $2, 3
srl $6, $3, 4

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt