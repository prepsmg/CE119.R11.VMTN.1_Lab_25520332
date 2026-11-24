.data
str1: .asciiz "kien truc may tinh"
str2: .asciiz "mips"
str3: .asciiz ""
str4: .asciiz "a bc def"
str5: .asciiz "con tro sp luon chia het cho bon"
tbl:  .word str1, str2, str3, str4, str5
bar:  .asciiz "|"
nl:   .asciiz "\n"
.text
.globl main
main:
    lui   $s0, 0x1001
    ori   $s0, $s0, 0x0044
    addi  $s1, $s0, 20
m_loop:
    beq   $s0, $s1, m_end
    lw    $s2, 0($s0)
    addu  $a0, $zero, $s2
    jal   reverse_words
    addiu $v0, $zero, 4
    lui   $a0, 0x1001
    ori   $a0, $a0, 0x0058
    syscall
    addiu $v0, $zero, 4
    addu  $a0, $zero, $s2
    syscall
    addiu $v0, $zero, 4
    lui   $a0, 0x1001
    ori   $a0, $a0, 0x0058
    syscall
    addiu $v0, $zero, 4
    lui   $a0, 0x1001
    ori   $a0, $a0, 0x005a
    syscall
    addi  $s0, $s0, 4
    j     m_loop
m_end:
    addiu $v0, $zero, 10
    syscall

strlen:
    addu  $v0, $zero, $zero
sl_loop:
    addu  $t0, $a0, $v0
    lb    $t1, 0($t0)
    beq   $t1, $zero, sl_done
    addi  $v0, $v0, 1
    j     sl_loop
sl_done:
    jr    $ra

rev_range:
    sltu  $t0, $a0, $a1
    beq   $t0, $zero, rr_done
rr_loop:
    lb    $t1, 0($a0)
    lb    $t2, 0($a1)
    sb    $t2, 0($a0)
    sb    $t1, 0($a1)
    addi  $a0, $a0, 1
    addi  $a1, $a1, -1
    sltu  $t0, $a0, $a1
    bne   $t0, $zero, rr_loop
rr_done:
    jr    $ra

reverse_words:
    addi  $sp, $sp, -16
    sw    $ra, 12($sp)
    sw    $s0, 8($sp)
    sw    $s1, 4($sp)
    sw    $s2, 0($sp)
    addu  $s0, $zero, $a0
    addu  $s2, $zero, $a0
    jal   strlen
    addu  $s1, $s0, $v0
    addi  $s1, $s1, -1
    addu  $a0, $zero, $s0
    addu  $a1, $zero, $s1
    jal   rev_range
rw_scan:
    sltu  $t0, $s1, $s0
    bne   $t0, $zero, rw_last
    lb    $t1, 0($s0)
    addiu $t2, $zero, 32
    bne   $t1, $t2, rw_next
    addu  $a0, $zero, $s2
    addi  $a1, $s0, -1
    jal   rev_range
    addi  $s2, $s0, 1
rw_next:
    addi  $s0, $s0, 1
    j     rw_scan
rw_last:
    addu  $a0, $zero, $s2
    addi  $a1, $s0, -1
    jal   rev_range
    lw    $s2, 0($sp)
    lw    $s1, 4($sp)
    lw    $s0, 8($sp)
    lw    $ra, 12($sp)
    addi  $sp, $sp, 16
    jr    $ra
