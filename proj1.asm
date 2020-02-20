# Bryan Navas
# bnavas
# 112244631

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
royal_flush_str: .asciiz "ROYAL_FLUSH\n"
straight_flush_str: .asciiz "STRAIGHT_FLUSH\n"
four_of_a_kind_str: .asciiz "FOUR_OF_A_KIND\n"
full_house_str: .asciiz "FULL_HOUSE\n"
simple_flush_str: .asciiz "SIMPLE_FLUSH\n"
simple_straight_str: .asciiz "SIMPLE_STRAIGHT\n"
high_card_str: .asciiz "HIGH_CARD\n"

zero_str: .asciiz "ZERO\n"
neg_infinity_str: .asciiz "-INF\n"
pos_infinity_str: .asciiz "+INF\n"
NaN_str: .asciiz "NAN\n"
floating_point_str: .asciiz "_2*2^"

# Put your additional .data declarations here, if any.


# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here

    #Checks to see if it is length 1
    lw $s0, addr_arg0 #Puts the first argument into $s0
    lbu $t0, 1($s0)   #We expect only one character so we load the character AFTER the first one (should be 0)
    bnez $t0,invalidArg1    #We check that the character is null or '0', if not then INVALID
    
    lbu $t0, 0($s0)  #We checked to see if a SECOND characted, now we set $t0 to the FIRST characted
   
first_argument_length1:
    #$t0 hold ONE character and now we must check if it is F, M or P
    
    li $t1, 'F'   #temporary used to check if chars are equal
    beq $t0, $t1, first_argument_completely_valid
    
    #if $t0 is not equal to 'F' we continue to check if it's equal to 'M'
    li $t1, 'M'   #temporary used to check if chars are equal
    beq $t0, $t1, first_argument_completely_valid
    
    #if $t0 is not equal to 'F' OR 'M' we continue to check if it's equal to 'P'
    li $t1, 'P'   #temporary used to check if chars are equal
    beq $t0, $t1, first_argument_completely_valid
    
    #if at this point $t0 is not equal to 'F', 'M' or 'P' we print InvalidArg
    j invalidArg1
    
    
    
first_argument_completely_valid:  
#$t0 holds ONE character that is either F, M or P   
    
    #next we check to see if there are 2 arguments
    lw $t1, num_args   #stores the number of arguments in command line
    li $t2, 2  #temporary variable used to check if there are 2 arguments
    bne $t1, $t2, invalidNumArgs  #if $t1 (the number of args) is not equal to 2, we print error msg and exit
   
    li $t1, 'F'   #temporary used to check if chars are equal
    beq $t0, $t1, F_argument
    
    #if $t0 is not equal to 'F' we continue to check if it's equal to 'M'
    li $t1, 'M'   #temporary used to check if chars are equal
    beq $t0, $t1, M_argument
    
    #if $t0 is not equal to 'F' OR 'M' we continue to check if it's equal to 'P'
    li $t1, 'P'   #temporary used to check if chars are equal
    beq $t0, $t1, P_argument
     
    M_argument: 
    #if instruction is 'M'    
    #looping 8 times to map arg1 into 32bit value
    #at this point everything is correct and we assume there is an 8 ascii character instruction
    
    li $t1, 0  #counter to see how many times the loop has run (will run until it == 8)
    li $t2, 8  #max times the loop will run
    li $t3, 28 #initial shift amount. Will decrease by 4 every time the loop is run
    li $t4, 0  #temporarily holds the ascii character each iteration of loop
    li $t5, 65 #used to check if ASCII is greater than or equal to 65 meaning it's (A-F)
    li $s1, 0  #Contains the 32bit value that represents a 32-bit MIPS machine instruction
    
    lw $s0, addr_arg1   #loads arg1 into $s0
    
    mappingArgLoop:
    beq $t1, $t2, endMappingLoop  #once the loop has run 8 times it will end
    lbu $t4, 0($s0)	#grabs a letter or a number from the instruction
    
    #Next we check to see if it's a number (0-9) or a letter (A-F)
    #Letters have a greater ascii code than numbers
    bge $t4, $t5, currentASCII_IsLetter #if it's a letter jump to a certain part of code

    		currentASCII_IsNum:
    		#runs if character is a number 0-9
    		andi $t4, $t4, 0x0F   #converts the ascii number to actual number by masking and grabbing last 4 bits
    		sllv $t4, $t4, $t3    # $t4 = $t4 <<< shift amt $t3, in other words this shifts into proper 32bit instruction order
    		add $s1, $s1, $t4     #adds the shifted amount into $s1 which holds the correct 32bit instruction
    		
    		addi $t3, $t3, -4     #subtracts 4 because every character is 4 bits
    		addi $t1, $t1, 1      #increases loop counter by 1
    		addi $s0, $s0, 1      #increased the memory address by 1 so we can access the next bit
    		
    		j mappingArgLoop      #jumps back to beginning of loop     
  			
    		currentASCII_IsLetter:
    		#runs if current character is a letter A-F
		addi $t4, $t4, 0001   #takes current letter and adds 1 to it			   	
    		addi $t4, $t4, 1000   #takes it and adds a 1 to the 4th spot
    		andi $t4, $t4, 0x0F   #after doing the last 2 operations, the last byte will have an actual number
    		sllv $t4, $t4, $t3    # $t4 = $t4 <<< shift amt $t3, in other words this shifts into proper 32bit instruction order
    		add $s1, $s1, $t4     #adds the shifted amount into $s1 which holds the correct 32bit instruction
    		
    		addi $t3, $t3, -4     #subtracts 4 because every character is 4 bits
    		addi $t1, $t1, 1      #increases loop counter by 1
    		addi $s0, $s0, 1      #increased the memory address by 1 so we can access the next bit
    		
    		j mappingArgLoop      #jumps back to beginning of loop		
    endMappingLoop:
    
   
    #at this point of the code, $s1 holds the 32bit MIPS instruction
    #now we have to reorganize the values into the six fields of an R-type instruction 
    
    #first we organize the opcode which will be stored in $t0 and printed
    andi $t0, $s1, 0xFC000000    #AND operation will only take the first 6 bits, this hex format simply means that in a 32 bit register, there are 6 1's and 26 0's
    srl $t0, $t0, 26      	 #Since the opcode will be on the first 6 bits of the 32, we need to shift it to the right by 26
    bnez $t0, invalidNumArgs     #this label is just the name that prints out the correct error, label name is not importnant
    
    li $v0, 1       #prints the opcode onto the screen
    move $a0, $t0
    syscall
    li $v0, 11      #prints a space after the opcode onto the screen
    li $a0, ' '
    syscall
    
    #the rs_field is the next 5 bits after that which will be stored in $t0 and printed
    andi $t0, $s1, 0x3E00000     #AND operation will ignore the first 6 bits, take the next 5 bits and ignore the rest of the 21 bits
    sll $t0, $t0, 6	 	 #this shift ensures that the first 6 digits are "lost" and turned to 0 when shifted in next step
    srl $t0, $t0, 27		 #shifts it so that the 5 rs_field digits are on the end
    
    li $v0, 1       #prints the rs_field onto the screen
    move $a0, $t0
    syscall   
    li $v0, 11      #prints a space after the rs_field onto the screen
    li $a0, ' '
    syscall
    
    #the rt_field is the next 5bits after that which will be stored in $t0 and printed
    andi $t0, $s1, 0x1F0000     #AND operation will ignore the first 11 bits, take the next 5bits, and ignore the rest of the 16 bits
    sll $t0, $t0, 11            #this ensures that the first 11 bits are "lost" and turned into 0 when shifted to the right
    srl $t0, $t0, 27            #shifts it so that the 5 rt_field digits are at the end
    
    li $v0, 1       #prints the rt_field onto the screen
    move $a0, $t0
    syscall   
    li $v0, 11      #prints a space after the rt_field onto the screen
    li $a0, ' '
    syscall
    
    #the rd_field is the next 5bits after that which will be stored in $t0 and printed
    andi $t0, $s1, 0xF800      #AND operation will ignore the first 16bits, take the next 5bits, and ignore the rest of the 11 bits
    sll $t0, $t0, 16	       #this ensures that the first 16 bits are "lost" and turned into 0 when shifted to the right in the next instruction
    srl $t0, $t0, 27	       #shifts it so that the 5 rd_field digits are at the end
    
    li $v0, 1       #prints the rd_field onto the screen
    move $a0, $t0
    syscall   
    li $v0, 11      #prints a space after the rd_field onto the screen
    li $a0, ' '
    syscall
    
    #the shamt is the next 5bits after that which will be stored in $t0 and printed
    andi $t0, $s1, 0x7C0       #AND operation will ignore the first 21 bits, take the next 5bits, and ignore the rest of the 6bits
    sll $t0, $t0, 21	       #this ensures that the first 21 bits are "lost" and turned into 0 when shifted to the right in the next instruction
    srl $t0, $t0, 27	       #shifts it so that the 5 shamt digits are at the end
    
    li $v0, 1       #prints the rd_field onto the screen
    move $a0, $t0
    syscall   
    li $v0, 11      #prints a space after the rd_field onto the screen
    li $a0, ' '
    syscall
    
    #the funct is the last 6bits which will be stored in $t0 and printed
    andi $t0, $s1, 0x3F      #AND operation will ignore the first 26 bits, and only grab the last 6
    sll $t0, $t0, 26   	     #this ensures that the first 26 bits are "lost" and turned into 0 when shifted to the right in the next instruction
    srl $t0, $t0, 26	     #shifts ensures that the last 6 funct digits are at the end
    
    li $v0, 1       #prints the funct onto the screen
    move $a0, $t0
    syscall   
    li $v0, 11      #prints a space after the funct onto the screen
    li $a0, '\n'
    syscall
    
    j exit   #ensures that it exits the program
    endM_argument:
    
    
    F_argument:
    #if user option is F
    #we assumen arg1 only has 4 digits
    #we have to check if they are proper hex
    
    #first we have to turn the user ASCII argument into binary
    li $t1, 0  #counter to see how many times the loop has run (will run until it == 4)
    li $t2, 4  #max times the loop will run
    li $t3, 12  #initial shift amount. Will decrease by 4 every time the loop is run
    li $t4, 0  #temporarily holds the ascii character each iteration of loop
    li $t5, 65 #used to check if ASCII is greater than or equal to 65 meaning it's (A-F)
    li $s1, 0  #Contains the 16bit value that represents a 16-bit Floating-point Number

    
    lw $s0, addr_arg1   #loads arg1 into $s0
    
    mappingArgLoop2:
    beq $t1, $t2, endMappingLoop2  #once the loop has run 4 times it will end
    lbu $t4, 0($s0)	#grabs a letter or a number from the instruction
    
    #next we check that the character we grabbed is within ASCII numbers 65-70(A-F) OR 48-57(0-9)
    li $t6, 70
    bgt $t4, $t6, invalidNumArgs    #if ASCII char is greater than 70 we print out invalid args
    li $t6, 48
    blt $t4, $t6, invalidNumArgs    #if ASCII char is less than 48
    li $t6, 65
    blt $t4, $t6 currentASCII_IsNum2   #If char # is less than 65 then it is presumably a number 0-9
    
    #Next we check to see if it's a number (0-9) or a letter (A-F)
    #Letters have a greater ascii code than numbers
    bge $t4, $t5, currentASCII_IsLetter2 #if it's a letter jump to a certain part of code

    		currentASCII_IsNum2:
    		#runs if character is a number 0-9
    		li $t6, 57
    		bgt $t4, $t6, invalidNumArgs  #if the number is between 58-64
    		andi $t4, $t4, 0x0F   #converts the ascii number to actual number by masking and grabbing last 4 bits
    		sllv $t4, $t4, $t3    # $t4 = $t4 <<< shift amt $t3, in other words this shifts into proper  16-bit Floating-point Number
    		add $s1, $s1, $t4     #adds the shifted amount into $s1 
    		
    		addi $t3, $t3, -4     #subtracts 4 because every character is 4 bits
    		addi $t1, $t1, 1      #increases loop counter by 1
    		addi $s0, $s0, 1      #increased the memory address by 1 so we can access the next bit
    		
    		j mappingArgLoop2      #jumps back to beginning of loop     
  			
    		currentASCII_IsLetter2:
    		#runs if current character is a letter A-F
		addi $t4, $t4, 0001   #takes current letter and adds 1 to it			   	
    		addi $t4, $t4, 1000   #takes it and adds a 1 to the 4th spot
    		andi $t4, $t4, 0x0F   #after doing the last 2 operations, the last byte will have an actual number
    		sllv $t4, $t4, $t3    # $t4 = $t4 <<< shift amt $t3, in other words this shifts into proper  16-bit Floating-point Number
    		add $s1, $s1, $t4     #adds the shifted amount into $s1
    		
    		addi $t3, $t3, -4     #subtracts 4 because every character is 4 bits
    		addi $t1, $t1, 1      #increases loop counter by 1
    		addi $s0, $s0, 1      #increased the memory address by 1 so we can access the next bit
    		
    		j mappingArgLoop2      #jumps back to beginning of loop		
    endMappingLoop2:
    
    #after loop, $s1 will hold binary representation of  16-bit Floating-point Number
    
    #dealing with sign bit stored in $t0
    andi $t0, $s1, 0x8000      #this ONLY grabs the sign bit
    sll $t0, $t0, 16           #ensures that the first 16 bits are lost and turned to 0 when shifted right
    srl $t0, $t0, 31	       #the sign bit if the left most bit now   
   
    #dealing with exponent stored in $t1
    andi $t1, $s1, 0x7C00     #this will ignore the first 17bits and take the next 5bits and ignore the rest of the 10bits
    sll $t1, $t1, 17	      #this shift ensures that the first 17bits are lost and turned to 0 when shifted back
    srl $t1, $t1, 27          #shifts so that the 5 exponent bits are on the far left
   
    #dealing with fraction stored at $t2
    andi $t2, $s1, 0x3FF     #this will ignore the first 22bits and only take the last 10 bits
    sll $t2, $t2, 22	    #this ensures that the first 22 bits are lost and turned to 0 when shifted back
    srl $t2, $t2, 22	    #shifts so that the last 10 fraction bits are on the far left
    
    
    	#handling special exponent cases:
    	beqz $t1, exponent_zero
    	li $t3, 31    #temporary used to check if exponent 11111
    	beq $t1, $t3, exponent_ones
    	
    	#if there are no special exponent cases we jump to handling normal cases
    	j normalCase
     	
     	exponent_ones:
     	#exponent is 11111 which means it's not a normal value
     	beqz $t0, pos_bit  #if sign bit is 0 and exponent is 11111
		neg_bit_case:    
		bnez $t2, print_NaN 	#if fraction is not equal to 0, then it's NaN
     		beqz $t2, print_negINF
     		
     		pos_bit:
     		bnez $t2, print_NaN 	#if fraction is not equal to 0, then it's NaN
     		beqz $t2, print_posINF
     	
     	  	
    	exponent_zero:
    	#exponent is 000000 and presumably fraction is 0000000000
    		 beqz $t2, printZero      #if the fraction is Zero, we print 0 onto the screen and exit
    		 
    		 
  
   
