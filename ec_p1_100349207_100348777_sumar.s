.data

.align 2
#MEMO--------------------------------------------------------------------------#
# + INFINITY  = 0x7F800000
# - INFINITY  = 0xFF800000
# NaN = 0x7FBFFFFF
#-------------------------------------------------------------------------------#
#TEXT---------------------------------------------------------------------------#
errorDim1Message: .asciiz "The dimension value must be integer value greater than 0\n"
errorDim2Message: .asciiz  "Dimension of matrix introduced doesnt match with the declared size needed of bytes to store the elements of matrices"
noErrors: .asciiz "No errors found to do matrix A and B processing\n"
tabAndBreak: .asciiz  "|-----|"
newLine: .asciiz "\n"
miMensaje: .asciiz "\nPROGRAM WORKED!"
matrixATitle: .asciiz  "Matrix A:|-----|"
matrixBTitle: .asciiz  "Matrix B:|-----|"
matrixCTitle: .asciiz  "Matrix C:|-----|"
matrixDTitle: .asciiz  "Matrix D:|-----|"

#-------------------------------------------------------------------------------#
dimension:.word 3 #this parameter has to be changed every time we put a different dimensioned matrix

size: .word 36 #Bytes needed to store last element of square matrices(THIS NEEDS TO BE CHANGED EVERYTIME WE DEFINE A NEW DIMENSION/MATRIX)

matrixA:
.word 0x7F800000
.float 0.0
.word 0x7F800000
.float 2.1, 2.4, 1.3
.float 3.4, 6.7, 0.0

matrixB:
.float 2.3
.word 0x7FBFFFFF
.word 0x7FBFFFFF
.float 1.3, 2.4, 1.3
.float 3.4, 6.7, 0.0

matrixC: .space 36

matrixD: .space 36

plusInfinity: .word 0x7F800000 
minusInfinity: .word 0xFF800000 
nan: .word 0x7FBFFFFF

.text

main:
#We check if dimension is valid(integer greater than 0)
lw $t7, dimension
blez $t7, errorDim1
#WE CHECK IF PROCESSING IS OK.(using sumarMin)
lw $a0, dimension
jal sumarMin
#PRINT TITLE "MATRIX A:"
li $v0, 4
la $a0, matrixATitle
syscall
#PRINT MATRIX A
#Arguments
addi $t0, $zero, 0#AUX:counter set to 0
la $a0, matrixA	 #we give the address of the first element of our matrix to te argument $a0
lw $a1, dimension#We put in a register the value of dimension entered in the data
jal getNumByte #$v1=dimension
move $a2, $v1
jal printMatrix  

#newLine
li $v0 4
la $a0 newLine
syscall

#PRINT TITLE "MATRIX B:"
li $v0, 4
la $a0, matrixBTitle
syscall
#PRINT MATRIX B
#Arguments
addi $t0, $zero, 0
la $a0, matrixB
lw $a1, dimension
jal getNumByte #$v1 = dimension
jal printMatrix

#newLine
li $v0 4
la $a0 newLine
syscall

#PRINT TITLE MATRIX C
li $v0, 4
la $a0, matrixCTitle
syscall
#We Build Matrix C and print it
#argument for getNumByte
lw $a1, dimension 
jal getNumByte
#Arguments for cConstruction
la $a1, matrixA
la $a2, matrixB
la $a3, matrixC
lw $s0, nan #loading NaN and Infinty in $s0 and $s1 to be able to pass them to stack
lw $s1, plusInfinity
addi $sp, $sp, -4
sw $v1, ($sp) #set limit for loop that goes through elements of matrices(BYTES) (saving value returned by getNumByte in stack)
addi $sp, $sp, -4
sw $s0, ($sp) #saving NaN in stack
addi $sp, $sp, -4
sw $s1, ($sp) #saving infinty in stack
jal cConstruction

#MATRIX D PROCESSING 
#arg of getNumByte
lw $a1, dimension
jal getNumByte#Returns in $v1 number of bytes needed to store last element of matrices

#arg of compareMatrices
move $t9, $v1 #we store max-size for our loop contained in compareMatrices
la $a1, matrixA
la $a2, matrixB
la $a3, matrixD
jal compareMatrices#this makes a new matrix D from minimum values of each position of A and B

#newLine
li $v0, 4
la $a0, newLine
syscall

#PRINT TITLE: "MATRIX D: "
li $v0, 4
la $a0, matrixDTitle
syscall
#PRINT MATRIX D:
#arg
addi $t0, $zero, 0
la $a0, matrixD
lw $a1, dimension
jal getNumByte #$v1 = dimension
move $a2, $v1
jal printMatrix
#Program WORKED!
li $v0, 4
la $a0, miMensaje
syscall

#THIS TERMINATES PROGRAM
j exit

getNumByte: #Calculates number of bytes needed to store values of matrices////ARGUMENTS: needs in $a1 value of dimension////RESULT: $v1
	li $t1, 4 #Size of step(4 Bytes for every element of matrix)
	mul $a1, $a1, $a1 #dimension*dimension
	mul $v1, $a1, $t1 #(dimension*dimension)*4
	jr $ra #gives back control to caller

printMatrix:#FUNCTION:Prints a matrix////ARGUMENTS: address of first element of matrix=$a0////AUX: counter $t0 ////RESULT: Void
	move $t1, $a2 #stores in $t1 the value of "Number of bytes needed to store all elements of matrix"
	addi $t2, $zero, 4 #Sets value of step to 4
	
	beq $t0, $t1, endPrintMatrix
	
		#prints current value
		li $v0, 2
		lwc1 $f12, 0($a0)
		syscall
		#STEP
		#moves to the next 4 bytes/element
		add $a0, $a0, $t2 
		#Adds 4 bytes to the counter
		addi $t0, $t0, 4
	
		#Tab
		move $t7 $a0#storing value of address to avoid loosing it when calling the system to print a new line
		li $v0, 4
		la $a0, tabAndBreak
		syscall
	
		#give back old return address
		move $a0 $t7
	j printMatrix
	
endPrintMatrix:
	jr $ra #give back control to caller

endMinimoFloat:
	jr $ra #give back control to caller

minimoFloat:#FUNCTION: Gives minimum from two float values////ARGUMENTS: $a2=first number; $a3=second number////RESULT:$v1 = minimum of two numbers introduced
	
	move $t8, $a2 #saving arguments enteres in temp registers
	move $s5, $a3 #same as last line
	move $t9 $ra# $t9 Saves return value to go back to where minimoFloat was called
	
	blt $t8, $s5, firstLess #Â¿$t9 < $t7? --YES-->goto: firstLess////---NO--->CONTINUE
	bgt $t8, $s5, secondLess#Â¿$t9 > $t7? --YES-->goto: secondLess////----NO--->CONTINUE
	j areEqual
		
		
firstLess:
	move $v1, $t8 #assings result to results register $v1
	move $ra, $t9 #gives back return address from where minimoFloat was called
	jr $ra #gives back control to caller
secondLess:
	move $v1, $s5 #assings result to results register $v1
	move $ra, $t9 ##gives back return address from where minimoFloat was called
	jr $ra #gives back control to caller
areEqual:
	move $v1, $a2 #assings result to results register $v1
	move $ra, $t9 ##gives back return address from where minimoFloat was called
	jr $ra #gives back control to caller

compareMatrices:#FUNCTION: Compare two float matrices element by element and asigning minimum value to same position in matrix D
		#ARGUMENTS:$a1 = start address of one matrix; $a2 = start address of other matrix; $a3 = start address of matrixD
		#RESULT: void 
		#IMPORTANT Notes: REQUIRES a pre-call to getNumByte before calling compareMatrices and move result: move $t9, $v1
		
		move $s7, $ra#saves original main calling address in a non-temporal register
		li $t0, 0 #counter = 0
		move $t6, $v1 #moves result of calling getNumbyte-->max-Size of bytes needed to access last element of matrices
		
		move $s1, $a1
		move $s2, $a2
		move $s3, $a3

		lw $t5, nan
		
		while: 
			beq, $t0, $t6, endCompareMatrices #if (counter == max-size)-->goto: endCompareMatrices
			
				lw $t2, ($s1)#stores value of one matrix
				lw $t3, ($s2)#stores value of other matrix
				
				beq $t2, $t5, asignNan #if (matriz[i] == nan) -->goto: asignNan
				#else
				beq $t3, $t5, asignNan#if (matriz[i] == nan) -->goto: asignNan
				#else
				
				
				#arguments to call minimoFloat
				move $a2 $t2  # ARG: current value of one matrix
				move $a3 $t3  # ARG: current value of other matrix
				
				jal minimoFloat
				move $t1, $v1 #move result(minimum value found between two) to $t1
				
				sw $t1, ($s3)#stores minimum value found in current position of matrixD
				j next
				
				next:
					addi $t0, $t0, 4#counter ++4
					#plus 4 bytes in all memory addresses
					addi $s1, $s1, 4
					addi $s2, $s2, 4
					addi $s3, $s3, 4
					#---------------
				j while
				
asignNan:

	sw $t5, ($s3) #gives value NaN to matrix D
	j next

endCompareMatrices:
		move $ra, $s7#gives back return address
		jr $ra
		
sumarMin: #FUNCTION: Checks if there any errors while proccessing matrix 
	#ARGUMENTS: $a0 = dimension;$a1 = address of first element of matrix; $a2 address of second element of matrix
	  #RESULT: $v1
	  
	  move $s7, $ra
#check dimension
blez $a0, errorDim1
#check dimension is coincident with array length
lw $a1, dimension 
jal getNumByte #bytes needed to store all elements of matrices USING DIMENSION as an argument.
move $t7, $v1 #$t7 stores maximum value needed to sotre last element of matrix from a root direction

lw $t6, size

beq $t7, $t6, allOk
#else
j errorDim2

allOk:
	li $v1, 0 
	
	li $v0, 4
	la $a0, noErrors
	syscall
	move $ra, $s7
	jr $ra
	
errorDim1:
	li $v1, -1
	li $v0, 4
	la $a0, errorDim1Message
	syscall
	j exit
	
errorDim2:
	li $v1, -1
	li $v0, 4
	la $a0, errorDim2Message
	syscall
	j exit
	
exit:
    li $v0, 10
    syscall		
   
cConstruction:#Function: Build matrix C following criteria of comparisson. #Arguments: position of memory of first element of each of 3 different matrices

	move $t8, $ra#we save  address of original caller of function
	
	#Special Values
	lw $s1, ($sp) #loading Infinty value to $s1
	addi $sp, $sp, 4 #free space
	lw $s0, ($sp) #loading NaN value to $s0
	addi $sp, $sp, 4 #free space
	lw $t2, ($sp) #set limit for loop that goes through elements of matrices(BYTES)
	addi $sp, $sp, 4 #free space
	
	addi $t1, $zero, 0#set counter(Step: +4)
	
	cConstructionLoop:
		lw $t3, ($a1)#saves current value of one matrix to a register
		lw $t4, ($a2)#saves current value of other matrix to a register
		
		beq $t1, $t2, endCConstruction	
		
		#shift left to eliminate sign of matrices
		sll $t3, $t3, 1 
		sll $t4, $t4, 1 
		#shift right to return to position (without sign)
		srl $t3, $t3, 1
		srl $t4, $t4, 1	
		
		beq $t3, $zero, Ais0#Check if A is 0
		beq $t3, $s0, AisNaN#Check if A is NaN
		beq $t4, $s0, BisNaN#Check if A is NaN
		beq $t3, $s1, AisInfinity#Check if A is Infinity
		beq $t4, $s1, BisInfinity#Check if A is Infinity
		
		#reloading the elements of matrices to temp registers to get original sign back
		lw $t3, ($a1)
		lw $t4, ($a2)
		
		#IEE  754 criteria
		#Exponent 
		sll $t6, $t3, 1#SIGN: shift 1 bit to the left to elimante bit sign
		srl $t6, $t6, 24 #EXPONENT:Shift 24 bits to the right to eliminate mantisa
		li $s5, 127 #load 127 in register $s5
		sub $t6, $t6, $s5 #substract 127 to obtain real value of exponent and save it in $t6
		#Mantisa
		sll $t7, $t3, 9 #shift 9 bits to de left to eliminate sign and exponent bits
		srl $t7, $t7, 9 #return to original position of mantisa but having eliminated the sign and exponent
					 #save value of mantisa in $s7
		beq $t6, $zero checkMantisaA #if exponent = 0 check value of mantisa
		j AisNormalized #else if the exponent is not zero then  de value of matrix A is normalized
					 #after these conditions de value 0 or 1 will have been stored in $s6
					 #if $s6 = 1 ---> value is normalized
					 #if $s6 = 0 ---> value is not normalized
					 
	cConstructionContinue: # do the same process but with matrix B
		sll $t6, $t4, 1
		srl $t6, $t6, 24
		sub $t6, $t6, $s5
		
		sll $t7, $t4, 9
		srl $t7, $t7, 9
		
		beq $t6, $zero checkMantisaB
		j BisNormal  
					 #after these conditions de value 0 or 1 will have been stored in $s7
					 #if $s7 = 1 ---> value is normalized
					 #if $s7 = 0 ---> value is not normalized
		
	cConstructionContinue2: #compare the values at $s6 and $s7
		
		bgt $s6, $s7, CEqualsA #if $s6 = 1 and $s7 = 0 the value of matrix C will be the value of A
		bgt $s7, $s6, CEqualsB #if $s6 = 0 and $s7 = 1 the value of matrix C will be the value of B
		beqz $s6,  CIsZero #if the above conditions haven´t been met and  value of $s6 = 0 this means $s7 is also 0
					    #if $s6 = 0 and $s7 = 0 then the value of matrix C is 0.0
							
		j CEqualsAPlusB #if the above conditions haven´t been met then both values in matrix A and B are normalized
		      		 #of A and B are normalized C = A + B
		
	step:
		#we print current value of matrix C
		li $v0, 2
		lwc1 $f12, 0($a3) 
		syscall
		#print space between values printed
		li $v0, 4
		la $a0, tabAndBreak
		syscall
		#we move 4 bytes in each position of memory of each matrix
		addi $a1, $a1, 4 #for matrix A
		addi $a2, $a2, 4 #for matrix B
		addi $a3, $a3, 4 #for matrix C
		
		addi $t1, $t1, 4 #step of 4 bytes to our counter
		
		b cConstructionLoop
	#Auxiliar tags 
	Ais0:
		beq $t4, $zero, BisZero # A = 0 and B = 0 ---> C = 0
		beq $t4, $s0, BisNaN
		beq $t4, $s1, BisInfinity
		j cConstructionContinue # A = 0 and B = float ---> jump to check normalization
	BisZero:
		sw $t3, ($a3) # A = 0 and B = 0---> C = 0 (we just take the value of A which must be 0)
		j step #jump to print value of element of C and continue running through matrices
	AisNaN:
		sw $s0, ($a3)	#if A is NaN store NaN in matrix C
		j step #jump to print value of element of C and continue running through matrices
	BisNaN:
		sw $s0, ($a3)	#save value of matrix A(NaN) in C
		j step #jump to print value of element of C and continue running through matrices
	AisInfinity:
		sw $s0, ($a3)	#if A is infinty store NaN in matrix C
		j step	#jump to print value of element of C and continue running through matrices
	BisInfinity:
		sw $s0, ($a3) #store NaN in C
		j step #jump to print value of element of C and continue running through matrices
	checkMantisaA: #At this point we know A is not a NaN or infinity but we don´t know what B is
		bnez $t7, ANotNormalized #if mantisa is not 0 then the valua at A is not normalized
		j AisNormalized #else A is normalized
	AisNormalized:
		li $s6, 1 #store 1 in $s6 because A is normalized and B has a valid value
		j cConstructionContinue #jump to continue analyzing exponent and mantisa of B
	ANotNormalized:
		li $s6, 0 #store 0 in $s6 because A is not normalized and B has a valid value
		j cConstructionContinue #jump to continue analyzing exponent and mantisa of B
	checkMantisaB:
		bnez $t7, BisNotNormalized #if the mantisa of B is not zero then B is not normalized
		j BisNormal #else B is normalized
	BisNormal:
		li $s7, 1 #store 1 in $s7 because B is normalized and A has a valid value
		j cConstructionContinue2 #jump to start comparing the values stored in $s6 and $s7
	
	BisNotNormalized:
		li $s7, 0 #store 0 in $s7 because B is not normalized and A has a valid value
		j cConstructionContinue2 #jump to start comparing the values stored in $s6 and $s7
	CEqualsA:
		sw $t3, ($a3) #store value of A in C
			j step #jump to print value of element of C and continue running through matrices
	CEqualsB:
		sw $t4, ($a3) #store value of B in C
			j step #jump to print value of element of C and continue running through matrices
	CIsZero:
		addi $a3, $a3, 0 #C = 0
			j step
	CEqualsAPlusB:
		mtc1 $t3, $f3 #move value of $t3(matrix A) to $f3 at Coproc 1 
		cvt.s.w $f5, $f3 #Convert Integer to Single 
		mtc1 $t4, $f4 #move value of $t4(matrix B) to $f4 at Coproc 1 
		cvt.s.w $f6, $f4 #Convert Integer to Single 

		add.s $f2, $f4, $f3 # A + B ---> store in $f2
		
		s.s $f2, 0($a3) #save the result of the sum in matrix C
			j step #jump to print value of element of C and continue running through matrices
	endCConstruction:
		move $ra, $t8
		jr $ra