# data section
.data

# code/instruction section
.text
#need to make a register that stores shamt
addi $1, $0, 4 #this will be our shamt value
addi $2, $0, 4
addi $3, $0, 7
addi $4, $0, 15

srav $5, $2, $1
srav $6, $3, $1
srav $7, $4, $1


addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt