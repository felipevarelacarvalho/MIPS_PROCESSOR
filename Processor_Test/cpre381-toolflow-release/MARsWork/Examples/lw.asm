#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text
addi  $1, $0, 1			# add a positive number for testing
addi  $2, $0, -1		# add a negative number for testing
addi  $3, $0, 0			# add a zero for testing

lw	  $4,  0x1($1)		# load a positive number into the register
lw	  $5,  0xFF($2)		# load a negative number into the register
lw	  $6,  0x1($3)		# load a zero into a register

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt
