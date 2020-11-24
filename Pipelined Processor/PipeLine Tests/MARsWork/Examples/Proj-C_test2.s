# Test #2 Doing the modified bubble sort
# Trevor Rowland, Muhamed Stilic, Felipe Carvalhos
# CPR E 381

#data
.data
outputArr: .word 0:10

inputArr: .word 1	#this should sort into 0,1,2,3,4,5,6,7,8,9 from an initial 9,8,7,6,5,4,3,2,1
		  .word 0
		  .word 3
		  .word 2
		  .word 5
		  .word 4
		  .word 7
		  .word 6
		  .word 9
		  .word 8
		  

space:.asciiz " "
endline:.asciiz "\n"
#text
.text


#Current Register definitions:
# $s0 - i
# $s1 - j
# $s2 - addr. of arr[0] or first element in the array
# $s3 - arr.length(based on output array, which should match anyways)
# $s4 - arr.length-1
# $s5 - arr.length-1-i

# $t0 = arr[j]
# $t1 = arr[j+1]
# $t2 = j*4
# $t3 = current address = (addr. of arr[0]) + j*4
# $t9 = temp for Swap

# t8 - tester val


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
#}

#Keep $v0, $a0 clear for printing


#init addr, arr.len and its dependents, i, and j

# Setting i and j
addi $s0, $0, 0	# set i = 0;
addi $s1, $0, 0 # set j = 0;

# Setting the address of arr[0], Pseudoinstructions must be removed to add stalls
#la $s2, inputArr 	# load address of inputArr into MIPS(this is addr. of arr[0])

lui $at, 0x00001001	#load base address into MIPS
#stalls
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
ori $s2, $at, 0x00000028 #load in top index of array for length calculation

# Calculate arr.length
#	-This is dependent on the output array, which should match anyways

# Finding arr.length and its derivatives(arr.length - 1 and arr.length - 1 - i)

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

sub $s3, $s2, $at # get arr.len(10 * 4(size of a word)
#arr.length

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

sra $s3, $s3, 2 # this is arr.length(=10) after accounting for the size of words

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

#arr.length-1

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

addi $s4, $s3, -1 # this is arr.length -1

addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall
addi		$0,  $0,  0			# Place stall

#arr.length-1-i(This is used in the conditional for the inner for loop)
sub $s5, $s4, $s0 # this is arr.length-1-i

#Outer For loop: Moving through the array
	
OuterForLoop:
	addi		$0,  $0,  0			# Place stall

	# for(i=0;i<length -1;i++){Inner Loop}
	# so check bge i, length-1, BRANCH
	# if this is false we should branch to the end of the program
	#	 outline of bge:
	#	 slt $at, $s, $t
	#	 beq $at, $zero, C
	
	slt $at, $s0, $s4 #checks if i<length-1, if true then no branch
	
	addi		$0,  $0,  0			# Place stall
	addi		$0,  $0,  0			# Place stall
	addi		$0,  $0,  0			# Place stall
	addi		$0,  $0,  0			# Place stall
	
	beq $at, $zero, Exit #if this fails in testing $t8 will = 1: WORKS

	addi		$0,  $0,  0			# Place stall

	addi $s1, $0, 0 # Set j=0 to prep for the Inner For Loop
	
	#Inner For loop: To Swap Or Not To Swap?
	
	InnerForLoop:
		addi		$0,  $0,  0			# Place stall
		# for(j=0; j < length-1-i;j++){CheckForSwap, Swap if Necessary}
		# so check bge j, length-1-i, BRANCH
		# if this is false we should branch to the exit of the inner loop to prep to go back to the outer loop
		#	 outline of bge:
		#	 slt $at, $s, $t
		# 	beq $at, $zero, C
		
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		
		slt $at, $s1, $s5 # checks if j<length-1-i, if true then no branch
		
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		
		beq $at, $zero, ExitInnerLoop #if this fails in testing then $t8 will = 2: WORK
		
		addi		$0,  $0,  0			# Place stall
		
		# If statement for swap:

		# if arr[j] > arr[j+1] then swap
		# we need to load the values in first, use $t values:
		# $a0 = arr[j], offset 0 + $t3 is its address
		# $a1 = arr[j+1], offset 4 + $t3 is its address
		# how do we get the addr since $s2 starts at arr[0]?
		#	-> use address = (addr. of arr[0]) + j*4
		
		#Calculating Address for Loading in Array
		sll $t2, $s1, 2	#compute j*4
		add $t3, $0, $s2 #compute addr. of arr[0]
		
		#calculate current address:
		
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		
		add $t3, $t3, $t2 #this is the address of arr[j](addr. of arr[0] + j*4)
		
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		
		#loading in arr[j] and arr[j+1]:
		lw $t0, 0($t3)	#store arr[j] as $t0
		lw $t1, 4($t3)	#store arr[j+1] as $t1
				
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall

		#check if arr[j] > arr[j+1], this uses ble arr[j], arr[j+1], Swap
		slt $at, $t1, $t0 # check if arr[j+1] < arr[j], if true no branch
		
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		addi		$0,  $0,  0			# Place stall
		
		beq $at, $zero, Update #if this fails then $t8 will = 3: WORKS
		addi		$0,  $0,  0			# Place stall
		
		#Swap: Swaps the elements $t0 and $t1 using a temp $
		Swap:
			addi		$0,  $0,  0			# Place stall
			add $t9, $0, $t0				# int temp = &arr[j];
			add $t0, $0, $t1				# &arr[j] = &arr[j+1];
			
			addi		$0,  $0,  0			# Place stall
			addi		$0,  $0,  0			# Place stall
			addi		$0,  $0,  0			# Place stall
			
			add $t1, $0, $t9				# &arr[j+1] = temp;
		
		#Update: Prepare values to jump back into InnerForLoop, Store Words Here
		Update:
			addi		$0,  $0,  0			# Place stall
			#Store back into Memory
			sw $t0, 0($t3) #Store arr[j] in Memory
			
			addi		$0,  $0,  0			# Place stall
			addi		$0,  $0,  0			# Place stall
			addi		$0,  $0,  0			# Place stall
			addi		$0,  $0,  0			# Place stall
			
			sw $t1, 4($t3) #Store arr[j+1] in Memory
			#Prep to make the Jump
			addi $s1, $s1, 1 # j++
			j InnerForLoop #Jump back into InnerLoop
			
			addi $0, $0, 0 #Add Stall

	#ExitInnerLoop: Preps to jump back into OuterForLoop
	ExitInnerLoop:
	addi		$0,  $0,  0			# Place stall

	addi $s0, $s0, 1 # i++;
	j OuterForLoop #Jump back into Outer Loop
	
	addi		$0,  $0,  0			# Place stall
	
#Exit: Ends the BubbleSort
Exit:
	addi		$0,  $0,  0			# Place stall
	li $v0, 10
   	addi		$0,  $0,  0			# Place stall
	addi		$0,  $0,  0			# Place stall
	addi		$0,  $0,  0			# Place stall
	addi		$0,  $0,  0			# Place stall
	syscall