# data section
.data

# code/instruction section
.text

# main:
# lui $1, 1
# jal procedure
# lui $2, 10

lui $1, 3
jr $ra


addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt