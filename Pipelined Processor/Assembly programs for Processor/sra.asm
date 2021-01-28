# data section
.data

# code/instruction section
.text
#initializing 
addi $1, $0, 31
addi $2, $0, 24
addi $3, $0, 17

sra $4, $1, 4
sra $5, $2, 3
sra $6, $3, 4

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt