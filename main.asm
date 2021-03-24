;include proced.asm

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
nUno db 0ah,0dh, 'Ingrese la ruta del archivo a leer','$'
nDos db 0ah,0dh, 'Se ha seleccionado el numero 2','$'
nTres db 0ah,0dh, 'Se ha seleccionado el numero 3','$'
nCuatro db 0ah,0dh, 'Se ha seleccionado el numero 4','$'
nCinco db 0ah,0dh, 'Enter para salir del programa','$'
nNoExiste db 0ah, 0dh, 'Opcion no disponible, seleccione otra','$'
;ruta del archivo temporal y su manejador
ruta db "texto.txt",0  
manejador dw 0


;otras cadenas y variables
msjError db 0ah,0dh, 'Hubo un error en la lectura del archivo.', '$'
archivoLeido db 0ah,0dh, 'Archivo leido correctamente.', '$'
rutaPorTeclado dw 30 dup("$")
lectura db 60 dup("$")
instruccion db 10000 dup("$")
letra db ?,"$"
saltoLinea db 0ah, 0dh, "$"
escribir db ';','$'
contadorOp db 0
contadorNum dw 0
numeros dw 6000 dup(0)

;comparadores de instrucciones

sum_a db 'sum','$'
res_a db 'res','$'
mul_a db 'mul','$'
div_a db 'div','$'
sum_c db '/sum','$'
res_c db '/res','$'
mul_c db '/mul','$'
div_c db '/div','$'
op_a db 'operacion','$'
op_c db '/operacion', '$'
val_a db 'valor', '$'
val_c db '/valor', '$'
padre_a db 'operaciones','$'
padre_c db '/operaciones','$'

;elementos de hora y fecha

hora db 30 dup("$") ;hora::minuto:segundo
fecha db 30 dup("$") ;DD/MM/YYYY


;elementos html
htmlTitulo dw '','$'
htmlDato1 dw '<h1>Practica 3 Arqui 1 Seccion A </h1>','$'
htmlDato2 dw '<p><b>Estudiante: </b> Joel Rodriguez Santos</p>','$'
htmlDato3 dw '<p><b>Carnet: </b> 201115018</p>','$'
htmlFecha db '<p><b>Fecha:</b>','$'
htmlsignC db '</p>','$'
htmlHora db '<p><b>Hora:</b>','$'
htmlInicio dw '<html><head><title>resultados</title>','$'
cierreHead dw '</head>','$'
htmlBody dw '<body><p>','$'
htmlCierre dw '</p></body></html>','$'
htmlStyle dw '<style>table, th, td {border: 1px solid black;}</style>','$'
;elementos para crear archivo
nombreSalida db "res.html",0   
manejadorSalida dw ?
errorCreacion db 'Error al crear el archivo','$'
ingreseNumero db 'Ingrese un numero','$'
operaciones db 0dh,0ah,'Operaciones:','$'
resultado db 0dh,0ah,'El resultado es:', '$'
numPorTeclado db 5 dup("$") 
numeroUni dw 4 dup(0)
opFactorial db 300 dup("$")
resultNum db 10 dup("$")
htmlCreado db 0dh,0ah,'Html creado.','$'

;db -> dato byte -> 8 bits
;dw -> dato word -> 16 bits
;dd -> doble word -> 32 bits
.code ;segmento de código
;org 100h
;================== SEGMENTO DE CODIGO ===========================
	main proc
        ;======================CARGA DE DATOS AL DS===========================
        MOV AX, @data
        MOV DS, AX
        ;=================================================================
        cls
        imprimirTextos inicio,9
        enter

        menuPrincipal:
            cls
            imprimirTextos menu,8
            imprimirArchivo saltoLinea
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
                je numeroCinco
                jne noDisponible

            numeroUno: ;Si se seleccionó la opción 1
                ;mov ah,9
                ;lea dx, nUno
                ;int 21h
                cls
                imprimirArchivo saltoLinea
                pedirPorTeclado rutaPorTeclado;Pedir la ruta por teclado
                abrirArchivo rutaPorTeclado,manejador ;Abrir archivo
                jc errorApertura ; Verificar si existe un error
                escribirFin manejador, escribir ;Escribir el EOF al archivo de entrada
                cerrarArchivo manejador ;Cerrar el archivo

                abrirArchivo rutaPorTeclado,manejador ;Abrir archivo
                jc errorApertura ; Verificar si existe un error
                leerArchivo lectura, manejador, letra, instruccion, contadorOp, sum_a,sum_c,res_a,res_c,mul_a,mul_c,div_a,div_c,val_a,val_c,op_a,op_c, numeros, contadorNum,saltoLinea,padre_a,padre_c
                cerrarArchivo manejador ;Cerrar el archivo
                ;imprimirArchivo lectura
                enter
                jmp menuPrincipal

                errorApertura: ;Imprimir el error y terminar
                    imprimirArchivo msjError ;Imprimir msj de error
                    enter
                    ;cerrarArchivo manejador  ;Cerrar el archivo
                    jmp menuPrincipal ;Saltar al final del programa

                jmp menuPrincipal
            numeroDos: ;Si se seleccionó la opción 2
                cls
                mov ah,9
                lea dx, nDos
                int 21h
                enter
                jmp menuPrincipal
            numeroTres: ;Si se seleccionó la opción 3
                ;mov ah,9
                ;lea dx, nTres
                ;int 21h
                cls
                factorial ingreseNumero,operaciones,resultado,numPorTeclado,numeroUni,opFactorial,saltoLinea,resultNum
                enter
                jmp menuPrincipal
            numeroCuatro: ;Si se seleccionó la opción 4
                ;mov ah,9
                ;lea dx, nCuatro
                ;int 21h
                pop si
                cls
                cerrarTabla
                getHora hora
                getFecha fecha
                crearHtml nombreSalida,manejadorSalida,errorCreacion
                writeHtml manejadorSalida,errorCreacion,htmlInicio 
                writeHtml manejadorSalida,errorCreacion,htmlStyle
                writeHtml manejadorSalida,errorCreacion,cierreHead
                writeHtml manejadorSalida,errorCreacion,htmlBody
                writeHtml manejadorSalida,errorCreacion,htmlDato1
                writeHtml manejadorSalida,errorCreacion,htmlDato2
                writeHtml manejadorSalida,errorCreacion,htmlDato3
                writeHtml manejadorSalida,errorCreacion,htmlHora              
                writeHtml manejadorSalida,errorCreacion,hora
                writeHtml manejadorSalida,errorCreacion,htmlsignC
                writeHtml manejadorSalida,errorCreacion,htmlFecha             
                writeHtml manejadorSalida,errorCreacion,fecha
                writeHtml manejadorSalida,errorCreacion,htmlsignC
                writeHtml manejadorSalida,errorCreacion,instruccion
                writeHtml manejadorSalida,errorCreacion,htmlCierre
                cerrarArchivo manejadorSalida
                imprimirArchivo htmlCreado
                imprimirArchivo saltoLinea
                limpiarLector instruccion,10000
                enter
                jmp menuPrincipal
            numeroCinco: ;Si se seleccionó la opción 5, entonces es salida
                cls
                mov ah,9
                lea dx, nCinco
                int 21h
                enter
                jmp fin
            ;imprimirTextos inicio,9
            noDisponible:
                cls
                imprimirArchivo nNoExiste
                imprimirArchivo saltoLinea
                enter
                jmp leer


        fin:
            
        .exit
	main endp
end