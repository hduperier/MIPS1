.data

A:				.space 80  	# create integer array with 20 elements ( A[20] )
size_prompt:		.asciiz 	"Enter array size [between 1 and 20]: "
array_prompt:		.asciiz 	"A["
sorted_array_prompt:	.asciiz 	"Sorted A["
close_bracket: 		.asciiz 	"] = "
search_prompt:		.asciiz	"Enter search value: "
not_found:			.asciiz	" not in sorted A"
newline: 			.asciiz 	"\n" 	

.text

main:	
	# ----------------------------------------------------------------------------------
	# Do not modify
	#
	# MIPS code that performs the C-code below:
	#
	# 	int A[20];
	#	int size = 0;
	#	int v = 0;
	#
	#	printf("Enter array size [between 1 and 20]: " );
	#	scanf( "%d", &size );
	#
	#	for (int i=0; i<size; i++ ) {
	#
	#		printf( "A[%d] = ", i );
	#		scanf( "%d", &A[i]  );
	#
	#	}
	#
	#	printf( "Enter search value: " );
	#	scanf( "%d", &v  );
	#
	# ----------------------------------------------------------------------------------
	la $s0, A			# store address of array A in $s0
  
	add $s1, $0, $0			# create variable "size" ($s1) and set to 0
	add $s2, $0, $0			# create search variable "v" ($s2) and set to 0
	add $t0, $0, $0			# create variable "i" ($t0) and set to 0

	addi $v0, $0, 4  		# system call (4) to print string
	la $a0, size_prompt 		# put string memory address in register $a0
	syscall           		# print string
  
	addi $v0, $0, 5			# system call (5) to get integer from user and store in register $v0
	syscall				# get user input for variable "size"
	add $s1, $0, $v0		# copy to register $s1, b/c we'll reuse $v0
  
prompt_loop:
	# ----------------------------------------------------------------------------------
	slt $t1, $t0, $s1		# if( i < size ) $t1 = 1 (true), else $t1 = 0 (false)
	beq $t1, $0, end_prompt_loop	 
	sll $t2, $t0, 2			# multiply i * 4 (4-byte word offset)
				
  	addi $v0, $0, 4  		# print "A["
  	la $a0, array_prompt 			
  	syscall  
  	         			
  	addi $v0, $0, 1			# print	value of i (in base-10)
  	add $a0, $0, $t0			
  	syscall	
  					
  	addi $v0, $0, 4  		# print "] = "
  	la $a0, close_bracket		
  	syscall					
  	
  	addi $v0, $0, 5			# get input from user and store in $v0
  	syscall 			
	
	add $t3, $s0, $t2		# A[i] = address of A + ( i * 4 )
	sw $v0, 0($t3)			# A[i] = $v0 
	addi $t0, $t0, 1		# i = i + 1
		
	j prompt_loop			# jump to beginning of loop
	# ----------------------------------------------------------------------------------	
end_prompt_loop:

	addi $v0, $0, 4  		# print "Enter search value: "
  	la $a0, search_prompt 			
  	syscall 
  	
  	addi $v0, $0, 5			# system call (5) to get integer from user and store in register $v0
	syscall				# get user input for variable "v"
	add $s2, $0, $v0		# copy to register $s2, b/c we'll reuse $v0


LOOP1:
	addi $s3, $s1, -1		#size-1
	slt $t2, $t1, $s3 		#i<size-1
	beq $t2, $zero, LOOP_for_search
	addi $t1, $t1, 1 		#counter
	addi $t3, $zero, 0 		#j set to 0
	j LOOP2

LOOP2:
	addi $t5, $t1, -1
	sub $t5, $s3, $t5
	slt $t6, $t3, $t5
	beq $t6, $zero, LOOP1
	addi $t7, $s0, 0
	addi $t8, $t3, 0
	sll $t8, $t8, 2
	add $t7, $t7, $t8
	
	lw $s4, 0($t7)
	
	addi $t8, $s0, 0
	addi $t9, $t3, 1
	sll $t9, $t9, 2
	add $t8, $t8, $t9
	
	lw $s5, 0($t8)
	
	slt $t4, $s5, $s4
	bne $t4, $zero, SORTER
	
	addi $t3, $t3, 1
	j LOOP2
	
SORTER:
	addi $t0, $s5, 0
	sw $t0, 0($t7)
	addi $t0, $s4, 0
	sw $t0, 0($t8)
	addi $t3, $t3, 1
	j LOOP2

LOOP_for_search:
	addi $t0, $zero, 0 	#left
	addi $t1, $s1, -1	#right
	addi $t3, $zero, 0	#middle
	addi $t4, $zero, -1	#element_ndex
	j WHILE_LOOP
	
WHILE_LOOP:
	addi $t5, $t1, 1
	slt $t6, $t0, $t5
	beq $t6, $0, end
	sub $t3, $t1, $t0
	sra $t3, $t3, 1
	add $t3, $t3, $t0
	addi $t7, $s0, 0
	addi $t8, $t3, 0
	sll $t8, $t8, 2
	add $t7, $t7, $t8
	lw $t9, 0($t7)
	beq $t9, $s2, LOOP3
	slt $t6, $t9, $s2
	beq $t6, $0, else
	bne $t6, $0, if
	
LOOP3:
	add $t4, $0, $t3
	addi $v0, $0, 4
	la $a0, sorted_array_prompt
	syscall
	li $v0, 1
	add $a0, $0, $t4
	syscall
	addi $v0, $0, 4
	la $a0, close_bracket
	syscall
	li $v0, 1
	add $a0, $0, $s2
	syscall
	addi $v0, $0, 4
	la $a0, newline
	syscall
	j exit

if:
	add $t0, $t3, 1
	j WHILE_LOOP
	
else:
	add $t1, $t3, -1
	j WHILE_LOOP

end:
	li $v0, 1
	add $a0, $0, $s2
	syscall
	addi $v0, $0, 4
	la $a0, not_found
	syscall
	addi $v0, $0, 4
	la $a0, newline
	syscall
	j exit
  	
# ----------------------------------------------------------------------------------
# Do not modify the exit
# ----------------------------------------------------------------------------------
exit:                     
  addi $v0, $0, 10      		# system call (10) exits the progra
  syscall               		# exit the program