normalCase:  #number is not +/- INF, or NaN            
    #printing signbit
    addi $t1, $t1, -15	      #subtracts the bias of 15 to make it proper exponent
    beqz $t0, pos_signbit
     
    neg_signbit:
    li $v0, 11    #prints the negative sign before anything
    li $a0, '-'
    syscall
    
    li $v0, 11    #prints a '1' on the screen because it's positive
    li $a0, '1'
    syscall
    
    li $v0, 11    #prints a '.' on the screen because it's positive
    li $a0, '.'
    syscall
    
    j print_fraction
    
    
    
    pos_signbit:
    li $v0, 11    #prints a '1' on the screen because it's positive
    li $a0, '1'
    syscall
    
    li $v0, 11    #prints a '.' on the screen because it's positive
    li $a0, '.'
    syscall
    
    #at this point we have to print the fraction in decimal format
    
    
    print_fraction:
    #prints out 1st digit in fraction and prints it
    andi $t3, $s1, 0x200      #this only grabs the first digit in the fraction
    sll $t3, $t3, 22	      #we want to ensure that the first 22 bits are lost
    srl $t3, $t3, 31	      #this number is now in the left most bit  
    li $v0, 1
    move $a0, $t3
    syscall
    #prints out 2nd digit in fraction and prints it
    andi $t3, $s1, 0x100      #this only grabs the second digit in the fraction
    sll $t3, $t3, 23	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall
    #prints out 3rd digit in fraction and prints it
    andi $t3, $s1, 0x80      #this only grabs the third digit in the fraction
    sll $t3, $t3, 24	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall
    #prints out 4th digit in fraction and prints it
    andi $t3, $s1, 0x40      #this only grabs the fourth digit in the fraction
    sll $t3, $t3, 25	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall
    #prints out 5th digit in fraction and prints it
    andi $t3, $s1, 0x20     #this only grabs the fifth digit in the fraction
    sll $t3, $t3, 26	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall 
    #prints out 6th digit in fraction and prints it
    andi $t3, $s1, 0x10     #this only grabs the sixth digit in the fraction
    sll $t3, $t3, 27	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall
    #prints out 7th digit in fraction and prints it
    andi $t3, $s1, 0x8      #this only grabs the seventh digit in the fraction
    sll $t3, $t3, 28	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall
    #prints out 8th digit in fraction and prints it
    andi $t3, $s1, 0x4      #this only grabs the eigth digit in the fraction
    sll $t3, $t3, 29	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall
    #prints out 9th digit in fraction and prints it
    andi $t3, $s1, 0x2      #this only grabs the ninth digit in the fraction
    sll $t3, $t3, 30	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall 
    #prints out 10th digit in fraction and prints it
    andi $t3, $s1, 0x1      #this only grabs the tenth digit in the fraction
    sll $t3, $t3, 31	      #every "iteration" it loses one more bit so immediate must increase     
    srl $t3, $t3, 31	        
    li $v0, 1 
    move $a0, $t3
    syscall
    
    #at this point the fraction has been printed out
    li $v0, 4 
    la $a0, floating_point_str  #prints "_2*2^"
    syscall
    
    #print out exponent with bias already removed
    li $v0, 1
    move $a0, $t1
    syscall
    
    j exit   #ensures that it exits the program
    endF_argument:
    
    
    P_argument:  
    lw $s7, addr_arg1   #loads arg1 into $s7, contains a 10 character string
    
    
    #$s0 - $s4 will hold the card RANK
    #$t0 - $t4 will hold the card SUIT
    lbu $s0, 0($s7) #hold the first card's rank
    lbu $t0, 1($s7) #hold the first card's suit
    
    lbu $s1, 2($s7) #hold the second card's rank
    lbu $t1, 3($s7) #hold the second card's suit
    	
    lbu $s2, 4($s7) #hold the third card's rank
    lbu $t2, 5($s7) #hold the third card's suit
    
    lbu $s3, 6($s7) #hold the fourth card's rank
    lbu $t3, 7($s7) #hold the fourth card's suit
    
    lbu $s4, 8($s7) #hold the fifth card's rank
    lbu $t4, 9($s7) #hold the fifth card's suit
    
    #validating input
    
   
    
    #now we have to map all the ranks to actual numbers as listed below
    #we do this for better data manipulation later on
    #essentially mapping ASCII chars to decimals we can use
    # Ace -> 14, Ace card gets mapped to decimal #14
    # King -> 13
    # Queen -> 12
    # Jack -> 11
    # TEN -> 10
    
    # 9 -> 9
    # 8 -> 8
    # 7 -> 7
    # 6 -> 6
    # 5 -> 5
    # 4 -> 4
    # 3 -> 3
    # 2 -> 2
    # 1 -> 1
    
    #running under the assumption that chars are 0-9, T, J, Q, K, or A
    
    #first we convert $s0 which holds the rank of the FIRST card
    convert_rank1:
    	#now we check if this character is a number or a letter
    	li $t5, 65       #used as temporary to check if the character is greater than ASCII char 65 (meaning it's a letter)
    	blt $s0, $t5, rank1_isNum    #if the rank of card 1 is not a letter, jump to section of code that converts ASCII 0-9 to numbers  
    	rank1_isLetter:
    		rank1_checkAce:
    			li $t5, 'A'   #used as a temporary to check if char is A
    			bne $s0, $t5, rank1_checkKing
	    		li $s0, 14    #if the rank is Ace, we turn it to #14. If not, we skip this instruction and jump to the next
    			j end_convert_rank1
    		rank1_checkKing:
    			li $t5, 'K'   #used as a temporary to check if char is K
	    		bne $s0, $t5, rank1_checkQueen
    			li $s0, 13    #if the rank is King, we turn it to #13. If not, we skip this instruction and jump to the next
    			j end_convert_rank1
    		rank1_checkQueen:
	    		li $t5, 'Q'   #used as a temporary to check if char is Q
    			bne $s0, $t5, rank1_checkJack
    			li $s0, 12    #if the rank is Queen, we turn it to #12. If not, we skip this instruction and jump to the next
	    		j end_convert_rank1
    		rank1_checkJack:
	    		li $t5, 'J'   #used as a temporary to check if char is J
    			bne $s0, $t5, rank1_checkTen
    			li $s0, 11    #if the rank is Jack, we turn it to #11. If not, we skip this instruction and jump to the next
	    		j end_convert_rank1
    		rank1_checkTen:
    			li $s0, 10   #if it is neither Ace, King, Queen or Jack, it MUST be TEN
    		j end_convert_rank1  #ensures it doesnt run through the bottom section of code
    	rank1_isNum:
    	andi $s0, $s0, 0x0F   #converts the ascii number to actual number by masking and grabbing last 4 bits
    end_convert_rank1:
    
    #now we convert $s1 which holds the rank of the SECOND card
    convert_rank2:
    	#now we check if this character is a number or a letter
    	li $t5, 65       #used as temporary to check if the character is greater than ASCII char 65 (meaning it's a letter)
    	blt $s1, $t5, rank2_isNum    #if the rank of card 1 is not a letter, jump to section of code that converts ASCII 0-9 to numbers  
    	rank2_isLetter:
    		rank2_checkAce:
    			li $t5, 'A'   #used as a temporary to check if char is A
    			bne $s1, $t5, rank2_checkKing
	    		li $s1, 14    #if the rank is Ace, we turn it to #14. If not, we skip this instruction and jump to the next
    			j end_convert_rank2
    		rank2_checkKing:
    			li $t5, 'K'   #used as a temporary to check if char is K
	    		bne $s1, $t5, rank2_checkQueen
    			li $s1, 13    #if the rank is King, we turn it to #13. If not, we skip this instruction and jump to the next
    			j end_convert_rank2
    		rank2_checkQueen:
	    		li $t5, 'Q'   #used as a temporary to check if char is Q
    			bne $s1, $t5, rank2_checkJack
    			li $s1, 12    #if the rank is Queen, we turn it to #12. If not, we skip this instruction and jump to the next
	    		j end_convert_rank2
    		rank2_checkJack:
	    		li $t5, 'J'   #used as a temporary to check if char is J
    			bne $s1, $t5, rank2_checkTen
    			li $s1, 11    #if the rank is Jack, we turn it to #11. If not, we skip this instruction and jump to the next
	    		j end_convert_rank2
    		rank2_checkTen:
    			li $s1, 10   #if it is neither Ace, King, Queen or Jack, it MUST be TEN
    		j end_convert_rank2  #ensures it doesnt run through the bottom section of code
    	rank2_isNum:
    	andi $s1, $s1, 0x0F   #converts the ascii number to actual number by masking and grabbing last 4 bits
    end_convert_rank2:
    
    #then we convert $s2 which holds the rank of the THIRD card
    convert_rank3:
    	#now we check if this character is a number or a letter
    	li $t5, 65       #used as temporary to check if the character is greater than ASCII char 65 (meaning it's a letter)
    	blt $s2, $t5, rank3_isNum    #if the rank of card 1 is not a letter, jump to section of code that converts ASCII 0-9 to numbers  
    	rank3_isLetter:
    		rank3_checkAce:
    			li $t5, 'A'   #used as a temporary to check if char is A
    			bne $s2, $t5, rank3_checkKing
	    		li $s2, 14    #if the rank is Ace, we turn it to #14. If not, we skip this instruction and jump to the next
    			j end_convert_rank3
    		rank3_checkKing:
    			li $t5, 'K'   #used as a temporary to check if char is K
	    		bne $s2, $t5, rank3_checkQueen
    			li $s2, 13    #if the rank is King, we turn it to #13. If not, we skip this instruction and jump to the next
    			j end_convert_rank3
    		rank3_checkQueen:
	    		li $t5, 'Q'   #used as a temporary to check if char is Q
    			bne $s2, $t5, rank3_checkJack
    			li $s2, 12    #if the rank is Queen, we turn it to #12. If not, we skip this instruction and jump to the next
	    		j end_convert_rank3
    		rank3_checkJack:
	    		li $t5, 'J'   #used as a temporary to check if char is J
    			bne $s2, $t5, rank3_checkTen
    			li $s2, 11    #if the rank is Jack, we turn it to #11. If not, we skip this instruction and jump to the next
	    		j end_convert_rank3
    		rank3_checkTen:
    			li $s2, 10   #if it is neither Ace, King, Queen or Jack, it MUST be TEN
    		j end_convert_rank3  #ensures it doesnt run through the bottom section of code
    	rank3_isNum:
    	andi $s2, $s2, 0x0F   #converts the ascii number to actual number by masking and grabbing last 4 bits
    end_convert_rank3:
    
    #next we convert $s3 which holds the rank of the FOURTH card
    convert_rank4:
    	#now we check if this character is a number or a letter
    	li $t5, 65       #used as temporary to check if the character is greater than ASCII char 65 (meaning it's a letter)
    	blt $s3, $t5, rank4_isNum    #if the rank of card 1 is not a letter, jump to section of code that converts ASCII 0-9 to numbers  
    	rank4_isLetter:
    		rank4_checkAce:
    			li $t5, 'A'   #used as a temporary to check if char is A
    			bne $s3, $t5, rank4_checkKing
	    		li $s3, 14    #if the rank is Ace, we turn it to #14. If not, we skip this instruction and jump to the next
    			j end_convert_rank4
    		rank4_checkKing:
    			li $t5, 'K'   #used as a temporary to check if char is K
	    		bne $s3, $t5, rank4_checkQueen
    			li $s3, 13    #if the rank is King, we turn it to #13. If not, we skip this instruction and jump to the next
    			j end_convert_rank4
    		rank4_checkQueen:
	    		li $t5, 'Q'   #used as a temporary to check if char is Q
    			bne $s3, $t5, rank4_checkJack
    			li $s3, 12    #if the rank is Queen, we turn it to #12. If not, we skip this instruction and jump to the next
	    		j end_convert_rank4
    		rank4_checkJack:
	    		li $t5, 'J'   #used as a temporary to check if char is J
    			bne $s3, $t5, rank4_checkTen
    			li $s3, 11    #if the rank is Jack, we turn it to #11. If not, we skip this instruction and jump to the next
	    		j end_convert_rank4
    		rank4_checkTen:
    			li $s3, 10   #if it is neither Ace, King, Queen or Jack, it MUST be TEN
    		j end_convert_rank4  #ensures it doesnt run through the bottom section of code
    	rank4_isNum:
    	andi $s3, $s3, 0x0F   #converts the ascii number to actual number by masking and grabbing last 4 bits
    end_convert_rank4:
   
    #lastly we convert $s4 which holds the rank of the FIFTH card
    convert_rank5:
    	#now we check if this character is a number or a letter
    	li $t5, 65       #used as temporary to check if the character is greater than ASCII char 65 (meaning it's a letter)
    	blt $s4, $t5, rank5_isNum    #if the rank of card 1 is not a letter, jump to section of code that converts ASCII 0-9 to numbers  
    	rank5_isLetter:
    		rank5_checkAce:
    			li $t5, 'A'   #used as a temporary to check if char is A
    			bne $s4, $t5, rank5_checkKing
	    		li $s4, 14    #if the rank is Ace, we turn it to #14. If not, we skip this instruction and jump to the next
    			j end_convert_rank5
    		rank5_checkKing:
    			li $t5, 'K'   #used as a temporary to check if char is K
	    		bne $s4, $t5, rank5_checkQueen
    			li $s4, 13    #if the rank is King, we turn it to #13. If not, we skip this instruction and jump to the next
    			j end_convert_rank5
    		rank5_checkQueen:
	    		li $t5, 'Q'   #used as a temporary to check if char is Q
    			bne $s4, $t5, rank5_checkJack
    			li $s4, 12    #if the rank is Queen, we turn it to #12. If not, we skip this instruction and jump to the next
	    		j end_convert_rank5
    		rank5_checkJack:
	    		li $t5, 'J'   #used as a temporary to check if char is J
    			bne $s4, $t5, rank5_checkTen
    			li $s4, 11    #if the rank is Jack, we turn it to #11. If not, we skip this instruction and jump to the next
	    		j end_convert_rank5
    		rank5_checkTen:
    			li $s4, 10   #if it is neither Ace, King, Queen or Jack, it MUST be TEN
    		j end_convert_rank5  #ensures it doesnt run through the bottom section of code
    	rank5_isNum:
    	andi $s4, $s4, 0x0F   #converts the ascii number to actual number by masking and grabbing last 4 bits
    end_convert_rank5:	 
    
    #at this point of the code we have all the ranks corresponding to a decimal number
    #ranks 0-9 are decimal numbers 0-9
    #ranks 10, Jack, Queen, King, Ace are decimal numbers 10, 11, 12, 13, and 14, respectively
    
    #remember that card 1 is held within 2 registers, $s0 (holds rank) and $t0 (holds suit)
    #the rest of the cards are stored in the same fashion
    
    
    #we must now order them from HIGHEST to LOWEST
    li $t5, 5     #max times loop will run
    li $t6, 0     #counter for loop
    orderCards_loop:
    	beq $t5, $t6, orderCards_endLoop      #once loop has run max # of times, we end loop
    	
    	bgt $s1, $s0, switchCards_1and2       #if card 2 has a higher rank than card 1, we switch them
    	j end_switchCards_1and2	      #if card 2 is NOT highter than card 1, we dont switch them and skip over code	
    		switchCards_1and2:
    			       #switches the rank of card 1 and 2
    				move $t7, $s0     # temp = rank of card 1
    				move $s0, $s1	  # rank of card 1 = rank of card 2
    				move $s1, $t7	  # rank of card 2 = temp			
    			       #switches the suits of card 1 and 2
    				move $t7, $t0     # temp = suit of card 1
    				move $t0, $t1     # suit of card 1 = suit of card 2
    				move $t1, $t7	  # suit of card 2 = temp		
    		end_switchCards_1and2:
    	
    	bgt $s2, $s1, switchCards_2and3     #if card 3 has a higher rank than card 2, we switch them
    	j end_switchCards_2and3       #if card 3 is NOT higher, we dont switch them and skip code
    		switchCards_2and3: 
    			       #switches the rank of card 2 and 3
    				move $t7, $s1
    				move $s1, $s2
    				move $s2, $t7
    			       #switches the suits of card 2 and 3
    			        move $t7, $t1
    			        move $t1, $t2
    			        move $t2, $t7	  	
    		end_switchCards_2and3:
    	
    	bgt $s3, $s2, switchCards_3and4    #if card 4 has a higher rank than card 3, we switch them
    	j end_switchCards_3and4	      #if card 4 does NOT have a higher rank, we dont switch and skip the code
    		switchCards_3and4:
    			       #switches the rank of card 3 and 4
    			        move $t7, $s2
    			        move $s2, $s3
    			        move $s3, $t7
    			       #switches the suits of card 3 and 4
    			        move $t7, $t2
    			        move $t2, $t3
    			        move $t3, $t7
    		end_switchCards_3and4:
    	
    	bgt $s4, $s3, switchCards_4and5
    	j end_switchCards_4and5
    		switchCards_4and5:
    		               #switches the rank of card 4 and 5
    		                move $t7, $s3
    			        move $s3, $s4
    			        move $s4, $t7
    			       #switches the suit of card 4 and 5
    			        move $t7, $t3
    			        move $t3, $t4
    			        move $t4, $t7
    		end_switchCards_4and5:
    			        	
    	addi $t6, $t6, 1   #adds 1 to the counter
    	j orderCards_loop  #jumps back to beginning of loop
    orderCards_endLoop:
    
    #now all our cards are in proper order, we now attempt to identify the hand
    
    checkRoyalFlush:
    	move $t6, $t0    #if royal flush, all suits must be the same as $t0 ($t0 holds the suit of first card)
    	
    	li $t5, 14       #recall that 14 represents Ace, so we check if the first rank is Ace
    	bne $t0, $t6, checkFOAK  #if the suits are not equal it cant be royal flush OR straight flush
    	bne $s0, $t5, checkStraightFlush   #if not ace, it cannot be royal flush, so we check for next highest hand
    		
    	li $t5, 13
    	bne $t1, $t6, checkFOAK
    	bne $s1, $t5, checkStraightFlush   #if the second card is not a king it cant be a royal flush and so on...    	
    	
    	li $t5, 12
    	bne $t2, $t6, checkFOAK
    	bne $s2, $t5, checkStraightFlush   	
    	
    	li $t5, 11
    	bne $t3, $t6, checkFOAK
    	bne $s3, $t5, checkStraightFlush
    	
    	li $t5, 10
    	bne $t4, $t6, checkFOAK
    	bne $s4, $t5, checkStraightFlush
    	    	
    	li $v0, 4
    	la $a0, royal_flush_str
    	syscall
    	j exit    	
    checkStraightFlush:
    	#CHECK IF THEY ARE SAME SUIT
    	move $t6, $t0    #if royal flush, all suits must be the same as $t0 ($t0 holds the suit of first card)
    	
    	#we then check to see if they are in sequential order ie. 7-6-5-4-3 but first checking if they are same suit
    	bne $t0, $t6, checkFOAK  #checks to see if they are the same suit, if NOT then it CANT be straight flush
    	move $t5, $s1  
    	addi $t5, $t5 1   #$t5 now holds the next card's rank plus 1
    	bne $s0, $t5, checkFOAK   #if the next card +1 is not the current card it cant be a straight flush
    	
    	bne $t1, $t6, checkFOAK
    	move $t5, $s2  
    	addi $t5, $t5 1   #$t5 now holds the next card's rank plus 1
    	bne $s1, $t5, checkFOAK   #if the next card +1 is not the current card it cant be a straight flush
    	
    	bne $t2, $t6, checkFOAK
    	move $t5, $s3  
    	addi $t5, $t5 1   #$t5 now holds the next card's rank plus 1
    	bne $s2, $t5, checkFOAK   #if the next card +1 is not the current card it cant be a straight flush
    	
    	bne $t3, $t6, checkFOAK
    	move $t5, $s4  
    	addi $t5, $t5 1   #$t5 now holds the next card's rank plus 1
    	bne $s3, $t5, checkFOAK   #if the next card +1 is not the current card it cant be a straight flush
    	
    	bne $t4, $t6, checkFOAK
    	
    	li $v0, 4
    	la $a0, straight_flush_str
    	syscall
    	j exit 
    	
    checkFOAK:
    	#2 cases ignoring suits, 4-3-3-3-3 OR 5-5-5-5-3
    	#repeating low means the 4 repeats are at the end(9-2-2-2-2)
    	#repeating high means the 4 repeats are at the beginning (9-9-9-9-2)
    	
    	bne $s0, $s1, lowFOAK     #if the first card is not equal to the second, we check if the repeating cards are on the end
	#at this point, we know the first 2 numbers have the same rank
      	bne $s1, $s2, checkFH   #if the second and third card dont have the same rank we check for Full House
      	bne $s2, $s3, checkFH
    	
    	li $v0, 4
    	la $a0, four_of_a_kind_str
    	syscall
    	j exit
    	
	lowFOAK:
	bne $s1, $s2, checkFH    #if it's something like 9-2-2-2-2 we only need to check that the last 4 are equal
	bne $s2, $s3, checkFH
	bne $s3, $s4, checkFH
	
	li $v0, 4
    	la $a0, four_of_a_kind_str
    	syscall
    	j exit	
    	
    checkFH:
       #2 cases 9-9-9-1-1 OR 9-9-1-1-1
       bne $s0, $s1, checkFlush     #in either case, the first 2 ranks have to be equal
        
       high3:
       #checks if the first 3 ranks which have a relatively high number are equal. Ex: 9-9-9-1-1
       	bne $s1, $s2, low3   #if the second and third rank arent equal, we check if the 3 of a kind is at the end
       	bne $s3, $s4, checkFlush #if the first 3 ranks are equal, but the last 2 arent, we check if it's a flush
       	
       	li $v0, 4
    	la $a0, full_house_str
    	syscall
    	j exit
       	
       low3: #checks if the last 3 cards are equal 
       	bne $s2, $s3, checkFlush
       	bne $s3, $s4, checkFlush
       	
       	li $v0, 4
    	la $a0, full_house_str
    	syscall
    	j exit	
       	
    checkFlush:  #if it's flush they all have the same suit
    	move $t5, $t0 	    #$t5 holds the suit they should all have for it to be a flush
    	
    	bne $t0, $t5, checkStraight   #we check to make sure that they all have the same rank
    	bne $t1, $t5, checkStraight
    	bne $t2, $t5, checkStraight
    	bne $t3, $t5, checkStraight
    	bne $t4, $t5, checkStraight
    	
    	li $v0, 4
    	la $a0, simple_flush_str
    	syscall
    	j exit
    	
    checkStraight:
    	#we check if they are all in sequential order
    	
    	move $t5, $s1		#we are putting the next card into $t5 and adding 1 which should be the current card
    	addi $t5, $t5, 1
    	bne $s0, $t5, highCard
    	
    	move $t5, $s2		
    	addi $t5, $t5, 1
    	bne $s1, $t5, highCard
    	
    	move $t5, $s3		
    	addi $t5, $t5, 1
    	bne $s2, $t5, highCard
    	
    	move $t5, $s4		
    	addi $t5, $t5, 1
    	bne $s3, $t5, highCard
    	
    	li $v0, 4
    	la $a0, simple_straight_str
    	syscall
    	j exit
    	
    highCard:  #if none of the previous hands get detected this prints out
    	li $v0, 4
    	la $a0, high_card_str
    	syscall  
    
    j exit    #ensures that it exits the program
    endP_argument:

exit:
    li $v0, 10   # terminate program
    syscall
    
#runs if the first arg is INVALID (has more than 1 character or NOT F, M or P)
invalidArg1:
    li $v0, 4
    la $a0, invalid_operation_error	#print the invalid operation message and exits the program
    syscall
    j exit 
    
#runs if the total number of arguments is NOT 2
printInvalidArgs:
	li $v0, 4
    la $a0, invalid_args_error	#print the invalid operation message and exits the program
    syscall
    j exit

invalidNumArgs:
    li $v0, 4
    la $a0, invalid_args_error	#print the invalid operation message and exits the program
    syscall
    j exit
    
#prints ZERO onto the screen 
printZero: 
    li $v0, 4
    la $a0, zero_str	#print the ZERO message and exits the program
    syscall
    j exit   
    
print_negINF:    
    li $v0, 4
    la $a0, neg_infinity_str	#print the -INF message and exits the program
    syscall
    j exit 
    
print_posINF:    
    li $v0, 4
    la $a0, pos_infinity_str	#print the +INF message and exits the program
    syscall
    j exit   
    
print_NaN:
    li $v0, 4
    la $a0, NaN_str	#print the +INF message and exits the program
    syscall
    j exit