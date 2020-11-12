#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text
lui $1,  3	#load positive number
lui $2,  0	#load in 0
lui $3,  3	#load positive number
lui $4,  0	#load in 0
lui $5,  3	#load positive number
lui $6,  0	#load in 0
lui $7,  3	#load positive number
lui $8,  0	#load in 0
lui $9,  3	#load positive number
lui $10, 0	#load in 0

addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt
