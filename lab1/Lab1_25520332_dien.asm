.data 	
	prompt: .asciiz "Nhap so kwh (0..9999): "
	error: .asciiz "Gia tri khong hop le, nhap lai.\n"
	print: .asciiz "Tien dien: "
	breakline: .asciiz "\n"
	
	Bac: .word 50, 50, 100, 100, 100, 9999
	Gia: .word 1640, 1700, 1990, 2540, 2890, 3040
.text
main:
	la $s3, Bac
	la $s4, Gia
loop_input:	
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	move $s0, $v0
	
	bgtu $s0, 9999, invalid
	j init
invalid:
	li $v0, 4
	la $a0, error
	syscall
	j loop_input
init:
	li $s1, 0
	li $s2, 0
loop_calc: 
	blez $s0, print_res
	li $t0, 6
	bge $s2, $t0, print_res
	
	sll $t1, $s2, 2
	
	add $t2, $s3, $t1
	lw $t3, 0($t2)
	
	add $t4, $s4, $t1
	lw $t5, 0($t4)
	
	move $t6, $s0
	ble $s0, $t3, skip
	move $t6, $t3
skip:
	mul $t7, $t6, $t5 	
	add $s1, $s1, $t7
	sub $s0, $s0, $t6
	addi $s2, $s2, 1
	j loop_calc
print_res:
	li $v0, 4
	la $a0, print
	syscall
	
	li $v0, 1
	move $a0, $s1
	syscall
	
	li $v0, 10
	syscall