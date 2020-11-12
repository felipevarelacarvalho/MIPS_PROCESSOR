# data section
.data

# code/instruction section
.text

addi $1, $0, 1
j next

next:

j skip1 
add $1, $1, $1

skip1: 

j skip2
add $1, $1, $1
add $1, $1, $1

skip2: 

j skip3

loop:
add $1, $1, $1
add $1, $1, $1
add $1, $1, $1
j exit

skip3:
j loop

exit:

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt