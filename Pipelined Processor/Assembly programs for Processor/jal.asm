# data section
.data

# code/instruction section
.text
main:    #assume value a is already in $t0, b in $t1
	li $sp, 0x7fffeffc  # set the stack pointer 
	addi $t0, $0, 2
	addi $t1 ,$0, 3
    add $a0,$0,$t0   # it's the same function as move the value
    add $a1,$0,$t1 
    jal addthem      # call procedure
    add $t3,$0,$v0   # move the return value from $v0 to where we want
    addi  $2,  $0,  10      # Place "10" in $v0 to signal an "exit" or "halt"
	syscall                 # Actually cause the halt

addthem:
    addi $sp,$sp,-4     # Moving Stack pointer
    sw $t0, 0($sp)      # Store previous value

    add $t0,$a0,$a1     # Procedure Body
    add $v0,$0,$t0      # Result

    lw $t0, 0($sp)      # Load previous value
    addi $sp,$sp,4      # Moving Stack pointer 
    jr $ra              # return (Copy $ra to PC)
