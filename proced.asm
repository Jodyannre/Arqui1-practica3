
;======================IMPRIMIR TEXTO DE ARRAYS===========================
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
;=================================================================


;======================IMPRIMIR CUALQUIER TEXTO===========================

imprimirArchivo macro direccion
        XOR ax, ax
        XOR dx, dx
		mov ah, 09h  
	    mov dx, offset direccion
	    int 21h
endm
;=================================================================



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
pedirPorTeclado macro rutaPorTeclado
    local pedir, fin_pedir
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

;======================DATOS INICIALES TABLA===========================

iniciarTabla macro
    <table>
    <thead>
    <tr>
    <th>
    <b>
    mov [si],'I'
    inc si
    mov [si],'d'
    inc si
    </b>
    </th>
    <th>
    <b>
    mov [si],'O'
    inc si
    mov [si],'p'
    inc si
    </b>
    </th>
    <th>
    <b>
    mov [si],'R'
    inc si
    mov [si],'e'
    inc si
    </b>
    </th>
    </tr>
    </thead>
    <tbody>    
endm


;======================================================================


;======================CERRAR TABLA===========================
cerrarTabla macro
    </tbody>
    </table>    
endm

;======================================================================


;======================LEER ARCHIVO===========================
leerArchivo macro lectura, manejador, letra, instruccion, contadorOp, sum_a,sum_c,res_a,res_c,mul_a,mul_c,div_a,div_c,val_a,val_c,op_a,op_c, numeros, contadorNum,saltoLinea,padre_a,padre_c
    local ciclo, finCiclo, getId, getNumero, verificarNumero, verificarId, escribirReporte
    mov si, offset instruccion
    mov di, offset lectura
    iniciarTabla
    ciclo:
        ;Conseguir caracter de entrada, 1 x 1
        ;imprimirArchivo lectura
        ;imprimirArchivo saltoLinea
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

        cmp letra, '-'
        je getNumero

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
                mov cl, '('
                mov [si],cl
                inc si
                mov cl, letra
                mov [si],cl
                inc si
                mov cl, ')'
                mov [si], cl
                inc si
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
            ;cerrarTabla
            push si
            imprimirArchivo instruccion
            jmp finCiclo

    finCiclo:
endm
;=================================================================


;======================Convertir a número===========================

convertirNumeros macro lectura, numeros, contadorNum
    local ciclo,finalizar,negativo, fin, omitirH
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
        limpiarLector lectura, 60
        mov di, offset lectura
        mov cx, ax    
        aam 
        add ah, 30h
        add al, 30h   
        pop si  
        cmp ah,30h
        je omitirH            
        mov [si],ah
        inc si
        omitirH:
        mov [si],al
        inc si 
        popf
        js negativo  
        ;push ax  
        push di
        mov di,contadorNum
        mov ax, cx
        ;sub ah, 30h
        ;sub al, 30h
        mov numeros[di],ax
        inc contadorNum
        inc contadorNum
        pop di
        jmp fin 
        negativo:
        mov ax, cx
        ;sub ah, 30h
        ;sub al, 30h
        mov bx,-1
        mul bx
        ;push ax
        push di
        mov di,contadorNum
        mov numeros[di],ax
        inc contadorNum
        inc contadorNum
        pop di
        ;mov cl,'-'
        ;add ah, 30h
        ;add al, 30h
        ;mov [si],cl
        ;inc si
        ;mov [si],ah
        ;inc si
        ;mov [si],al
        ;inc si                      
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
    local agregarDiv, agregarMulti, agregarOp, agregarResta, agregarSuma, exeDiv, exeMulti, exeResta, exeSuma, salir,finOperacion, esNegativo, divNegativo,continuarDiv, mulNegativo, continuarMul,resNegativo, res2Negativo, continuarRes, sumNegativo, sum2Negativo, continuarSum, esMayor, divNegativo, div2Negativo, div2tNegativo, mulNegativo, mul2Negativo, mul2tNegativo
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

        test ax,ax
        js sumNegativo
        add ax,bx
        jmp continuarSum

        sumNegativo:
            neg ax
            test bx,bx
            js sum2Negativo
            sub ax,bx
            neg ax
            jmp continuarSum

            sum2Negativo:
                sub ax,bx
                neg ax
                jmp continuarSum

        continuarSum:
            ;push ax
            mov numeros[si],ax
            pop si
            ;test ax,ax
            ;pushf
            inc contadorNum
            inc contadorNum      
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

        test ax,ax
        js resNegativo:
        sub ax,bx
        jmp continuarRes
        ;push ax

        resNegativo:
            neg ax
            test bx,bx
            js res2Negativo
            add ax,bx
            neg ax
            jmp continuarRes

            res2Negativo:
                ;neg bx
                add ax,bx
                neg ax
                jmp continuarRes

        
        continuarRes:
            mov numeros[si],ax
            pop si
            ;test ax,ax
            ;pushf
            inc contadorNum
            inc contadorNum
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
        xor dx,dx
        test ax,ax
        js mulNegativo
        test bx,bx
        js mul2Negativo
        mul bx
        jmp continuarMul
        mulNegativo:
            neg ax
            test bx,bx
            js mul2tNegativo
            mul bx
            neg ax
            jmp continuarMul   
        mul2tNegativo:
            neg bx
            mul bx 
            jmp continuarMul              
        ;push ax
        mul2Negativo:
            neg bx
            mul bx
            neg ax
            jmp continuarMul
        continuarMul:
            mov numeros[si],ax
            pop si
            ;test ax,ax
            ;pushf
            inc contadorNum
            inc contadorNum
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
        test ax,ax
        js divNegativo
        test bx,bx
        js div2Negativo
        div bx
        jmp continuarDiv
        divNegativo:
            neg ax
            test bx,bx
            js div2tNegativo
            xor dx,dx
            div bx
            neg ax
            jmp continuarDiv   
        div2tNegativo:
            neg bx
            xor dx,dx
            div bx 
            jmp continuarDiv               
        ;push ax
        div2Negativo:
            neg bx
            xor dx,dx
            div bx
            neg ax
            jmp continuarDiv
        continuarDiv:
            mov numeros[si],ax
            pop si
            ;test ax,ax
            ;pushf
            inc contadorNum
            inc contadorNum
            jmp salir

    agregarOp:
        addOp lectura
        jmp salir
    finOperacion:
        </td>
        <td>
        push di
        dec contadorNum
        dec contadorNum
        mov di,contadorNum
        mov ax, numeros[di]
        ;cmp ax,0
        ;popf
        ;jg noEsNegativo
        ;js esNegativo
        test ax,ax
        js esNegativo
        noEsNegativo:
        ;add ah, 30h
        ;add al, 30h
        ;mov [si],' '
        ;inc si
        ;mov [si],'='
        ;inc si
        ;mov [si],' '
        ;inc si
        ;mov [si],ax
        ;aam
        ;add ah,30h
        ;add al,30h
        ;mov [si],ah
        ;inc si
        ;mov [si],al
        ;inc si
        numberToAscii
        </td>
        ;saltoHtml
        jmp salir
        esNegativo:
            push bx
            mov bx,-1
            mul bx
            ;add ah, 30h
            ;add al, 30h
            ;mov [si],' '
            ;inc si
            ;mov [si],'='
            ;inc si
            ;mov [si],' '
            ;inc si
            mov [si],'-'
            inc si
            ;mov [si],ax
            ;aam
            ;add ah,30h
            ;add al,30h
            ;mov [si],ah
            ;inc si
            ;mov [si],al
            ;inc si
            numberToAscii
            </td>
            ;saltoHtml
            pop bx
        ;realizar operacion
    salir: 
        inc contadorOp
        pop di   
        limpiarLector lectura,11
        mov di, offset lectura
        ;pop cx
        ;pop ax
endm
;=================================================================


;======================Numeros grandes===========================

numberToAscii macro
    local esMenor, digito, recorrerPila, unDigito, ciclo, esIgual
        xor dx,dx
        mov cx, 1
        mov bx, 10
    digito:
        cmp ax,10
        jb esMenor
        div bx
        inc cx
        push dx
        jmp digito
    esMenor:
        push ax
        cmp cx,1
        je unDigito
        ciclo:
            cmp cx,1
            je unDigito
            dec cx
            pop dx
            add dl, 30h
            mov [si],dl
            inc si
            jmp ciclo
    unDigito:
        pop dx
        mov ax,dx
        ;add ah, 30h
        ;mov [si],ah
        ;inc si
        add al, 30h
        mov [si],al
        inc si 
endm



;=================================================================


;======================Agregar el id de la op===========================
addOp macro lectura
    local ciclo, fin
    push di
    mov di, offset lectura
    <tr>
    <td>
    ciclo:
        mov cl,[di]
        cmp cl, 24h
        je fin
        mov [si],cl
        inc si
        inc di
        jmp ciclo
    fin:
        ;mov [si], ' '
        ;inc si
        ;mov [si], '='
        ;inc si
        ;mov [si], ' '
        ;inc si
        </td>
        <td>
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
limpiarLector macro lectura,cantidad
    local limpiar
    push si
    push cx
    push bx
    lea si, lectura
    mov cl,'$'
    mov ch,0
    mov bl,cantidad
    limpiar:
        mov [si],cl
        inc si
        inc ch
        cmp ch,cantidad
        jne limpiar
    pop bx
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


;======================LIMPIAR CONSOLA===========================
cls macro
    push ax
    ;mov ah, 06h
    ;mov al, 0
    ;int 10h
    mov ah,00
    mov al,02
    int 10h
    pop ax
endm
;=================================================================


;======================ESPERAR ENTER===========================
enter macro
    local pedir, fin_pedir
    push ax
    push si
    pedir:
        mov ah, 01H
        int 21h
        cmp al, 0Dh
        je fin_pedir
        mov [si], al
        inc si
        jmp pedir
    fin_pedir:   
    pop si
    pop ax    
endm


;=================================================================



;======================CONSEGUIR HORA===========================

getHora macro hora
    mov si,offset hora
    mov ah, 2ch
    int 21h
    ;Aqui se consigue la hora y los registros quedan así:
    ;Ch = hora
    ;Cl = minuto
    ;Dh = segundo
    ;Mando un número para decirle que es el último
    xor ax,ax
    mov al,ch
    convertirHora 0
    mov al,cl
    convertirHora 0
    mov al, dh
    convertirHora 1
    saltoHtml
    ;saltoHtml
endm


;=================================================================


;======================CONVERTIR HORA===========================

convertirHora macro ultimo
    local esCero,verificarUltimo, menor,agregarPuntos,fin
    push ax
    push bx
    push cx
    push dx
    cmp al,0
    je esCero
    cmp al,10
    jb menor
    xor dx,dx
    mov bx,10
    div bx
    aam
    add al,30h 
    mov [si],al
    inc si
    mov al,dl
    aam
    add al,30h
    mov [si],al
    inc si
    jmp verificarUltimo

    menor:
        mov [si],30h
        inc si    
        aam
        add al, 30h    
        mov [si], al
        inc si
        jmp verificarUltimo
    esCero:
        mov [si],30h
        inc si
        mov [si],30h
        inc si

    verificarUltimo:
        mov al, ultimo
        cmp al,1
        je fin
        jne agregarPuntos

    agregarPuntos:
        mov [si],':'
        inc si
    fin:
        pop dx
        pop cx
        pop bx
        pop ax
endm
;=================================================================



;======================CONSEGUIR FECHA===========================
getFecha macro fecha
    mov si,offset fecha
    mov ah, 2ah
    int 21h
    ;Aqui se consigue la hora y los registros quedan así:
    ;CX = año
    ;DH = mes
    ;DL = dia
    ;Mando un número para decirle que es el último
    xor ax,ax
    mov al,dl
    convertirHora 1
    mov [si],'/'
    inc si
    mov al,dh
    convertirHora 1
    mov [si],'/'
    inc si
    mov ax,cx
    getYear 5
    saltoHtml
    ;saltoHtml
endm
;=================================================================

;======================AGREGAR SALTO HTML===========================
saltoHtml macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si
    mov [si],'b'
    inc si
    mov [si],'r'
    inc si
    mov [si],'>'
    inc si
endm

;=================================================================

;======================CONVERTIR FECHA===========================
getYear macro iteracion
    local conseguido, fin, dividir  
    push dx
    push cx
    push ax
    push bx
    
    mov bx,10
    mov cx,1
    dividir:
        xor dx,dx
        div bx
        push dx
        cmp ax,10
        jb conseguido
        jmp dividir
    conseguido:
        aam
        add al,30h 
        mov [si],al
        inc si
        inc cx       
        cmp cx,iteracion
        je fin
        pop dx
        mov al,dl
        jne conseguido
    fin:
        pop bx
        pop ax
        pop cx
        pop dx
endm

;=================================================================




;======================CREAR HTML===========================

crearHtml macro nombre,manejador,errorCreacion
    local error, fin
    lea dx, nombre
    mov cx,0
    ;Crear el archivo
    mov ah, 3ch
    int 21h
    mov manejador,ax
    jc error
    ;Cerrar el archivo
    ;mov ah, 3Eh
    ;mov bx, manejador
    ;int 21h
    jmp fin
    error:
        imprimirArchivo errorCreacion
        enter
        ;Rutina para terminar programa
        ;mov ax, 4c00h
        ;int 21h
    fin:
endm

;=================================================================



;======================ESCRIBIR HTML===========================
writeHtml macro manejador,errorCreacion,contenido
    mov ah,40h
    mov bx,manejador
    getArraySize contenido
    lea dx,contenido
    int 21h    
    ;cerrarArchivo manejador
endm
;=================================================================

;======================GET SIZE ARRAY===========================
getArraySize macro array
    local ciclo,fin
    mov cx,0
    lea si,array
    ciclo:
        cmp [si],'$'
        je fin
        inc si
        inc cx
        jmp ciclo
    fin:
endm
;=================================================================



;======================MACROS PARA ETIQUETAS TABLA HTML===========================


<b> macro
    mov [si],'<'
    inc si
    mov [si],'b'
    inc si
    mov [si],'>'
    inc si
endm

</b> macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si
    mov [si],'b'
    inc si
    mov [si],'>'
    inc si
endm

<table> macro
    mov [si],'<'
    inc si
    mov [si],'t'
    inc si
    mov [si],'a'
    inc si
    mov [si],'b'
    inc si
    mov [si],'l'
    inc si
    mov [si],'e'
    inc si
    mov [si],'>'
    inc si
endm

<thead> macro
    mov [si],'<'
    inc si
    mov [si],'t'
    inc si
    mov [si],'h'
    inc si
    mov [si],'e'
    inc si
    mov [si],'a'
    inc si
    mov [si],'d'
    inc si
    mov [si],'>'
    inc si
endm

<tr> macro
    mov [si],'<'
    inc si
    mov [si],'t'
    inc si
    mov [si],'r'
    inc si
    mov [si],'>'
    inc si
endm

<th> macro
    mov [si],'<'
    inc si
    mov [si],'t'
    inc si
    mov [si],'h'
    inc si
    mov [si],'>'
    inc si
endm

<tbody> macro
    mov [si],'<'
    inc si
    mov [si],'t'
    inc si
    mov [si],'b'
    inc si
    mov [si],'o'
    inc si
    mov [si],'d'
    inc si
    mov [si],'y'
    inc si
    mov [si],'>'
    inc si
endm

<td> macro
    mov [si],'<'
    inc si
    mov [si],'t'
    inc si
    mov [si],'d'
    inc si
    mov [si],'>'
    inc si
endm



</table> macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si
    mov [si],'t'
    inc si
    mov [si],'a'
    inc si
    mov [si],'b'
    inc si
    mov [si],'l'
    inc si
    mov [si],'e'
    inc si
    mov [si],'>'
    inc si
endm

</thead> macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si
    mov [si],'t'
    inc si
    mov [si],'h'
    inc si
    mov [si],'e'
    inc si
    mov [si],'a'
    inc si
    mov [si],'d'
    inc si
    mov [si],'>'
    inc si
endm

</tr> macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si   
    mov [si],'t'
    inc si
    mov [si],'r'
    inc si
    mov [si],'>'
    inc si
endm

</th> macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si   
    mov [si],'t'
    inc si
    mov [si],'h'
    inc si
    mov [si],'>'
    inc si
endm

</tbody> macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si
    mov [si],'t'
    inc si
    mov [si],'b'
    inc si
    mov [si],'o'
    inc si
    mov [si],'d'
    inc si
    mov [si],'y'
    inc si
    mov [si],'>'
    inc si
endm

</td> macro
    mov [si],'<'
    inc si
    mov [si],'/'
    inc si   
    mov [si],'t'
    inc si
    mov [si],'d'
    inc si
    mov [si],'>'
    inc si
endm
;=================================================================================



;======================FACTORIAL===========================

factorial macro ingreseNumero,operaciones,resultado,numPorTeclado,numeroUni,opFactorial,saltoLinea, resultNum
    local ciclo, fin,factorial,continuar,unDig,tresDig,result,uno,tres,parcial,tresDig2,unDig2,noesCero,facdeUno,cuatro,cuatroDig,cuatroDig2
    imprimirArchivo ingreseNumero
    imprimirArchivo saltoLinea
    pedirPorTeclado numPorTeclado
    getNum numPorTeclado, numeroUni
    lea si,opFactorial
    mov bx,1
    mov cx,ax
    mov ax,1   
    mov [si],'0'
    inc si
    mov [si],'!'
    inc si
    mov [si],'='
    inc si
    mov [si],'1'
    inc si
    mov [si],';'
    inc si
    mov [si], ' '
    inc si
    cmp cx,0
    je fin
    ciclo:
        jmp factorial       
        continuar:
            mov [si],';'
            inc si
            mov [si], ' '
            inc si
            add bx,1
            sub cx,1
            cmp cx,0
            jne ciclo
            jmp result
        factorial:
            ;mul bx
            mov dx,bx
            add dl,30h
            mov [si],dl
            inc si
            mov [si],'!'
            inc si
            mov [si],'='
            inc si
            sub dl,1
            cmp dl,30h
            jne noesCero
                mov [si],31h
                inc si
                add dl,1
                jmp facdeUno
            noesCero:
                add dl,1
                mov [si],dl
                inc si
                facdeUno:
                    mov [si],'*'
                    inc si
                    cmp ax,999
                    ja cuatroDig
                    cmp ax,99
                    ja tresDig
                    cmp ax,10
                    jb unDig
                    getYear 3
                    jmp parcial
            cuatroDig:
                getYear 5
                jmp parcial
            tresDig:
                getYear 4
                jmp parcial
            unDig:
                convertirHora 1
                jmp parcial
            parcial:
                mul bx
                mov [si], '='
                inc si
                cmp ax,999
                ja cuatroDig2
                cmp ax,99
                ja tresDig2
                cmp ax,10 
                jb unDig2
                getYear 3
                jmp continuar
            cuatroDig2:
                getYear 5
                jmp continuar
            tresDig2:
                getYear 4
                jmp continuar
            unDig2:
                convertirHora 1
                jmp continuar
        result:
            limpiarLector numPorTeclado,5
            lea si, resultNum
            ;mov [si],'='
            ;inc si
            ;lea si,numPorTeclado
            cmp ax,999
            ja cuatro
            cmp ax,99
            ja tres
            cmp ax, 10
            jb uno
            getYear 3
            jmp fin
            cuatro:
                getYear 5
                jmp fin
            tres:
                getYear 4
                jmp fin
            uno:
                convertirHora 1
                jmp fin
        fin:
            imprimirArchivo saltoLinea
            imprimirArchivo operaciones
            imprimirArchivo saltoLinea
            imprimirArchivo saltoLinea
            imprimirArchivo opFactorial
            imprimirArchivo saltoLinea
            imprimirArchivo resultado
            imprimirArchivo resultNum

endm
;==========================================================




;======================GET NUM POR TECLADO===========================
getNum macro lectura, numero
    local ciclo,finalizar,negativo, fin, omitirH
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
        limpiarLector lectura,5
        mov numero[0],ax
        jmp fin                  
        fin: 
        
endm
;==========================================================