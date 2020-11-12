# data section
.data

# code/instruction section
.text

addi $1, $0, 1
addi $2, $0, 3
addi $3, $0, 3

beq $1, $3, EXIT #should keep going here
beq $2, $3, EXIT #now it branches to exit

EXIT:

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt