.data
n:   .word 13
msg: .asciiz "F(n) = "
.text
.globl main
main:
    lui   $t0, 0x1001
    ori   $t0, $t0, 0x0000
    lw    $a0, 0($t0)
    jal   fib_rec
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

fib_rec:
    addi  $sp, $sp, -12
    sw    $ra, 8($sp)
    sw    $s0, 4($sp)
    sw    $s1, 0($sp)
    addu  $s0, $zero, $a0
    slti  $t0, $s0, 2
    beq   $t0, $zero, fr_rec
fr_base:
    addu  $v0, $zero, $s0
    j     fr_ret
fr_rec:
    addi  $a0, $s0, -1
    jal   fib_rec
    addu  $s1, $zero, $v0
    addi  $a0, $s0, -2
    jal   fib_rec
    add   $v0, $s1, $v0
fr_ret:
    lw    $s1, 0($sp)
    lw    $s0, 4($sp)
    lw    $ra, 8($sp)
    addi  $sp, $sp, 12
    jr    $ra

fib_iter:
    addu  $v0, $zero, $zero
    addiu $t0, $zero, 1
    addu  $t1, $zero, $zero
fi_loop:
    slt   $t2, $t1, $a0
    beq   $t2, $zero, fi_done
    addu  $t3, $v0, $t0
    addu  $v0, $zero, $t0
    addu  $t0, $zero, $t3
    addiu $t1, $t1, 1
    j     fi_loop
fi_done:
    jr    $ra
