.data
msg: .asciiz "Ket qua: "
.text
.globl main
main:
    addiu $a0, $zero, 5
    jal   outer
    addu  $s0, $zero, $v0
    addiu $v0, $zero, 4
    lui   $a0, 0x1001
    ori   $a0, $a0, 0x0000
    syscall
    addu  $a0, $zero, $s0
    addiu $v0, $zero, 1
    syscall
    addiu $v0, $zero, 10
    syscall

outer:
    addi  $sp, $sp, -4
    sw    $ra, 0($sp)
    jal   inner
    addi  $v0, $v0, 1
    lw    $ra, 0($sp)
    addi  $sp, $sp, 4
    jr    $ra

inner:
    add   $v0, $a0, $a0
    jr    $ra
