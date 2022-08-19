data segment
PageUp dw 4900h		;下翻页
PageDown dw 5100h	;上翻页
Home dw 4700h		;页首
keyEnd dw 4F00h		;页末
keyEsc dw 011Bh		;退出
filename db 100, ?, 100 dup(0)		;文件名
buf db 256 dup(0)	;
handle dw 0		;文件句柄
key dw 0		;bioskey值
bytes_in_buf dw 0	;
file_size dd 0		;文件大小
file_offset dd 0	;32位文件偏移值
rows dw 0
bytes_on_row dw 0
tag db '0123456789ABCDEF'	;16进制索引
msgbox1 db 'Please input filename:', 0Dh, 0Ah, '$'	;消息窗口1
msgbox2 db 'Cannot open file!', 0Dh, 0Ah, '$'		;消息窗口2
string db '00000000:            |           |           |                             '
data ends

code segment
assume ds:data, cs:code
start:
  mov ax, data
  mov ds, ax
  mov ah, 9
  mov dx, offset msgbox1
  int 21h		;输出'Please input filename:'
  mov dx, offset filename
  mov ah, 0Ah
  int 21h		;以buffer形式读入filename字符串
  mov bx, word ptr [filename+1]
  and bx, 00FFh
  mov [filename+2+bx], 0;！修改文件名结尾为0x00
  mov ah, 2
  mov dl, 0Ah
  int 21h		;换行
  mov ah, 3Dh
  mov al, 0
  mov dx, offset filename+2
  int 21h
  mov handle, ax	;打开文件
  jc file_open_error
  jmp file_open_success
file_open_error:
  mov ah, 9
  mov dx, offset msgbox2
  int 21h		;输出'Cannot open file!'
  mov ah, 4Ch
  mov al, 0
  int 21h		;exit
file_open_success:
  mov ah, 42h
  mov al, 2
  mov bx, handle
  mov cx, 0
  mov dx, 0
  int 21h
  mov word ptr file_size[2], dx
  mov word ptr file_size[0], ax
  mov ax, 3
  int 10h		;video mode
  mov ax, 0B800h
  mov es, ax	;segment address
while_loop:
  ;32位减法dx:ax = dx:ax - cx:bx(>0)
  mov dx, word ptr file_size[2]	;32位file_size高8位->dx
  mov ax, word ptr file_size[0]	;32位file_size低8位->ax
  mov cx, word ptr file_offset[2]	;32位file_offset高8位->cx
  mov bx, word ptr file_offset[0]	;32位file_offset低8位->bx
  call sub_32_bit
  ;计算bytes_in_buf
  cmp dx, 0
  je dx_zero_true	;dx为0,继续判断
  jmp above_256		;dx非0,dx:ax必定大于256
  dx_zero_true:
    cmp ah, 0
    je ah_zero_true	;dx为0,ah为0,dx:ax必定小于256
    jmp above_256	;dx为0,ah非0,dx:ax必定大于等于256
  ah_zero_true:
    mov bytes_in_buf, ax
    jmp zero_next_1
  above_256:
    mov ax, 256
    mov bytes_in_buf, ax
  zero_next_1:
  ;lseek
  mov ah, 42h
  mov al, 0
  mov bx, handle
  mov cx, word ptr file_offset[2]
  mov dx, word ptr file_offset[0]
  int 21h
  ;_read
  mov ah, 3Fh
  mov bx, handle
  mov cx, bytes_in_buf
  mov dx, data
  mov ds, dx
  mov dx, offset buf
  int 21h
  ;show_this_page函数
  ;参数bx->offset buf
  ;参数dx:ax->file_offset
  ;参数cx->bytes_in_buf
  mov bx, offset buf
  mov dx, word ptr file_offset[2]
  mov ax, word ptr file_offset[0]
  mov cx, bytes_in_buf
  call show_this_page
  ;bioskey
  mov ah, 0
  int 16h
  mov key, ax
  ;switch(key)
  mov si, key
  jmp switch_1
  while_loop_temp1:		;临时标签
  jmp while_loop
  switch_1:
    cmp si, PageUp
    je key_PageUp
    jmp switch_2
    key_PageUp:
      mov dx, word ptr file_offset[2]
      mov ax, word ptr file_offset[0]
      mov cx, 0
      mov bx, 256
      call sub_32_bit
      jc file_offset_below_zero
      jmp file_offset_above_equal_zero
      file_offset_below_zero:
      mov dx, 0
      mov ax, 0
      mov word ptr file_offset[2], dx
      mov word ptr file_offset[0], ax      
      jmp final
      file_offset_above_equal_zero:
      mov word ptr file_offset[2], dx
      mov word ptr file_offset[0], ax
      jmp final
  switch_2:
    cmp si, PageDown
    je key_PageDown
    jmp switch_3
    key_PageDown:
      mov dx, word ptr file_offset[2]
      mov ax, word ptr file_offset[0]
      push dx
      push ax
      mov cx, 0
      mov bx, 256
      call add_32_bit
      mov cx, word ptr file_size[2]
      mov bx, word ptr file_size[0]
      call sub_32_bit
      jc inside_file
      jmp out_of_file
      inside_file:
      pop ax
      pop dx
      mov cx, 0
      mov bx, 256
      call add_32_bit
      mov word ptr file_offset[2], dx
      mov word ptr file_offset[0], ax
      jmp final
      out_of_file:
      pop ax
      pop dx
      jmp final
  switch_3:
    cmp si, Home
    je key_Home
    jmp switch_4
    key_Home:
      mov dx, 0
      mov ax, 0
      mov word ptr file_offset[2], dx
      mov word ptr file_offset[0], ax
      jmp final
  jmp switch_4
  while_loop_temp2:		;临时标签
  jmp while_loop_temp1
  switch_4:
    cmp si, keyEnd
    je key_End
    jmp final
    key_End:
      mov dx, word ptr file_size[2]
      mov ax, word ptr file_size[0]
      mov bx, 256
      call div_32_bit
      mov dx, word ptr file_size[2]
      mov ax, word ptr file_size[0]
      mov cx, 0
      mov bx, si
      call sub_32_bit
      mov word ptr file_offset[2], dx
      mov word ptr file_offset[0], ax
      mov cx, word ptr file_size[2]
      mov bx, word ptr file_size[0]
      cmp dx, cx
      je dx_cx_equal
      jmp not_equal
      dx_cx_equal:
        cmp bx, ax
	je bx_ax_equal
        jmp not_equal
      bx_ax_equal:
        mov dx, cx
	mov ax, bx
	mov cx, 0
	mov bx, 256
        call sub_32_bit
        mov word ptr file_offset[2], dx
        mov word ptr file_offset[0], ax
	jmp final
      not_equal:
	jmp final
  final:
  mov di, keyEsc
  cmp key, di
  jne while_loop_temp2	;对应.C的while循环
  mov ah, 3Eh
  mov bx, handle
  int 21h		;关闭文件
  mov ah, 4Ch
  mov al, 0
  int 21h		;exit
