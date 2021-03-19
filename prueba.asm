.model small
.stack
.code
org 100h

data:
    kal1 db 'MIKROSKIL$'
    kal2 db 11 dup(?)
code1:
    mov bx,0
ulang1:
    mov dl,kal1[bx]
    mov kal2[bx],dl
    inc bx
    cmp dl,'$'
    jne ulang1
    mov ah,9
    mov dx,offset kal2
    int 21h
    int 20h
end data