#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

addi 		$7, $0, 0x10010000	# initialize dmem

addi $1, $0, 1
j next

next:

add $2, $1, $1
bne $1, $2, skip1

skip1: 

addi $1, $1, 1
beq $1, $2, skip2

skip2: 

j skip3

loop:
add $1, $1, $1
add $1, $1, $1
add $1, $1, $1
j final

skip3:
j loop

final:
lui $1, 1
jal procedure
lui $2, 10

procedure:
lui $1, 3
jr $ra

addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt
