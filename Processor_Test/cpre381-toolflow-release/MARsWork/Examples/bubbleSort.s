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
lw  			$t9, 0($s2)				# $s2 is the address, what do I change $t9 to?

addi 			$a3, $0, 1				#boolean for swap = true (if 0 then swap = false)
addi 			$t0, $0, 0				# i = 0
addi 			$t1, $0, 0				# j = 0
addi			$t3, $0, 0				#addrIterator = 0;

# getting arrLen
add	$t2, $0, $s2 						# $t2 = arr.length
addi $t4, $t2, -1 						# $t2 = arr.length - 1 

Loop1: # First for loop in BubbleSort, loops through the array

	beq $a3, $0, ExitLoop1				# if swap == false then exit bubblesort
	addi $a3, $0, 0						# set swap = false
	
	addi $t3, $0, 0
	la $s2, inputArr

	# bge $t0, $t2, ExitLoop1
	slt $t6, $t1, $t4 					# check if j > arr.length - 1
	beq $t6, $0, ExitLoop1 				# check if result of $t > $s is true, if true exit for loop
	
	Loop2: # Second for loop in BubbleSort, decides on whether or not to swap
	
		sub $t5, $t4, $t0 				# set arrLEN-i-1 on every iteration
		
		
		add $s2, $s2, $t3
		
		# ble $t1, $t5, Loop1: Go back to Loop1 if j >= arrLEN - i - 1
		slt $t7, $t1, $t5				# check if j < arrLEN, if true this outputs 1 which skips over the beq statement below
		beq $t7, $0, ExitLoop2 			# check if result of $t > $s is true, if true exit for loop

		# load from array
		lw $a0, 0($s2)			# $a0 = arr[j];
        lw $a1, 4($s2)			# $a1 = arr[j+1];
		
		# ble $a0, $a1, Update: Skip over swap process if arr[j] <= arr[j+1]
		slt $t8, $a1, $a0
		beq $t8, $0, Update
		
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
	# $t6: dst1 for the first bge
	# $t7: dst2 for the first ble
	# $t8: dst3 for the second ble
	
# args: 
	# $a0: arr[j]
	# $a1: arr[j+1]
	# $a2: temp
	# $a3: bool for swap
	
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

	
	

































