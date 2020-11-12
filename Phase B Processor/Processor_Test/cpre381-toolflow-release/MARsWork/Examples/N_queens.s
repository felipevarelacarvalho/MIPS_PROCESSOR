########################################################################################
# Joseph Zambreno
# Department of Electrical and Computer Engineering
# Iowa State University
########################################################################################


# Nqueens.s
########################################################################################
# DESCRIPTION: This file implements a not very useful version of the N-queens algorithm 
# Works for N=8,9 and that's about it. 
#
#
# NOTES:
# 11/05/19 by JAZ::Design created.
########################################################################################


.eqv N 8
.eqv N2 64

.data		 
board: .word 0 : N2
slashCode: .word 0 : N2
backslashCode: .word 0 : N2

space:.asciiz " "
endline:.asciiz "\n"  

     
.text
.globl main
j main 

########################################################################################

initSolution:
  addiu $sp,$sp,-24
  sw $fp,20($sp)
  move $fp,$sp
  sw $4,24($fp)
  sw $0,8($fp)
  beq $0, $0, $L2
  sub $0, $0, $0

$L5:
  sw $0,12($fp)
  beq $0, $0, $L3
  sub $0, $0, $0

$L4:
  lw $2,8($fp)
  sll $2,$2,5
  lw $3,24($fp)
  addu $3,$3,$2
  lw $2,12($fp)
  sll $2,$2,2
  addu $2,$3,$2
  sw $0,0($2)
  lw $2,12($fp)
  addiu $2,$2,1
  sw $2,12($fp)
$L3:
  lw $2,12($fp)
  slti $2,$2,N
  bne $2,$0,$L4
  sub $0, $0, $0

  lw $2,8($fp)
  addiu $2,$2,1
  sw $2,8($fp)
$L2:
  lw $2,8($fp)
  slti $2,$2,N
  bne $2,$0,$L5
  sub $0, $0, $0

  sub $0, $0, $0
  move $sp,$fp
  lw $fp,20($sp)
  addiu $sp,$sp,24
  jr $31
  sub $0, $0, $0

printSolution:
  addiu $sp,$sp,-40
  sw $31,36($sp)
  sw $fp,32($sp)
  move $fp,$sp
  sw $4,40($fp)
  sw $0,24($fp)
  beq $0, $0, $L7
  sub $0, $0, $0

$L10:
  sw $0,28($fp)
  beq $0, $0, $L8
  sub $0, $0, $0

$L9:
  lw $2,24($fp)
  sll $2,$2,5
  lw $3,40($fp)
  addu $3,$3,$2
  lw $2,28($fp)
  sll $2,$2,2
  addu $2,$3,$2
  lw $2,0($2)
  move $4,$2
  
  
  li $v0, 1
# Remove to print solution
#  syscall  


  move $t7, $4
  la $a0, space
  li $v0, 4
# Remove to print solution
#  syscall  
  move $4, $t7

    sub $0, $0, $0

  lw $2,28($fp)
  addiu $2,$2,1
  sw $2,28($fp)
$L8:
  lw $2,28($fp)
  slti $2,$2,N
  bne $2,$0,$L9
  sub $0, $0, $0

  move $t7, $4
  la $a0, endline
  li $v0, 4
# Remove to print solution
#  syscall  

  move $4, $t7


  lw $2,24($fp)
  addiu $2,$2,1
  sw $2,24($fp)
$L7:
  lw $2,24($fp)
  slti $2,$2,N
  bne $2,$0,$L10
  sub $0, $0, $0

  sub $0, $0, $0
  move $sp,$fp
  lw $31,36($sp)
  lw $fp,32($sp)
  addiu $sp,$sp,40
  jr $31
  sub $0, $0, $0

isSafe:
  addiu $sp,$sp,-8
  sw $fp,4($sp)
  move $fp,$sp
  sw $4,8($fp)
  sw $5,12($fp)
  sw $6,16($fp)
  sw $7,20($fp)
  lw $2,8($fp)
  sll $2,$2,5
  lw $3,16($fp)
  addu $3,$3,$2
  lw $2,12($fp)
  sll $2,$2,2
  addu $2,$3,$2
  lw $2,0($2)
  sll $2,$2,2
  lw $3,28($fp)
  addu $2,$3,$2
  lw $2,0($2)
  bne $2,$0,$L12
  sub $0, $0, $0

  lw $2,8($fp)
  sll $2,$2,5
  lw $3,20($fp)
  addu $3,$3,$2
  lw $2,12($fp)
  sll $2,$2,2
  addu $2,$3,$2
  lw $2,0($2)
  sll $2,$2,2
  lw $3,32($fp)
  addu $2,$3,$2
  lw $2,0($2)
  bne $2,$0,$L12
  sub $0, $0, $0

  lw $2,8($fp)
  sll $2,$2,2
  lw $3,24($fp)
  addu $2,$3,$2
  lw $2,0($2)
  beq $2,$0,$L13
  sub $0, $0, $0

$L12:
  move $2,$0
  beq $0, $0, $L14
  sub $0, $0, $0

$L13:
  li $2,1 # 0x1
$L14:
  move $sp,$fp
  lw $fp,4($sp)
  addiu $sp,$sp,8
  jr $31
  sub $0, $0, $0

solveNQueensUtil:
  addiu $sp,$sp,-56
  sw $31,52($sp)
  sw $fp,48($sp)
  move $fp,$sp
  sw $4,56($fp)
  sw $5,60($fp)
  sw $6,64($fp)
  sw $7,68($fp)
  lw $2,60($fp)
  slti $2,$2,N
  bne $2,$0,$L16
  sub $0, $0, $0

  li $2,1 # 0x1
  beq $0, $0, $L17
  sub $0, $0, $0

$L16:
  sw $0,40($fp)
  beq $0, $0, $L18
  sub $0, $0, $0

$L21:
  lw $2,80($fp)
  sw $2,24($sp)
  lw $2,76($fp)
  sw $2,20($sp)
  lw $2,72($fp)
  sw $2,16($sp)
  lw $7,68($fp)
  lw $6,64($fp)
  lw $5,60($fp)
  lw $4,40($fp)
  jal isSafe
  sub $0, $0, $0

  beq $2,$0,$L19
  sub $0, $0, $0

  lw $2,40($fp)
  sll $2,$2,5
  lw $3,56($fp)
  addu $3,$3,$2
  lw $2,60($fp)
  sll $2,$2,2
  addu $2,$3,$2
  li $3,1 # 0x1
  sw $3,0($2)
  lw $2,40($fp)
  sll $2,$2,2
  lw $3,72($fp)
  addu $2,$3,$2
  li $3,1 # 0x1
  sw $3,0($2)
  lw $2,40($fp)
  sll $2,$2,5
  lw $3,64($fp)
  addu $3,$3,$2
  lw $2,60($fp)
  sll $2,$2,2
  addu $2,$3,$2
  lw $2,0($2)
  sll $2,$2,2
  lw $3,76($fp)
  addu $2,$3,$2
  li $3,1 # 0x1
  sw $3,0($2)
  lw $2,40($fp)
  sll $2,$2,5
  lw $3,68($fp)
  addu $3,$3,$2
  lw $2,60($fp)
  sll $2,$2,2
  addu $2,$3,$2
  lw $2,0($2)
  sll $2,$2,2
  lw $3,80($fp)
  addu $2,$3,$2
  li $3,1 # 0x1
  sw $3,0($2)
  lw $2,60($fp)
  addiu $3,$2,1
  lw $2,80($fp)
  sw $2,24($sp)
  lw $2,76($fp)
  sw $2,20($sp)
  lw $2,72($fp)
  sw $2,16($sp)
  lw $7,68($fp)
  lw $6,64($fp)
  move $5,$3
  lw $4,56($fp)
  jal solveNQueensUtil
  sub $0, $0, $0

  beq $2,$0,$L20
  sub $0, $0, $0

  li $2,1 # 0x1
  beq $0, $0, $L17
  sub $0, $0, $0

$L20:
  lw $2,40($fp)
  sll $2,$2,5
  lw $3,56($fp)
  addu $3,$3,$2
  lw $2,60($fp)
  sll $2,$2,2
  addu $2,$3,$2
  sw $0,0($2)
  lw $2,40($fp)
  sll $2,$2,2
  lw $3,72($fp)
  addu $2,$3,$2
  sw $0,0($2)
  lw $2,40($fp)
  sll $2,$2,5
  lw $3,64($fp)
  addu $3,$3,$2
  lw $2,60($fp)
  sll $2,$2,2
  addu $2,$3,$2
  lw $2,0($2)
  sll $2,$2,2
  lw $3,76($fp)
  addu $2,$3,$2
  sw $0,0($2)
  lw $2,40($fp)
  sll $2,$2,5
  lw $3,68($fp)
  addu $3,$3,$2
  lw $2,60($fp)
  sll $2,$2,2
  addu $2,$3,$2
  lw $2,0($2)
  sll $2,$2,2
  lw $3,80($fp)
  addu $2,$3,$2
  sw $0,0($2)
$L19:
  lw $2,40($fp)
  addiu $2,$2,1
  sw $2,40($fp)
$L18:
  lw $2,40($fp)
  slti $2,$2,N
  bne $2,$0,$L21
  sub $0, $0, $0

  move $2,$0
$L17:
  move $sp,$fp
  lw $31,52($sp)
  lw $fp,48($sp)
  addiu $sp,$sp,56
  jr $31
  sub $0, $0, $0

solveNQueens:
  addiu $sp,$sp,-208
  sw $31,204($sp)
  sw $fp,200($sp)
  move $fp,$sp
  la $4, board
  jal initSolution
  sub $0, $0, $0

  sw $0,48($fp)
  sw $0,52($fp)
  sw $0,56($fp)
  sw $0,60($fp)
  sw $0,64($fp)
  sw $0,68($fp)
  sw $0,72($fp)
  sw $0,76($fp)
  sw $0,40($fp)
  beq $0, $0, $L23
  sub $0, $0, $0

$L26:
  sw $0,44($fp)
  beq $0, $0, $L24
  sub $0, $0, $0

$L25:
  lw $3,40($fp)
  lw $2,44($fp)
  addu $3,$3,$2
  lw $4,40($fp)
  sll $5,$4,3
  lw $4,44($fp)
  addu $4,$5,$4
  sll $4,$4,2
  la $2, slashCode
  addu $2,$4,$2
  sw $3,0($2)
  lw $3,40($fp)
  lw $2,44($fp)
  subu $2,$3,$2
  addiu $3,$2,7
  lw $4,40($fp)
  sll $5,$4,3
  lw $4,44($fp)
  addu $4,$5,$4
  sll $4,$4,2
  la $2, backslashCode
  addu $2,$4,$2
  sw $3,0($2)
  lw $2,44($fp)
  addiu $2,$2,1
  sw $2,44($fp)
$L24:
  lw $2,44($fp)
  slti $2,$2,N
  bne $2,$0,$L25
  sub $0, $0, $0

  lw $2,40($fp)
  addiu $2,$2,1
  sw $2,40($fp)
$L23:
  lw $2,40($fp)
  slti $2,$2,N
  bne $2,$0,$L26
  sub $0, $0, $0

  addiu $2,$fp,140
  sw $2,24($sp)
  addiu $2,$fp,80
  sw $2,20($sp)
  addiu $2,$fp,48
  sw $2,16($sp)
  la $7, backslashCode
  la $6, slashCode
    move $5,$0
  la $4, board
    jal solveNQueensUtil
  sub $0, $0, $0

  bne $2,$0,$L27
  sub $0, $0, $0

  move $2,$0
  beq $0, $0, $L29
  sub $0, $0, $0

$L27:
  li $2,1 # 0x1
$L29:
  move $sp,$fp
  lw $31,204($sp)
  lw $fp,200($sp)
  addiu $sp,$sp,208
  jr $31
  sub $0, $0, $0

main:

  li $sp, 0x7fffeffc  # set the stack pointer 
  addiu $sp,$sp,-32
  sw $31,28($sp)
  sw $fp,24($sp)
  move $fp,$sp
  jal solveNQueens
  sub $0, $0, $0

  la $4, board
  jal printSolution
  sub $0, $0, $0

  move $2,$0
  move $sp,$fp
  lw $31,28($sp)
  lw $fp,24($sp)
  addiu $sp,$sp,32
  li   $v0, 10          # system call for exit
  syscall               # Exit!
