.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros				@Ejercicio 1
.global asm_productoEscalar32	@Ejercicio 2
.global asm_productoEscalar16	@Ejercicio 3
.global asm_productoEscalar12	@Ejercicio 4

.global asm_pack32to16			@Ejercicio 6
.global asm_max					@Ejercicio 7
.global asm_downsampleM			@Ejercicio 8
.global asm_invertir			@Ejercicio 9
.global asm_eco					@Ejercicio 10

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 1:
@   void asm_zeros (uint32_t * vector, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector
@   r1: longitud
.thumb_func               @ Se avisa al emsablador que esta es una funcion
    asm_zeros:            @ Etiqueta/nombre de la función.
        mov r2, 0         @ r2 = 0
        asm_zeros_bucle:  @ Etiqueta de comienzo de bucle.
    str r2, [r0]          @ Asigna 0 a la palabra en dirección r0.
    add r0, 4             @ Pasa a la siguiente palabra/elemento en vector.
    subs r1, 1            @ Resta 1 a la cantidad de elementos y actualiza flags de estado del procesador. En particular, estamos interesados en el flag Z.
    bne asm_zeros_bucle   @ La instrucción se ejecuta mientras el resultado de r1 - 1 no sea cero (Z == 0).
    bx lr                 @ La instrucción de salto no se ejecutó porque Z == 1, volvemos a quién nos llamó.


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 2:
@   void asm_productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector de entrada
@   r1: dirección de memoria de inicio del vector de salida
@   r2: longitud
@   r3: escalar por el que multiplicar el vector
.thumb_func               		  @ Se avisa al emsablador que esta es una funcion
    asm_productoEscalar32:        @ Etiqueta/nombre de la función.
    	push {r4-r6}
    	asm_productoEscalar32_loop:
        	ldr r4, [r0]          @ r4 = *r0; @ Muevo a r4 el valor al que apunta r0
			mov r5, r3	          @ r5 = r3;  @ r5 es una copia del escalar
			mov r6, 0	          @ r6 = 0;
			asm_product_32:	      @ Etiqueta donde comienza el bucle para multiplicar escalar por elemento de vector
	    		adds r6, r6, r4   @ r6+=r4;
	    		subs r5, 1	      @ r5--;
	    		bne asm_product_32@ Regreso a asm_product si r5 no llegó a cero. Si llegó a cero "r6 = r4 * r3;"
			str r6, [r1]	      @ Guardo r6 en la dirección a la que apunta r1
			add r0, 4	  		  @  Pasa al siguiente elemento del vector de entrada. Mueve 4 bytes.
			add r1, 4	          @  Pasa al siguiente elemento del vector de salida. Mueve 4 bytes.
			subs r2, 1	          @ Resta 1 a la cantidad de elementos del vector.
			bne asm_productoEscalar32_loop         @ Va a la siguiente multiplicación. Salta si r2 llegó a cero.
    	pop {r4-r6}
    	bx lr		          	  @ Vuelve a la llamada de la función


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 3:
@   void asm_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector de entrada
@   r1: dirección de memoria de inicio del vector de salida
@   r2: longitud
@   r3: escalar por el que multiplicar el vector
.thumb_func               	      @ Se avisa al emsablador que esta es una funcion
    asm_productoEscalar16:        @ Etiqueta/nombre de la función.
    	push {r4-r6}
    	asm_productoEscalar16_loop:
        	ldrh r4, [r0]      	  @ r4 = *r0; @ Muevo a r4 el valor al que apunta r0. El sufijo "h" lee media palabra.
			mov r5, r3	          @ r5 = r3;  @ r5 es una copia del escalar
			mov r6, 0	          @ r6 = 0;
			asm_product_16:	      @ Etiqueta donde comienza el bucle para multiplicar escalar por elemento de vector
	    		adds r6, r6, r4   @ r6+=r4;
	    		subs r5, 1	      @ r5--;
	    		bne asm_product_16			  @ Regreso a asm_product si r5 no llegó a cero. Si llegó a cero "r6 = r4 * r3;"
			strh r6, [r1]	      @ Guardo r6 en la dirección a la que apunta r1. El sufijo "h" escribe media palabra.
			add r0, 2	          @ Pasa al siguiente elemento del vector de entrada. Mueve 2 bytes.
			add r1, 2	          @ Pasa al siguiente elemento del vector de salida. Mueve 2 bytes.
			subs r2, 1	          @ Resta 1 a la cantidad de elementos del vector.
			bne asm_productoEscalar16_loop    @ Va a la siguiente multiplicación. Salta si r2 llegó a cero.
    		pop {r4-r6}
    		bx lr		          @ Vuelve a la llamada de la función





@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 4:
@   void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector de entrada
@   r1: dirección de memoria de inicio del vector de salida
@   r2: longitud
@   r3: escalar por el que multiplicar el vector
.thumb_func               			  	@ Se avisa al emsablador que esta es una funcion
	asm_productoEscalar12:			  	@ Se avisa al emsablador que esta es una funcion
		push {r4-r6}
		asm_productoEscalar12_loop:
        	ldrh r4, [r0]      	  		@ r4 = *r0; @ Muevo a r4 el valor al que apunta r0. El sufijo "h" lee media palabra.
			mov r5, r3	          		@ r5 = r3;  @ r5 es una copia del escalar
			mov r6, 0	          		@ r6 = 0;
			asm_product_12:	      		@ Etiqueta donde comienza el bucle para multiplicar escalar por elemento de vector
	    		adds r6, r6, r4   		@ r6+=r4;
	    		subs r5, 1	      		@ r5--;
	    		bne asm_product_16		@ Regreso a asm_product si r5 no llegó a cero. Si llegó a cero "r6 = r4 * r3;"
		usat r6, 12, r6					@Satura el resultado a 12 bits
		strh r6, [r1]	      			@ Guardo r6 en la dirección a la que apunta r1. El sufijo "h" escribe media palabra.
		add r0, 2	          			@ Pasa al siguiente elemento del vector de entrada. Mueve 2 bytes.
		add r1, 2	         			@ Pasa al siguiente elemento del vector de salida. Mueve 2 bytes.
		subs r2, 1	          			@ Resta 1 a la cantidad de elementos del vector.
		bne asm_productoEscalar16_loop  @ Va a la siguiente multiplicación. Salta si r2 llegó a cero.
    	pop {r4-r6}
    	bx lr		          			@ Vuelve a la llamada de la función




@---------------------------------- EJERCICIO 5 -------------------------






@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 6:
@   void asm_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector de entrada
@   r1: dirección de memoria de inicio del vector de salida
@   r2: longitud
.thumb_func
	asm_pack32to16:					@ Nombre de la función
		asm_pack32to16_loop:		@ Inicio de bucle
			ldr r3,[r0],#4			@ Carga el valor al que apunta r0 en r3 y mueve 4 bytes r0
			lsr r3,16				@ Hace desplazamiento de 16 bits a derecha
			strh r3,[r1],#2			@ Guarda r3 en la dirección donde apunta r1 y le suma 2 a r1
			subs r2,1				@ r2--; y actualiza los flags
			bne asm_pack32to16_loop	@ Se mantiene dentro del loop mientras Z!=0
		bx lr						@ Regresa a donde se llamo la función



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 7:
@   int32_t asm_max (int32_t * vectorIn, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector
@   r1: longitud
@ Parámetro regresado:
@   r0: posición del valor máximo del vector
@ Usos de registros:
@   r2: valor máximo encontrado
@   r3: posición del valor máximo encontrado
@   r4: valor a comparar
@   r5: posición actual
.thumb_func               		@ Se avisa al emsablador que esta es una funcion
    asm_max:            		@ Etiqueta/nombre de la función.
	push {r4-r5}				@ Guarda los registros r4 y r5 en el stack
	ldr r2,[r0]					@ Carga el valor de la posición 0 del vector en r2
	mov r3,#0					@ Posición del valor máximo encontrado = 0
	mov r5,#0					@ Posición actual = 0
	asm_max_loop:
	    add r0,#4				@ Mueve a la siguiente posición del vector
	    add r5,#1				@ Posición actual +=1
	    ldr r4,[r0]				@ Carga el valor de la posición actual del vector para comparar
	    cmp r4,r2				@ Comparo posición actual con máximo valor encontrado
	    itt hs					@ Si posición actual es mayor a máximo valor encontrado ejecutar las siguientes dos condiciones
	    	movhs r2,r4			@ Actualiza el máximo valor encotnrado
			movhs r3,r5			@ Actualiza la posición del máximo valor encontrado
		subs r1,#1				@ longitud -=1
		bne asm_max_loop
	mov r0,r3					@ Devolver la posición del máximo del vector
	pop {r4-r5}					@ Recuperar los registros guardados en el stack
	bx lr						@ Vuelve a la llamada de la función


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 8:
@   void asm_downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector de entrada
@   r1: dirección de memoria de inicio del vector de salida
@   r2: longitud
@   r3: "N". Se debe descartar uno de cada N valores del vector
@ Usos de registros:
@   r4: contador N
@	r5: valor actual del vector
.thumb_func
	asm_downsampleM:
	push {r4-r5}					@ Guarda en el stack el valor de r4 y r5
	mov r4,r3						@ contador = N
	asm_downsampleM_loop:			@ Loop
		ldr r5,[r0]					@ Carga el valor actual del array
		subs r4,#1					@ contador--;
		itte ne						@ if(contador!=0) {
			strne r5,[r1]				@ Guarda el valor actual del array en el vector de salida
			addne r1,#4					@ Siguiente dirección del vector de salida
			moveq r4,r3				@ } else {contador = N;}
		add r0,#4					@ Siguiente dirección del vector de entrada
		subs r2,#1					@ longitud--;
		bne asm_downsampleM_loop	@ End Loop
	pop {r4-r5}						@ Recupera del stack el valor de r4 y r5
	bx lr							@ Vuelve a la llamada de la función


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 9:
@   void asm_invertir (uint16_t * vector, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector
@   r1: longitud
@ Usos de registros:
@   r2: valor actual del vector
@   r3: copia de la longitud
@	r4: copia de la dirección donde comienza el vector
.thumb_func
	asm_invertir:
	push {r4}						@ Guarda en la pila el valor de r4
	mov r3,r1						@ Copia en r3 el largo del vector
	mov r4,r0						@ Hace una copia en r4 de la dirección del vector
	asm_invertir_loop_push:			@ Loop_push @ Nota: guarda en la pila el vector
		ldrh r2,[r0]				@ Guardo en r2 el valor actual del vector
		add r0,#2					@ Siguiente posición del vector
		push {r2}					@ Muevo el valor del vector a la cola
		subs r3,#1					@ longitud--;
		bne asm_invertir_loop_push	@ End Loop_push
	asm_invertir_loop_pop:
		pop {r2}					@ Recupero el valor a insertar en el vector
		strh r2,[r4]				@ Guardo el valor recuperado en el vector
		add r4,#2					@ Siguiente posición del vector
		subs r1,#1					@ longitud--;
		bne asm_invertir_loop_pop	@ End Loop_pop
	pop {r4}						@ Recupera de la pila el valor de r4
	bx lr							@ Vuelve a la llamada de la función



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 10:
@   void eco(uint32_t * vector, uint32_t longitud, uint32_t offset)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector
@   r1: longitud
@	r2: offset
@ Usos de registros:
@   r3: valor actual del vector
@   r4: copia de la longitud. En "asm_pop_eco_loop" guarda el valor del eco
@	r5: copia de la dirección donde comienza el vector
.thumb_func
	asm_eco:
	push {r4-r5}					@ Guarda en la pila el valor de r4 y r5
	mov r4,r1						@ Copia en r4 el largo del vector
	mov r5,r0						@ Hace una copia en r5 de la dirección del vector
	asm_push_eco_loop:				@ Loop_eco_push
		ldr r3,[r0],#4				@ Guardo en r2 el valor del vector y muevo a la siguiente posición del vector
		lsr r3,#1					@ Divide el valor del vector por 2
		push {r3}					@ Guardo el valor del eco en la pila
		sub r4,#1					@ longitud--;
		cmp r4,r2					@ Comparar la longitud que queda del vector con el offset
		bne asm_push_eco_loop		@ End Loop_eco_push
	asm_goto_end_vector_loop:		@ Loop para ir a la última posición del array +1
		add r0,#4					@ Avanza un lugar en la posición del vector
		subs r4,#1					@ Avanza hasta llegar al final del vector. Resta 1 a la longitud
		bne asm_goto_end_vector_loop
	sub r1,r2						@ longitud -= offset;
	asm_pop_eco_loop:				@ Loop para agregar eco a la señal
		pop {r4}					@ Recupera el valor del último eco
		sub r0,#4					@ Vuelve una posición para atrás en el vector
		ldr r3,[r0]					@ Toma el valor de la posición actual del vector
		add r3,r4					@ Suma al valor de l a posición actual el eco
		str r3,[r0]					@ Guarda en el vector el nuevo valor con el eco
		subs r1,#1					@ longitud--;
		bne asm_pop_eco_loop
	pop {r4-r5}						@ Recupera de la pila el valor de r4 y r5
	bx lr							@ Vuelve a la llamada de la función


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C" ejercicio 10 con SIMD:
@   void eco(uint32_t * vector, uint32_t longitud, uint32_t offset)
@
@ Parametros recibidos:
@   r0: dirección de memoria de inicio del vector
@   r1: longitud
@	r2: offset







