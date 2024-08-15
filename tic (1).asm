.data
game: .word 0,0,0,0,0,0,0,0,0
CPU: .word 0:17
prompt: .asciiz "\nMake your move."
computer: .asciiz "\nComputer takes "
cwin: .asciiz "\nComputer Wins."
draw: .asciiz "\nDraw."
pwin: .asciiz "\nPlayer Wins."
Seperator: .asciiz "|"
Line: .asciiz "\n--------\n"
newLine: .asciiz "\n"
X: .asciiz "X"
O: .asciiz "O"
dash: .asciiz "-"

.text
li $t3, 0
la $s0, game
la $s1, CPU
li $t1, 8
add $t7, $zero, $s1
	
# RNG the first turn. .
li $v0, 42
li $a1, 2
syscall
move $t0, $a0	# 0 means Computer goes first. 1 means Player first

# Quickly use t1 once to implement computer's possible moves
Fill:  #Randomly fill 9 numbers into array CPU which is t7
	addi $t1, $t1, -1
	li $v0, 42
	li $a1, 9
	syscall
	sw $a0, 0($t7)
	addi $t7, $t7, 4
	bne $t1, $zero, Fill

	# Manually filling out additional best case moves:
	li $t1, 5
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 1
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 3
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 7
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 4
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 0
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 6
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 2
	sw $t1, 0($t7)
	addi $t7, $t7, 4
	li $t1, 8
	sw $t1, 0($t7)

# Main driver
Game:
	beq $t3, 9, Draw
	add $t5, $zero, $s0
	add $t7, $zero, $s1
	j Computer
	j Player
	j Game

# Computer Turn
Computer:
	add $t5, $zero, $s0 
	beq $t0, 1, Player	# If $t0 = 1, player's turn 
	lw $t6, 0($t7)		# Getting first index of $t7... 
	addi $t7, $t7, 4
	
	sll $t4, $t6, 2
	add $t5, $t4, $t5	# Adding $t6 to $t5
	lw $t4, 0($t5)		# Loading value of $t5 into $t4
	bnez $t4, Computer	# If $t4 is not equal to zero, jump to beginning of Computer label due to invalid input (Space is already taken).

	li $t4, -1		# Otherwise, $t4 is set to -1 (Computer's turn)
	sw $t4, 0($t5)		# Value of $t4 is saved back into $t5
	#Print computer label, print value in $t6
	li $v0, 4
	la $a0, computer #"Computer takes: "
	syscall
	li $v0, 1
	la $a0, ($t6)
	syscall
	li $v0, 4
 	la $a0, newLine
 	syscall
	
	add $t5, $zero, $s0
	li $t8, 0
	jal printer
	li $t0, 1 #Sets to player
	addi $t3, $t3, 1 
	bgt $t3, 4, Win
	j Game

# Player Turn   
Player:
	#beq $t0, 0, Computer	# if $t0 equals 0, GAME 
	add $t5, $s0, $zero	# put array address into $t5
	li $v0, 4		# print prompt     
	la $a0, prompt   
	syscall
	

	li $v0, 5 		# read int input; $v0 contains interger read
	syscall
	add $t4, $v0, $zero	# move input to $t4
	
	sll $t4, $t4, 2		# multiply t4 by 4 (shift left 2)
	add $t5, $t4, $t5	# add $t4 and $t5, store into $t5
	lw $t4, 0($t5)		# load the data at $t4 into $t4

	# check if $t4 is 0
	# if it's not 0, jump back to Player (Due to invalid move)
	bne $t4, 0, Player
	
	# Else store 1 at that address. 
	li $t4,1
	sw $t4, 0($t5) 
	li $t0, 0		# change $t0 to 0 (computers turn)
	addi $t3, $t3, 1	# increment t3 by 1
	
	add $t5, $zero, $s0
	li $t8, 0
	jal printer
	# if t3 is greater than 4, Win
	slti $t4, $t3, 4
	bne $t4, 1, Win
	# Loop back
	j Game

#Checks the win condition
Win:
la $t5, ($s0)
add $t6, $zero, $zero
	
Horizontal:	
	lw $t2, 0($t5)	
	addi $t5, $t5, 4	
	lw $t1, 0($t5)	
	add $t1, $t1, $t2	
	addi $t5, $t5, 4	
	lw $t2, 0($t5)
	addi $t5, $t5, 4
	add $t1, $t1, $t2
	addi $t6, $t6, 1
	beq $t1, -3, Comp
	beq $t1, 3, Play
	add $t1, $zero, $zero
	bne $t6, 3, Horizontal
			
la $t5, ($s0)
add $t6, $zero, $zero
add $t1, $zero, $zero
Vertical:
	lw $t2, 0($t5)	
	addi $t5, $t5, 12	
	lw $t1, 0($t5)
	add $t1, $t1, $t2	
	addi $t5, $t5, 12	
	lw $t2, 0($t5)
	add $t1, $t1, $t2	
	addi $t6, $t6, 1	
	beq $t1, -3, Comp	
	beq $t1, 3, Play
	add $t1, $zero, $zero	
	add $t5, $t5, -20	
	bne $t6, 3, Vertical	
# Check Diagonals
	la $t5, ($s0)
	lw $t2, 0($t5)
	lw $t1, 16($t5)
	add $t1, $t1, $t2
	lw $t2, 32($t5)
	add $t1, $t1, $t2
	beq $t1, -3, Comp
	beq $t1, 3, Play
	
	la $t5, ($s0)
	lw $t2, 8($t5)
	lw $t1, 16($t5)
	add $t1, $t2, $t1
	lw $t2, 24($t5)
	add $t1, $t1, $t2
	beq $t1, -3, Comp
	beq $t1, 3, Play
j Game

printer:
	lw $t4, 0($t5)
	addi $t8, $t8, 1
	beq $t8, 4, newL
     	beq $t8, 8, newL
      	beq $t8, 12, Back
     	addi $t5, $t5, 4
    beq $t4, 1, PX
    beq $t4, -1, PO
    beq $t4, 0, PD
    j printer
    
    PX:
    li $v0, 4
 	la $a0, X
 	syscall
 	
    li $v0, 4
 	la $a0, Seperator
 	syscall
 
 	j printer
    PO: #the letter O
    li $v0, 4
 	la $a0, O
 	syscall
    li $v0, 4
 	la $a0, Seperator
 	syscall
 	
 	j printer
    PD: #print empty
    li $v0, 4
 	la $a0, dash
 	syscall
 	
    li $v0, 4
 	la $a0, Seperator
 	syscall
 	
	j printer
	
    newL: #print new
    li $v0, 4
 	la $a0, Line
 	syscall
 	j printer
 	 	
Back:
jr $ra
 	 	
Comp: #Computer Wins
	la $a0, cwin
	li $v0, 4
	syscall
	j Exit

Play: #Player Wins
	la $a0, pwin
	li $v0, 4
	syscall
	j Exit
Draw: #Draw
	la $a0, draw
	li $v0, 4
	syscall
Exit: #Finish
	li $v0, 10
	syscall


