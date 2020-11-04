#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text
addi 		$7, $0, 0x10010000	# initialize dmem
li $sp, 0x7fffeffc  # set the stack pointer

addi $1, $0, 1
addi $2, $0, -1
addi $3, $0, 4
addi $4, $0, 1

bne  $1, $2, part1

part1:

beq	 $1, $4, part2

part2:

j main 
add $5, $0, 1

main:
lui $1, 1
jal procedure
lui $2, 10

procedure:
lui $1, 3
jr $ra

addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt
