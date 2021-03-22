imprimirArchivo macro direccion
        XOR ax, ax
        XOR dx, dx
		mov ah, 09h  
	    mov dx, offset direccion
	    int 21h
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

;ruta del archivo temporal y su manejador
ruta db "texto.txt",0  
manejador dw 0


;otras cadenas y variables
msjError db 0ah,0dh, 'Hubo un error en la lectura del archivo.', '$'
archivoLeido db 0ah,0dh, 'Archivo leido correctamente.', '$'
rutaPorTeclado dw 30 dup("$")
lectura db 60 dup("$")
instruccion db 60 dup("$")
letra db ?,"$"
saltoLinea db 0ah, 0dh, "$"
escribir db ';','$'
contadorOp db 0
contadorNum db 0
comparar db 'div','$'
suma db 'sum', '$'
noes db 0ah, 0dh,'No son iguales', '$'

;db -> dato byte -> 8 bits
;dw -> dato word -> 16 bits
;dd -> doble word -> 32 bits
.code ;segmento de código
org 100h
;================== SEGMENTO DE CODIGO ===========================
	main proc
        ;======================CARGA DE DATOS AL DS===========================
        MOV AX, @data
        MOV DS, AX
        ;=================================================================
		mov si, offset comparar
		mov di, offset suma
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
			imprimirArchivo noes
		fin:
            
        .exit
	main endp
end