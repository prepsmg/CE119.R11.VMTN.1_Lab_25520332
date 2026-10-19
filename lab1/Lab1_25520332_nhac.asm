.data
	space: .asciiz " "
	breakline: .asciiz "\n"
	length: .word 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 1, 4
	height: .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
	note: .word 15
	dukien: .asciiz "Tong du kien (ms): "
	doduoc: .asciiz "Thoi gian do duoc (ms): "
.text
main:
	li $v0, 30
	syscall
	move $s5, $a0
	
	la $s0, height
	la $s1, length
	lw $s2, note
	li $s3, 0
	li $s4, 0
loop:
	beq $s3, $s2, end_loop
	sll $t0, $s3, 2
	add $t1, $s0, $t0
	lw $t2, 0($t1)
	addi $t2, $t2, 2
	add $t1, $s1, $t0
	lw $t3, 0($t1)
	mul $t3, $t3, 180
	add $s4, $s4, $t3
	li $v0, 1
	move $a0, $t2
	syscall
	li $v0, 4
	la $a0, space
	syscall
	li $v0, 1
	move $a0, $t3
	syscall
	li $v0, 4
	la $a0, breakline
	syscall
	
	move $a0, $t2
	move $a1, $t3
	li $a2, 73
	li $a3, 100
	li $v0, 31
	syscall
	li $v0, 32
	move $a0, $t3
	syscall
	
	addi $s3, $s3, 1
	j loop
end_loop:
	li $v0, 30
	syscall
	move $s6, $a0
	sub $s7, $s6, $s5
	li $v0, 4
	la $a0, dukien
	syscall
	li $v0, 1
	move $a0, $s4
	syscall
	li $v0, 4
	la $a0, breakline
	syscall
	li $v0, 4
	la $a0, doduoc
	syscall
	li $v0, 1
	move $a0, $s7
	syscall
	li $v0, 10
	syscall
	
	