;---------------自定义函数--------------------
;---------把8位数转化成16进制格式-----------
;输入8位al，以16进制字符形式输出高4位字符至bh与低4位字符至bl
;操作的寄存器有ax, bx, cl, si
char2hex:
  push ax
  push cx
  push si
  mov ah, 0
  push ax
  mov cl, 4
  shr al, cl
  mov si, ax
  mov bh, byte ptr tag[si]
  pop ax
  and al, 0Fh
  mov si, ax
  mov bl, byte ptr tag[si]
  pop si
  pop cx
  pop ax
  ret
;---------把32位数转化成16进制格式----------
;输入dx:ax->file_offset偏移
;用到了ax, dx, cl, bx
long2hex:
  push ax
  push dx
  push cx
  push bx
  push ax
  mov dx, word ptr file_offset[2]
;最高8位
  mov al, dh
  call char2hex
  mov byte ptr string[0], bh
  mov byte ptr string[1], bl
;较高8位
  mov al, dl
  call char2hex
  mov byte ptr string[2], bh
  mov byte ptr string[3], bl
  pop ax
  push ax
;较低8位
  mov al, ah
  call char2hex
  mov byte ptr string[4], bh
  mov byte ptr string[5], bl
  pop ax
;最低8位
  call char2hex
  mov byte ptr string[6], bh
  mov byte ptr string[7], bl
  pop bx
  pop cx
  pop dx
  pop ax
ret
;---------显示当前一行----------
;显示当前行的段地址，16进制内容，字符内容
;输入bx->offset buf + 16 * i数组首地址
;输入dx:ax->file_offset + 16 * i偏移
;输入cx->bytes_on_row当前行字节数
;输入si->row行号
;输出void
show_this_row:
  push si
  push ax
  pop ax
  call long2hex
  ;把buf中各个字节转化成16进制格式填入s中的xx处
  mov di, 0
  push ax
  push bx
  jmp first_show_this_row_cycle_1
  show_this_row_cycle_1:
    mov al, ds:[bx+di]
    push bx									;debug: char2hex返回值为bx, 会破坏对应行的偏移地址的值，需要push和pop;
    call char2hex
    push di
    mov bp, 0
    add bp, di
    add bp, di
    add bp, di
    mov byte ptr string[bp+10], bh
    mov byte ptr string[bp+10+1], bl
    pop di
    pop bx									;debug: push bx与pop bx没有对应在一起
    add di, 1
    first_show_this_row_cycle_1:
    cmp di, cx
    jb show_this_row_cycle_1
  pop bx
  pop ax
  ;把buf中各个字节填入s右侧小数点处
  push ax
  mov di, 0
  jmp first_show_this_row_cycle_2
  show_this_row_cycle_2:
    mov al, byte ptr [bx+di]
    mov byte ptr string[di+59], al
    add di, 1
    first_show_this_row_cycle_2:
    cmp di, cx
    jb show_this_row_cycle_2
  pop ax
  ;计算row行对应的视频地址
  push ax
  push dx
  mov bx,160
  mov ax, si
  mov dx, 0
  mul bx
  mov bx, ax
  pop dx
  pop ax
  ;输出s
  push ax
  mov di, 0
  jmp first_show_this_row_cycle_3
  show_this_row_cycle_3:
    mov al, string[di]
    push di
    add di, di
    mov byte ptr es:[bx+di], al
    mov byte ptr es:[bx+di+1], 07h
    pop di
    add di, 1
    first_show_this_row_cycle_3:
    cmp di, 75
    jb show_this_row_cycle_3
    mov byte ptr es:[bx+43], 0Fh
    mov byte ptr es:[bx+67], 0Fh
    mov byte ptr es:[bx+91], 0Fh
  pop ax
  pop si
