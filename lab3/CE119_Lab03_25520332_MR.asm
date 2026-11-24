.data
n:   .word 20
msg: .asciiz "F(n) = "
.text
.globl main
main:
    lui   $t0, 0x1001
    ori   $t0, $t0, 0x0000
    lw    $a0, 0($t0)
    jal   fib_opt
    addu  $s0, $zero, $v0
    addiu $v0, $zero, 4
    lui   $a0, 0x1001
    ori   $a0, $a0, 0x0004
    syscall
    addu  $a0, $zero, $s0
    addiu $v0, $zero, 1
    syscall
    addiu $v0, $zero, 10
    syscall

fib_opt:
    slti  $t0, $a0, 2
    beq   $t0, $zero, fo_rec
    addu  $v0, $zero, $a0
    jr    $ra
fo_rec:
    addi  $sp, $sp, -12
    sw    $ra, 8($sp)
    sw    $s0, 4($sp)
    sw    $s1, 0($sp)
    addu  $s0, $zero, $a0
    addi  $a0, $s0, -1
    jal   fib_opt
    addu  $s1, $zero, $v0
    addi  $a0, $s0, -2
    jal   fib_opt
    add   $v0, $s1, $v0
    lw    $s1, 0($sp)
    lw    $s0, 4($sp)
    lw    $ra, 8($sp)
    addi  $sp, $sp, 12
    jr    $ra
