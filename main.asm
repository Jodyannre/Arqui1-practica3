imprimirTextos macro matriz, size
    LOCAL loopImprimir
    push SI
    push CX
    push AX
    push DX
    LEA SI, OFFSET matriz ;Offset del array menu
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

.model small
.stack 100h
.data
;================ SEGMENTO DE DATOS ==============================
;Cadenas del mensaje incial y array con todas las cadenas
linea1 db 0ah,0dh,'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA','$'
linea2 db 0ah,0dh,'FACULTAD DE INGENIERIA','$'
linea3 db 0ah,0dh,'ESCUELA DE CIENCIAS Y SISTEMAS','$'
linea4 db 0ah,0dh,'ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1','$'
linea5 db 0ah,0dh,'SECCION A','$'
linea6 db 0ah,0dh,'PRIMER SEMESTRE 2021','$'
linea7 db 0ah,0dh,'Joel Rodriguez Santos','$'
linea8 db 0ah,0dh,'201115018','$'
linea9 db 0ah,0dh,'Tercera practica assembler','$'
inicio dw linea1,linea2,linea3,linea4,linea5,linea6,linea7,linea8,linea9

;Cadenas del menú y array con opciones
menu0  db 0ah,0dh, 'Menu' , '$'
separacion db 0ah, 0dh, '-------------------------', '$'
menu1 db 0ah,0dh, '1. Cargar archivo' , '$'
menu2 db 0ah,0dh, '2. Modo calculadora ' , '$'
menu3 db 0ah,0dh, '3. Factorial ' , '$'
menu4 db 0ah,0dh, '4. Crear reporte' , '$'
menu5 db 0ah,0dh, '5. Salir' , '$'
menu  dw menu0,separacion,menu1,menu2,menu3,menu4,menu5,separacion

;Cadenas de ingreso en el menú
ingreso db 0ah,0dh, 'Ingrese una opcion para continuar','$'
nUno db 0ah,0dh, 'Se ha seleccionado el numero 1','$'
nDos db 0ah,0dh, 'Se ha seleccionado el numero 2','$'
nTres db 0ah,0dh, 'Se ha seleccionado el numero 3','$'
nCuatro db 0ah,0dh, 'Se ha seleccionado el numero 4','$'
nCinco db 0ah,0dh, 'Se ha seleccionado el numero 5','$'

;db -> dato byte -> 8 bits
;dw -> dato word -> 16 bits
;dd -> doble word -> 32 bits
.code ;segmento de código
org 100h
;================== SEGMENTO DE CODIGO ===========================
	main proc
        MOV AX, @data
        MOV DS, AX
        imprimirTextos menu,8
        mov ah,9
        lea dx,ingreso ;Impresión de cadena para ingreso de una opción del menú
        int 21h
        leer:
            mov ah, 1   ; Leer entrada del teclado
            int 16h
            jz  leer    ; Determinar si se ha presionado algo
            mov ah, 0   ; Obtener tecla presionada
            int 16h    
            cmp al, '1' ; Comparar la tecla presionada
            je numeroUno  
            cmp al, '2' ; Comparar la tecla presionada
            je numeroDos
            cmp al, '3' ; Comparar la tecla presionada
            je numeroTres
            cmp al, '4' ; Comparar la tecla presionada
            je numeroCuatro
            cmp al, '5' ; Comparar la tecla presionada
            jne leer
        numeroUno: ;Si se seleccionó la opción 1
            mov ah,9
            lea dx, nUno
            int 21h
            jmp fin
        numeroDos: ;Si se seleccionó la opción 2
            mov ah,9
            lea dx, nDos
            int 21h
            jmp fin
        numeroTres: ;Si se seleccionó la opción 3
            mov ah,9
            lea dx, nTres
            int 21h
            jmp fin
        numeroCuatro: ;Si se seleccionó la opción 4
            mov ah,9
            lea dx, nCuatro
            int 21h
            jmp fin
        numeroCinco: ;Si se seleccionó la opción 5
            mov ah,9
            lea dx, nCinco
            int 21h
            jmp fin
        ;imprimirTextos inicio,9
        fin:
        .exit
	main endp
end