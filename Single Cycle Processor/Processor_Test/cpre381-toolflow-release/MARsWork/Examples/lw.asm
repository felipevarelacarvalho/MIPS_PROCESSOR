#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

addi $7, $0, 0x10010000	# initialize dmem

addi  $1, $0, 1			# add a positive number for testing
addi  $2, $0, -1		# add a negative number for testing
addi  $3, $0, 0			# add a zero for testing

sw	  $1,  4($7)		# store a positive number into the register
sw	  $2,  8($7)		# store a negative number into the register
sw	  $3,  12($7)		# store a zero into a register

lw	  $4,  4($7)		# load a positive number into the register
lw	  $5,  8($7)		# load a negative number into the register
lw	  $6,  12($7)		# load a zero into a register

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt
