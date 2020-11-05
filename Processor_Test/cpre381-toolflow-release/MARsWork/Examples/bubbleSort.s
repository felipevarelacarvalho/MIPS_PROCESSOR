# BubbleSort in MIPS

# Trevor Rowland, Muhamad Stilic, Felipe Carvalho
# CPR E 381 Project Part B
.data
outputArr: .word 0 : 10

inputArr: .word 0	#this should sort into 0,1,2,3,4,5,6,7,8,9 from an initial 9,8,7,6,5,4,3,2,1
		  .word 1
		  .word 2
		  .word 3
		  .word 4
		  .word 5
		  .word 6
		  .word 7
		  .word 8
		  .word 9
		  

space:.asciiz " "
endline:.asciiz "\n"  

.text

BUBBLESORT:

# getting the address(need to add lab1 above as "lab1: .byte 0xa1" in the .data section)
la 				$s2, inputArr			# load address of inputArr into MIPS

addi 			$a3, $0, 1				#boolean for swap = true (if 0 then swap = false)
addi 			$t0, $0, 0				# i = 0
addi 			$t1, $0, 0				# j = 0
addi			$t3, $0, 0				#addrIterator = 0;

# getting arrLen
add	$t2, $0, $s2 						# $t2 = arr.length
addi $t4, $t2, -4 						# $t2 = arr.length - 1 

Loop1: # First for loop in BubbleSort, loops through the array

	beq $a3, $0, ExitLoop1				# if swap == false then exit bubblesort
	addi $a3, $0, 0						# set swap = false
	
	addi $t3, $0, 0
	la $s2, inputArr
	
	lw $t7, 0($t4)						#pull val at arrLEN -1

	# bge $t0, $t2, ExitLoop1
	slt $t6, $t7, $t1 					# check if j > arr.length - 1
	bne $t6, $0, ExitLoop1 				# check if result of $t > $s is true, if true exit for loop
	
	Loop2: # Second for loop in BubbleSort, decides on whether or not to swap
		
		sll $t9, $t0, 2					# calculate i * 4 for accessing in array
		sub $t5, $t9, $t0 				# set arrLEN-i-1 on every iteration
		
		la $s2, inputArr
		add $s2, $s2, $t3
		
		lw $t8, 0($t5)					# access value in array at arrLEN - i - 1
		# ble $t1, $t5, Loop1: Go back to Loop1 if j >= arrLEN - i - 1
		slt $t6, $t1, $t8				# check if j < arrLEN, if true this outputs 1 which skips over the beq statement below
		beq $t6, $0, ExitLoop2 			# check if result of $t > $s is true, if true exit for loop

		# load from array
		lw $a0, 0($s2)			# $a0 = arr[j];
        lw $a1, 4($s2)			# $a1 = arr[j+1];
		
		# ble $a0, $a1, Update: Skip over swap process if arr[j] <= arr[j+1]
		slt $t6, $a1, $a0
		beq $t6, $0, Update
		
		Swap:
		add $a2, $0, $a0				# int temp = &arr[j];
		add $a0, $0, $a1				# &arr[j] = &arr[j+1];
		add $a1, $0, $a2				# &arr[j+1] = temp;
		addi $a3, $0, 1					# set swap = true;
		
		Update:
		addi $t1, $t1, 1				# j++;
		sll  $t3, $t1, 2				# $t3 = j * 4;
		add $s2, $s2, $t3
		
        j Loop2							# jump to next iteration of for loop
		
	ExitLoop2: 
	addi $t0, $t0, 1					# i++;
	j Loop1
	
ExitLoop1:
	jr $ra
	
# Signals:

# Temps: 
	# $t0: i
	# $t1: j
	# $t2: array length
	# $t3: address incrementer
	# $t4: array length - 1
	# $t5: array length - i - 1
	# $t6: dst1 for the first bge and the 2 ble's
	
# args: 
	# $a0: arr[j]
	# $a1: arr[j+1]
	# $a2: temp
	# $a3: bool for swap
	# $a4: value at arrLEN - 1
	# $a5: value ar arrLEN - i - 1
	# $a6: i * 4
	
# other: 
	#s2: address for the array indexes
	
# // A function to implement bubble sort 
# void bubbleSort(int arr[], int n) 
# { 
#    int i, j; THIS IS TAKEN CARE OF
#    for (i = 0; i < n-1; i++)       
#   
#        // Last i elements are already in place    
#        for (j = 0; j < n-i-1; j++)  
#            if (arr[j] > arr[j+1]) 
#				int temp = &arr[j];
#				&arr[j] = &arr[j+1];
#				&arr[j+1] = &arr[j];
# } 

	
	

































