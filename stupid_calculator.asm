data segment
buffer1 db 6, ?, 6 dup(0)
buffer2 db 6, ?, 6 dup(0)
msg2 db 10 dup(0), 0Dh, 0Ah, '$'	;十进制
msg3 db 9 dup(0), 0Dh, 0Ah, '$'		;十六进制，后跟h
msg4 db 40 dup(0), 0Dh, 0Ah, '$'	;二进制，四位一空格，后跟B
data ends

code segment
assume cs:code, ds:data
start:
;=============================================================
input_1:		;输入第一个数字
  mov ax, data
  mov ds, ax
  mov dx, offset buffer1
  mov ah, 0Ah
  int 21h
  
  mov bx, 10		;常数10
  mov cl, [buffer1+1]	;当前字符串长度
  mov di, 1		;下标
  mov ax, word ptr [buffer1+2]	;ax初始化
  mov ah, 0
  sub ax, '0'
  mov ch, 0
  cmp cl, 1		;是否是一位字符串
  je next_1
  again_1:
    mul bx
    mov si, word ptr [buffer1+di+2]
    and si, 00FFh
    sub si, '0'
    add ax, si
    add di, 1
    cmp di, cx
    jne again_1
  next_1:
    push ax
  mov bx, word ptr [buffer1+1]
  and bx, 00FFh
  mov [buffer1+2+bx], '$'


input_2:		;输入第二个数字
  mov dx, offset buffer2
  mov ah, 0Ah
  int 21h
  ;
  mov bx, 10		;常数10
  mov cl, [buffer2+1]	;当前字符串长度
  mov di, 1		;下标
  mov ax, word ptr [buffer2+2]	;ax初始化
  mov ah, 0
  sub ax, '0'
  mov ch, 0
  cmp cl, 1		;是否是一位字符串
  je next_2
  again_2:
    mul bx
    mov si, word ptr [buffer2+di+2]
    sub si, '0'
    and si, 00FFh
    add ax, si
    add di, 1
    cmp di, cx
    jne again_2
  next_2:
    mov bx, ax
    push bx
  
  mov bx, word ptr [buffer2+1]
  and bx, 00FFh
  mov [buffer2+2+bx], '$'


;=============================================================
calc:			;乘法计算
  pop bx
  pop ax
  mul bx
  push dx
  push ax

;=============================================================
formula:		;算式输出
  mov dx, offset buffer1 + 2
  mov ah, 9
  int 21h

  mov ah, 2
  mov dl, '*'
  int 21h


  mov dx, offset buffer2 + 2
  mov ah, 9
  int 21h

  mov ah, 2
  mov dl, '='
  int 21h
  
  mov ah, 2
  mov dl, 0Dh
  int 21h

  mov ah, 2
  mov dl, 0Ah
  int 21h
;=============================================================
  pop ax
  pop dx
  push dx
  push ax
to10:			;十进制输出
  mov si, 0
again_push:
  mov cx, ax
  mov bx, 10

  mov ax, dx
  mov dx, 0
  div bx
  mov di, ax		;高位商
  
  mov ax, cx
  div bx
  push dx		;余数
  mov dx, di
  add si, 1
  cmp dx, 0
  jnz again_push
  cmp ax, 0
  jnz again_push
  mov bx, 0
again_pop:
  pop dx
  add dl, '0'
  mov byte ptr [msg2+bx], dl
  add bx, 1
  sub si, 1
  cmp si, 0
  jnz again_pop
  
  mov ah, 9
  mov dx, offset msg2
  int 21h
;=============================================================
  pop ax
  pop dx
  push dx
  push ax
to16:			;十六进制输出
  mov cx, 4
  mov di, 0; destination index
  again_316:
    push cx
    mov cl, 4
    rol dx, cl; 把DX循环左移4位
    push dx
    and dx, 000Fh
    cmp dx, 10
    jb is_digit_316
  is_alpha_316:
    sub dl, 10
    add dl, 'A'
    jmp finish_4bits_316
  is_digit_316:
    add dl, '0'
  finish_4bits_316:
    mov msg3[di], dl
    pop dx
    pop cx
    add di, 1
    sub cx, 1
    jnz again_316

    mov cx, 4
    mov di, 4; destination index
  again_416:
    push cx
    mov cl, 4
    rol ax, cl; 把AX循环左移4位
    push ax
    and ax, 000Fh
    cmp ax, 10
    jb is_digit_416
  is_alpha_416:
    sub al, 10
    add al, 'A'
    jmp finish_4bits_416
  is_digit_416:
    add al, '0'
  finish_4bits_416:
    mov msg3[di], al
    pop ax
    pop cx
    add di, 1
    sub cx, 1
    jnz again_416

    mov msg3[8], 'h'

    mov ah, 9
    mov dx, offset msg3
    int 21h
;=============================================================
  pop ax
  pop dx
to2:			;二进制输出
  mov cx, 16
  mov di, 0; destination index
  mov si, 0;
again_52:
  push cx
  mov cl, 1
  rol dx, cl; 把DX循环左移1位
  push dx
  and dx, 0001h
  add dl, '0'
  cmp si, 4
  jne goon_52
  mov msg4[di], ' '
  mov si, 0
  add di, 1
goon_52:
  mov msg4[di], dl
  pop dx
  pop cx
  add di, 1
  add si, 1
  sub cx, 1
  jnz again_52

  mov cx, 16
  mov di, 20; destination index
  mov si, 0
again_62:
  push cx
  mov cl, 1
  rol ax, cl; 把AX循环左移1位
  push ax
  and ax, 0001h
  add al, '0'
  cmp si, 4
  jne goon_62
  mov msg4[di], ' '
  mov si, 0
  add di, 1
goon_62:
  mov msg4[di], al
  pop ax
  pop cx
  add di, 1
  add si, 1
  sub cx, 1
  jnz again_62

  mov msg4[39], 'B'

  mov ah, 9
  mov dx, offset msg4
  int 21h
;=============================================================
  mov ah, 4Ch
  int 21h
code ends
end start
