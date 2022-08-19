data segment
s db 4 dup(0),0Dh,0Ah,'$'		;error_1:字符串的定义
data ends

code segment
assume cs:code, es:data
main:
mov ax, 3
int 10h		;video mode
mov ax, 0B800h
mov es, ax	;segment address
mov bx, 0	;offset address
mov cx, 0	;ascii_10
mov dx, 0	;column

again:
;ASCII字符显示
  mov byte ptr es:[bx], cl
  mov byte ptr es:[bx+1], 0Ch
;16进制第一位
  push cx
  and cx, 000Fh
  cmp cx, 10
  jb is_digit_a
is_alpha_a:
  sub cx, 10
  add cx, 'A'
  jmp next_a
is_digit_a:
  add cx, '0'
next_a:
  mov byte ptr es:[bx+4], cl
  mov byte ptr es:[bx+5], 0Ah
;16进制第二位
  pop cx				;error_3:pop别忘了，8位寄存器不能进栈？
  push cx	;待测试
  shr cx, 4				;error_2:区分右移动与左移
  and cx, 000Fh
  cmp cx, 10
  jb is_digit_b
is_alpha_b:
  sub cx, 10
  add cx, 'A'
  jmp next_b
is_digit_b:
  add cx, '0'
next_b:
  mov byte ptr es:[bx+2], cl
  mov byte ptr es:[bx+3], 0Ah
;补4个空格?
  pop cx
  cmp bx, 3840
  jb goon
space:
  sub bx, 3840
  add bx, 14
  jmp tail
goon:
  add bx, 160
tail:
  add cx, 1
  cmp cx, 255				;error_4:cx16位不能溢出，所以不能用jnz
jbe again


mov ah, 0
int 16h
mov ah, 4Ch
int 21h
code ends
end main
