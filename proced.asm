imprimirTextos macro matriz, size
    LOCAL loopImprimir
    push SI
    push CX
    push AX
    push DX
    LEA SI, matriz ;Offset del array menu
    MOV CX, size ;Tamaño del array

    ;Imprimiendo el texto inicial recorriendo el array
    loopImprimir:
        MOV DX, [SI]
        MOV AH, 9
        int 21h
        INC SI
        INC SI
    LOOP loopImprimir

    ;Recuperación de los valores originales de los registros y el index
    pop DX
    pop AX
    pop CX
    pop SI
endm

imprimirArchivo macro direccion
        XOR ax, ax
        XOR dx, dx
		mov ah, 09h  
	    mov dx, offset direccion
	    int 21h
endm


;======================ABRIR EL ARCHIVO===========================
abrirArchivo macro ruta, manejador
    mov ah, 3Dh ;Mover función para abrir archivo
    mov al, 02h ;Modo de permiso
    lea dx, ruta ;Nombre del fichero a leer
    int 21h ;Ejecutar instrucción
    mov manejador, ax ;Guardar el manejador
endm
;=================================================================



;======================CERRAR EL ARCHIVO===========================
cerrarArchivo macro manejador
    mov ah, 3Eh
    mov bx, manejador
    int 21h
endm
;=================================================================


;======================PEDIR RUTA POR TECLADO===========================
pedirRutaPorTeclado macro rutaPorTeclado
    lea si, rutaPorTeclado
    pedir:
        mov ah, 01H
        int 21h
        cmp al, 0Dh
        je fin_pedir
        mov [si], al
        inc si
        jmp pedir
    fin_pedir:
endm
;=================================================================



;======================LEER ARCHIVO===========================
leerArchivo macro lectura, manejador, letra, instruccion, contadorOp, sum_a,sum_c,res_a,res_c,mul_a,mul_c,div_a,div_c,val_a,val_c,op_a,op_c, numeros, contadorNum,saltoLinea,padre_a,padre_c
    local ciclo, finCiclo
    mov si, offset instruccion
    mov di, offset lectura
    ciclo:
        ;Conseguir caracter de entrada, 1 x 1
        imprimirArchivo lectura
        imprimirArchivo saltoLinea
        mov ah, 3Fh
        mov bx, manejador
        mov cx, 1
        lea dx, letra
        int 21h

        ;Verificar si se llego al final del archivo
        cmp letra, ';'
        je escribirReporte

        ;Verificar si se abrió una nueva operacion y ver si hay un número para guardar
        cmp letra, '<'
        je verificarNumero

        ;Verificar si se cerró una operación y ver si hay un nuevo id para guardar
        cmp letra, '>'
        je verificarId

        cmp letra, 0dh
        je ciclo

        cmp letra, 0ah
        je ciclo

        cmp letra, 09h
        je ciclo

        cmp letra, 'A'
        jb getNumero
        jae getId

        jmp ciclo

        getId:
            lowerCase letra
            mov cl, letra
            mov [di], cl
            inc di
            jmp ciclo

        getNumero:
            cmp letra,'-'
            je esNegativo
            mov cl, letra
            mov [di],cl
            inc di
            jmp ciclo
            esNegativo:
                mov ch,1
                mov cl,2
                sub ch,cl
                pushf
            jmp ciclo
        verificarNumero:
            cmp lectura[0],'$'
            je ciclo
            convertirNumeros lectura, numeros, contadorNum
            jmp ciclo

        verificarId:
            ejecutarOp lectura, sum_a,sum_c,res_a,res_c,mul_a,mul_c,div_a,div_c,val_a,val_c,op_a,op_c, contadorOp , numeros, contadorNum,padre_a,padre_c
            jmp ciclo
        escribirReporte:
            imprimirArchivo instruccion
            jmp finCiclo

    finCiclo:
endm
;=================================================================


;======================Convertir a número===========================

convertirNumeros macro lectura, numeros, contadorNum
    local ciclo,finalizar,negativo, fin
    push si

    mov si, offset lectura
    mov ax,0
    mov cx,10

    ciclo:
        mul cx
        mov bx,ax  
        xor ax,ax
        mov al, [si]
        sub al,48
        add ax,bx
        inc si
        cmp [si],'$'
        je finalizar
        jne ciclo

    finalizar:  
        limpiarLector lectura
        mov di, offset lectura
            
        aam 
        add ah, 30h
        add al, 30h   
        pop si 
        popf
        js negativo 
        mov [si],ah
        inc si
        mov [si],al
        inc si   
        ;push ax  
        push di
        mov di,contadorNum
        sub ah, 30h
        sub al, 30h
        mov numeros[di],ax
        inc contadorNum
        inc contadorNum
        pop di
        jmp fin 
        negativo:
        mov bx,-1
        mul bx
        ;push ax
        push di
        mov di,contadorNum
        sub ah, 30h
        sub al, 30h
        mov numeros[di],ax
        inc contadorNum
        inc contadorNum
        pop di
        mov cl,'-'
        add ah, 30h
        add al, 30h
        mov [si],cl
        inc si
        mov [si],ah
        inc si
        mov [si],al
        inc si                      
        fin: 
        
endm



;=================================================================


;======================Lower Case===========================
lowerCase macro letra
local salir
    cmp letra, '/'
    je salir
    cmp letra, 'a'
    jae salir
    add letra, 20h
    salir:
endm
;=================================================================

;======================Verificar id===========================
ejecutarOp macro lectura, sum_a,sum_c,res_a,res_c,mul_a,mul_c,div_a,div_c,val_a,val_c,op_a,op_c, contadorOp, numeros, contadorNum,padre_a,padre_c
    ;push ax
    ;push cx
    comparar lectura, sum_a
    je agregarSuma
    comparar lectura, res_a
    je agregarResta
    comparar lectura, mul_a
    je agregarMulti
    comparar lectura, div_a
    je agregarDiv
    comparar lectura, val_a
    je salir
    comparar lectura, padre_a
    je salir
    comparar lectura, op_a
    je agregarOp

    comparar lectura, sum_c
    je exeSuma
    comparar lectura, res_c
    je exeResta
    comparar lectura, mul_c
    je exeMulti
    comparar lectura, div_c
    je exeDiv
    comparar lectura, val_c
    je salir
    comparar lectura, padre_C
    je salir
    comparar lectura, op_c
    je finOperacion

    jmp salir

    agregarSuma:
        mov cl, '+'
        mov [si], cl
        inc si
        jmp salir
    agregarResta:
        mov cl, '-'
        mov [si], cl
        inc si
        jmp salir
    agregarMulti:
        mov cl, '*'
        mov [si], cl
        inc si
        jmp salir
    agregarDiv:
        mov cl, '/'
        mov [si], cl
        inc si
        jmp salir

    exeSuma:
        ;pop ax
        push si
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        mov bx, ax
        ;pop ax
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        add ax,bx
        ;push ax
        mov numeros[si],ax
        inc contadorNum
        inc contadorNum
        pop si
        jmp salir
    exeResta:
        ;pop ax
        push si
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        mov bx, ax
        ;pop ax
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        sub ax,bx
        ;push ax
        mov numeros[si],ax
        inc contadorNum
        inc contadorNum
        pop si
        jmp salir
    exeMulti:
        ;pop ax
        push si
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        mov bx, ax
        ;pop ax
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        imul bx
        ;push ax
        mov numeros[si],ax
        inc contadorNum
        inc contadorNum
        pop si
        jmp salir
    exeDiv:
        ;pop ax
        push si
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        mov bx, ax
        ;pop ax
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        xor dx,dx
        idiv bx
        ;push ax
        mov numeros[si],ax
        inc contadorNum
        inc contadorNum
        pop si
        jmp salir

    agregarOp:
        addOp lectura
        jmp salir
    finOperacion:
        dec contadorNum
        dec contadorNum
        mov si,contadorNum
        mov ax, numeros[si]
        add al, 30h
        add ah, 30h
        mov [di],' '
        inc di
        mov [di],'='
        inc di
        mov [di],' '
        inc di
        mov [di],ax
        inc di
        inc di
        mov [di], 0dh
        inc di
        inc contadorOp
        ;realizar operacion
    salir:    
        limpiarLector lectura
        mov di, offset lectura
        ;pop cx
        ;pop ax
endm
;=================================================================


;======================Agregar el id de la op===========================
addOp macro lectura
    local ciclo, fin
    push di
    mov di, offset lectura
    ciclo:
        mov cl,[di]
        cmp cl, 24h
        je fin
        mov [si],cl
        inc si
        inc di
        jmp ciclo
    fin:
        mov [si], ' '
        inc si
        mov [si], '='
        inc si
        mov [si], ' '
        inc si
        pop di
endm
;=================================================================

;======================Comparar===========================
comparar macro lectura, operacion
    local comparacion, mensaje, fin
    push si
    push di
    mov si, offset operacion
    mov di, offset lectura
    comparacion:
        mov cl, [si]
        mov bl, [di]
        cmp cl, 24h
        je fin
        cmp cl,bl
        jne mensaje
        inc si
        inc di
        jmp comparacion
    mensaje:
        ;imprimirArchivo noes     
           
    fin:
        pop di
        pop si
endm


;=================================================================


;======================Limpiar lector===========================
limpiarLector macro lectura
    local limpiar
    push si
    push cx
    lea si, lectura
    mov cl,'$'
    mov ch,0
    limpiar:
        mov [si],cl
        inc si
        inc ch
        cmp ch,11
        jne limpiar
    pop cx
    pop si
endm

;=================================================================




;======================LIMPIAR REGISTROS===========================
limpiarRegistros macro
    XOR ax,ax
    XOR bx,bx
    XOR cx,cx
    XOR dx,dx
    XOR si,si
endm
;=================================================================




;======================ESCRIBIR FIN DE ARCHIVO===========================
escribirFin macro manejador, escribir
    
;POSICIONAR CURSOR
    mov ah, 42h
    mov al, 02h
    mov bx, manejador
    mov cx, 0
    mov dx, 0
    int 21h

;ESCRIBIR EN ARCHIVO
    mov ah, 40h
    mov bx, manejador
    mov cx, 1
    lea dx, escribir
    int 21h
endm

;=================================================================



