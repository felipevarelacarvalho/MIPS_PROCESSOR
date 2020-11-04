# data section
.data

# code/instruction section
.text

addi $1, $0, 5



addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt