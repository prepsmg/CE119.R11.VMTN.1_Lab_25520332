.data
scores:     .word 8, 5, 10, 0, 4, 7, 9, 4, 8, 0, 6, 5
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
.align 2
hist:       .word 0, 0, 0, 0
str_p:      .asciiz "([{([])}])"
s_min:      .asciiz "min="
s_max:      .asciiz " max="
s_p:        .asciiz "P: "

.text
main:
    la   $a0, scores
    li   $a1, 12
    jal  stats
    move $s0, $v0               # min
    move $s1, $v1               # max

    la   $a0, scores            # stats da lam thay doi $a0, $a1
    li   $a1, 12
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    move $a0, $s0
    move $a1, $s1
    la   $a2, hist
    jal  print_report

    la   $a0, hist
    li   $a1, 4
    jal  draw_hist

    la   $a0, str_p
    jal  check_brackets
    move $s0, $v0
    move $s1, $v1
    la   $a0, s_p
    li   $v0, 4
    syscall
    move $a0, $s0
    move $a1, $s1
    jal  print_pair

    li   $v0, 10
    syscall

# ---------------------------------------------------------------
# stats: tim gia tri nho nhat va lon nhat cua mang word
# Tham so   : $a0 = dia chi mang, $a1 = n (n >= 1)
# Tra ve    : $v0 = min, $v1 = max
# Thanh ghi : $a0, $a1 (bi thay doi), $t0, $t1, $v0, $v1
# Thu tuc la, mot luot duyet, khong ghi bo nho
# ---------------------------------------------------------------
stats:
    lw   $v0, 0($a0)            # min = phan tu dau
    move $v1, $v0               # max = phan tu dau
    addi $a0, $a0, 4
    addi $a1, $a1, -1
st_loop:
    beq  $a1, $zero, st_done
    lw   $t0, 0($a0)
    slt  $t1, $t0, $v0          # t0 < min ?
    beq  $t1, $zero, st_chkmax
    move $v0, $t0
st_chkmax:
    slt  $t1, $v1, $t0          # max < t0 ?
    beq  $t1, $zero, st_next
    move $v1, $t0
st_next:
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    st_loop
st_done:
    jr   $ra

# ---------------------------------------------------------------
# histogram: dem so diem trong tung nhom xep loai
# Tham so   : $a0 = dia chi mang diem, $a1 = n,
#             $a2 = dia chi grade_tab, $a3 = dia chi hist
# Tra ve    : khong (hist[g] duoc tang)
# Thanh ghi : $a0, $a1 (bi thay doi), $t0..$t4
# Thu tuc la
# ---------------------------------------------------------------
histogram:
hg_loop:
    beq  $a1, $zero, hg_done
    lw   $t0, 0($a0)            # s = diem
    add  $t1, $a2, $t0          # dia chi grade_tab[s]
    lbu  $t2, 0($t1)            # g = nhom cua diem s
    sll  $t2, $t2, 2            # offset byte = g * 4
    add  $t3, $a3, $t2          # dia chi hist[g]
    lw   $t4, 0($t3)
    addi $t4, $t4, 1
    sw   $t4, 0($t3)
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    hg_loop
hg_done:
    jr   $ra

# ---------------------------------------------------------------
# print_report: in hai dong ket qua thong ke
# Tham so   : $a0 = min, $a1 = max, $a2 = dia chi hist
# Tra ve    : khong
# Thanh ghi : $a0, $v0, $t0..$t2
# Thu tuc la
# ---------------------------------------------------------------
print_report:
    move $t0, $a0               # min
    move $t1, $a1               # max
    la   $a0, s_min
    li   $v0, 4
    syscall
    move $a0, $t0
    li   $v0, 1
    syscall
    la   $a0, s_max
    li   $v0, 4
    syscall
    move $a0, $t1
    li   $v0, 1
    syscall
    li   $a0, 10                # xuong dong
    li   $v0, 11
    syscall
    li   $t0, 0                 # g = 0
    li   $t1, 4                 # so nhom
pr_loop:
    beq  $t0, $t1, pr_done
    beq  $t0, $zero, pr_g       # g0 khong co dau cach phia truoc
    li   $a0, 32                # dau cach
    li   $v0, 11
    syscall
pr_g:
    li   $a0, 103               # chu g
    li   $v0, 11
    syscall
    move $a0, $t0
    li   $v0, 1
    syscall
    li   $a0, 61                # dau =
    li   $v0, 11
    syscall
    sll  $t2, $t0, 2
    add  $t2, $a2, $t2
    lw   $a0, 0($t2)
    li   $v0, 1
    syscall
    addi $t0, $t0, 1
    j    pr_loop
pr_done:
    li   $a0, 10
    li   $v0, 11
    syscall
    jr   $ra

# ---------------------------------------------------------------
# check_brackets: kiem tra cap ngoac ( ) [ ] { } bang ngan xep
# Tham so   : $a0 = dia chi chuoi .asciiz
# Tra ve    : $v0 = vi tri (dem tu 1), $v1 = ma loi (0..3)
# Thanh ghi : $a0 (bi thay doi), $t0..$t4, $t7, $v0, $v1
# $t7 luu $sp luc vao: ngan xep rong khi $sp == $t7, va
# moi duong thoat deu khoi phuc $sp = $t7. Thu tuc la.
# ---------------------------------------------------------------
check_brackets:
    move $t7, $sp               # luu $sp luc vao thu tuc
    li   $t0, 0                 # vi tri hien tai
cb_loop:
    lb   $t1, 0($a0)            # ky tu hien tai
    addi $t0, $t0, 1
    beq  $t1, $zero, cb_end     # het chuoi
    addi $a0, $a0, 1
    li   $t2, 40                # '('
    beq  $t1, $t2, cb_push
    li   $t2, 91                # '['
    beq  $t1, $t2, cb_push
    li   $t2, 123               # '{'
    beq  $t1, $t2, cb_push
    li   $t2, 41                # ')'
    li   $t3, 40
    beq  $t1, $t2, cb_close
    li   $t2, 93                # ']'
    li   $t3, 91
    beq  $t1, $t2, cb_close
    li   $t2, 125               # '}'
    li   $t3, 123
    beq  $t1, $t2, cb_close
    j    cb_loop                # ky tu khac: bo qua
cb_push:
    addi $sp, $sp, -4
    sw   $t1, 0($sp)
    j    cb_loop
cb_close:                       # $t3 = ngoac mo tuong ung
    beq  $sp, $t7, cb_err2      # ngan xep rong
    lw   $t4, 0($sp)
    addi $sp, $sp, 4
    bne  $t4, $t3, cb_err1      # khac loai
    j    cb_loop
cb_err1:
    move $v0, $t0
    li   $v1, 1
    move $sp, $t7
    jr   $ra
cb_err2:
    move $v0, $t0
    li   $v1, 2
    move $sp, $t7
    jr   $ra
cb_end:
    beq  $sp, $t7, cb_ok
    move $v0, $t0               # do dai chuoi + 1
    li   $v1, 3
    move $sp, $t7
    jr   $ra
cb_ok:
    li   $v0, 0
    li   $v1, 0
    move $sp, $t7
    jr   $ra

# ---------------------------------------------------------------
# draw_hist: ve pho diem bang ky tu |
# Tham so   : $a0 = dia chi hist, $a1 = so nhom
# Tra ve    : khong
# Thanh ghi : $a0, $v0, $t0..$t3
# Thu tuc la
# ---------------------------------------------------------------
draw_hist:
    move $t1, $a0               # dia chi hist
    li   $t0, 0                 # g = 0
dh_row:
    beq  $t0, $a1, dh_done
    li   $v0, 11
    li   $a0, 103               # chu g
    syscall
    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 11
    li   $a0, 58                # dau :
    syscall
    li   $a0, 32                # dau cach
    syscall
    sll  $t2, $t0, 2
    add  $t2, $t1, $t2
    lw   $t3, 0($t2)            # so ky tu |
dh_bar:
    beq  $t3, $zero, dh_nl
    li   $v0, 11
    li   $a0, 124               # ky tu |
    syscall
    addi $t3, $t3, -1
    j    dh_bar
dh_nl:
    li   $v0, 11
    li   $a0, 10
    syscall
    addi $t0, $t0, 1
    j    dh_row
dh_done:
    jr   $ra

# ---------------------------------------------------------------
# print_pair: in "(v0, v1)" va xuong dong
# Tham so   : $a0 = v0, $a1 = v1
# Thanh ghi : $a0, $v0, $t0, $t1
# Thu tuc la
# ---------------------------------------------------------------
print_pair:
    move $t0, $a0
    move $t1, $a1
    li   $v0, 11
    li   $a0, 40
    syscall
    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 11
    li   $a0, 44
    syscall
    li   $a0, 32
    syscall
    li   $v0, 1
    move $a0, $t1
    syscall
    li   $v0, 11
    li   $a0, 41
    syscall
    li   $a0, 10
    syscall
    jr   $ra