ret
;---------清除屏幕0~15行--------------------
;输入void
;输出void
clear_this_page:
  mov bx, 0
  clear_char:
  mov word ptr es:[bx], 0020h
  add bx, 2
  cmp bx, 2560
  jb clear_char
ret
;---------显示屏幕0~15行--------------------
;显示当前页
;输入bx->offset buf数组首地址
;输入dx:ax->file_offset偏移
;输入cx->bytes_in_buf当前页字节数
;输出void
show_this_page:
  call clear_this_page
  ;计算当前页行数
  mov cx, bytes_in_buf
  mov ax, cx
  add ax, 15
  mov bx, 16
  mov dx, 0
  div bx
  mov rows, ax
  ;显示当前页
  mov si, 0
  jmp first_show_this_page_compare
show_this_page_cycle:
  ;i*16
  mov ax, si
  mov bx, 16
  mul bx
  ;计算bytes_on_row
  mov di, rows
  sub di, 1
  cmp si, di
  je si_di_equal
  jmp si_di_not_equal
  si_di_equal:
      mov cx, bytes_in_buf
      mov di, cx
      sub di, ax
      mov bytes_on_row, di
  si_di_not_equal:
    mov di, 16
    mov bytes_on_row, di
  ;i*16
  mov ax, si
  mov bx, 16
  mul bx
  mov di, ax
  ;输入dx:ax->file_offset + 16 * i偏移
  mov dx, word ptr file_offset[2]
  mov ax, word ptr file_offset[0]
  mov cx, 0
  mov bx, di
  call add_32_bit
  ;输入bx->offset buf + 16 * i数组首地址
  mov bx, offset buf
  add bx, di
  ;输入si->row行号
  mov si, si
;输入cx->bytes_on_row当前行字节数
  mov cx, bytes_on_row
  call show_this_row								;debug: 之前漏掉了这一步。。。
  add si, 1
  first_show_this_page_compare:
  cmp si, rows
  jb show_this_page_cycle
ret
;---------32位减法--------------------
;32位减法dx:ax = dx:ax - cx:bx(>0)
;注意cx = 0xFFFF时的减法溢出
;根据cf判断减法结果是否为负
;输入dx:ax, cx:bx
;输出dx:ax, cf
sub_32_bit:
  sub ax, bx		;32位差的低16位
  jc carry_true_1	;有借位
  jmp carry_next_1	;无借位
  carry_true_1:
    add cx, 1		;高8位退1						;debug: 原先写了'dec dx, 1'后来发现会有问题,　见下一个debug
  carry_next_1:
    sub dx, cx		;32位差的高16位						;debug: 在执行上一步前dx=cx=0, 如果执行'dec dx, 1', 那么cf=1,执行下一步后cf=0, 但是实际减法是溢出的, 考虑到本程序中file_size不太可能是64k(cx=FFFF),所以上一步处理为'add cx, 1'
ret
;---------32位加法--------------------
;32位加法dx:ax = dx:ax + cx:bx
;注意加法溢出
;根据cf判断加法是否溢出
;输入dx:ax, cx:bx
;输出dx:ax, cf
add_32_bit:
  add ax, bx
  jc carry_true_2
  jmp carry_next_2
  carry_true_2:
    add dx, 1
  carry_next_2:
    add dx, cx
ret
;---------32位除法--------------------
;32位除法dx:ax / bx = dx:ax...si
;改良后的除法不会溢出
;输入被除数dx:ax, 除数bx
;输出商dx:ax，余数si
div_32_bit:
  mov cx, ax		;保存好低位ax
  mov ax, dx
  mov dx, 0
  div bx		;所得的商ax为最终商的高16位，余数dx为下一步除法的被除数低16位
  mov di, ax
  mov ax, cx
  div bx		;所得的商ax为最终商的低16位，余数dx为最终余数
  mov si, dx		;最终的余数si
  mov dx, di		;最终的高16位商dx
ret
code ends
end start
