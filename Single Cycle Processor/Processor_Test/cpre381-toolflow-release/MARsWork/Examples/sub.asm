# data section
.data

# code/instruction section
.text
addi  $1,  $0,  -1 		# Place “1” in $1
addi  $2,  $0,  -1		# Place “1” in $2
sub   $3,  $1,  $2		# subtract $2 from $1, place in $3
sub   $4,  $2,  $3		# subtract $3 from $2, place in $4
sub   $5,  $3,  $4		# subtract $4 from $3, place in $5
sub   $6,  $4,  $5		# subtract $5 from $4, place in $6
sub   $7,  $5,  $6		# subtract $6 from $5, place in $7

addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
syscall                 # Actually cause the halt