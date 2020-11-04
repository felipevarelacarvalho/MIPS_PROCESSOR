# BubbleSort in MIPS

# Trevor Rowland, Muhamad Stilic, Felipe Carvalho
# CPR E 381 Project Part B

BUBBLESORT:

    # getting the address(need to add lab1 above as "lab1: .byte 0xa1" in the .data section)
	lui 			$s0, %hi(lab1)
    ori 			$s0, %lo(lab1)
    lw  			$s2, 0($s1)					# $s2 is the address
	
    addi 			$t9, $0, 1					# boolean for swap = true(if 0 then swap = false)
    addi 			$t7, $0, 0					# i = 0
    addi 			$t8, $0, 0					# j = 0
	
	#getting arrLen
	addi			$sp,$sp,-8
    sw				$ra,0($sp)
    sw				$a0,4($sp)
    li				$t2,0						# $t2 is arr.length

LOOP:
    beq  			$t9, $0, EXIT				# branch to exit if swap is false
    addi 			$t9, $0, 0					# set swap equal to false
    addi 			$t7, $t7, 1					# i++;
    sub     		$t8, $t8, $t8				# set j = 0;
    sub  			$t4, $t2, $t7				# set $6 = arrLEN - i;
    
    FORLOOP:
        # make bge for if j>=arr.length then branch to EXITFORLOOP
		slt 		$t3, $t8, $t2				# check if j > arr.length
		beq 		$t3, $0, EXITFORLOOP		# check if result of $t > $s is true, if true exit for loop
		
        lw 			$a0, 0($s2)					# $a0 = arr[j];
        lw 			$a1, 4($s2)					# $a1 = arr[j+1];
		
        # make ble for if arr[j] <= arr[j+1] then skip SWAP if true
        slt $t3, $t2, $t8
		beq $t3, $0, UPDATE
		
        SWAP:
            sw		$a1, 0($s2)					# arr[j+1] = arr[j]
            sw 		$a0, 4($s2)					# arr[j] = arr[j+1]
            addi 	$t9, $0, 1					# set swap = true
				
        UPDATE:
        addi 		$t8, $t8, 1					# j++;
        sll  		$t3, $t8, 2					# $5 = j * 4;
        addi 		$s2, $s2, $t3				# point to next element in array
        j FORLOOP								#jump to next iteration of for loop
		
    EXITFORLOOP:
        j LOOP
        
EXIT:
    jr $ra