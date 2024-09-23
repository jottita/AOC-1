		AREA datos,DATA
;TODO EL MOVIEMIENTO(dirx y diry) SE PODRIA HACER CON UNA UNICA VARIABLE PARA CADA JUGADOR CON UN NUMERO DEL 0-3 
;REPRESENTADO CADA UNO UNA DIRECCIÓN{0 =IZQ,1=DER,2=ARRIBA,3=ABAJO POR EJEMPLO}
;NO LO HE HECHO DE ESTA FORMA PORQUE SEGUI EL ESQUEMA QUE SE NOS FACILITA Y
;SE ME OCURRIO CUANDO YA TENÍA GRAN PARTE DEL PROYECYO HECHO PERO CREO QUE SERIA MÁS SENCILLO DE ESA FORMA
reloj 			DCD 	0 			;contador de centesimas de segundo
max 			DCD 	32 			;velocidad de movimiento (en centesimas s.)
velocidad 		DCD		32			; auxilar que cambia la vel
mover			DCD 	0 			;indica si hay que moverse
dir1x 			DCD 	0 			;mov. horizontal jugador1 (-1 izq,0 col fija,1 der) 
dir1y 			DCD		0 			;mov. vertical jugador1 (-1 arriba,0 fila fija,1 abajo)
dir2x 			DCD 	0 			;mov. horizontal jugador2 (-1 izq.,0 col fija,1 der)
dir2y 			DCD 	0 			;mov. vertical jugador2 (-1 arriba,0 fila fija,1 abajo)
fin 			DCB 	0 			;indicador fin de programa (si vale 1)
R_DAT			EQU 	0xE0010000 	;Registro de datos donde se guarda el ascii de la tecla pulsada
T0_IR 			EQU 	0xE0004000	;EOI del timer
ARRIBA 			EQU		0x40007E00  ;Limite por arriba 
ABAJO			EQU		0x40007FFF	;Limite por abajo
VICIntEnable 	EQU 	0xFFFFF010 	;act. Irqs (solo 1’s)
VICIntEnClr 	EQU 	0xFFFFF014 	;desact. IRQs (solo 1’s)
VICVectAddr0 	EQU 	0xFFFFF100 	;vector interr. (VI)
VICVectAddr 	EQU 	0xFFFFF030 	;reg. para EOI
VACIO			EQU		0x20202020
reloj_so		DCD		0			;var. para @RSI_timer_SO 
teclado_so		DCD		0			;var. para @RSI_teclado_SO 
semilla			DCD		0x000000022	;semilla incializada
posicion1		DCD		0			;posicion del personaje 1
posicion2		DCD 	0			;posicion del personaje 2
pos_pos			DCD		0,0,0		; vector de posibles posciones cuando el jugador se encuentra con una colision	
colis			DCD		0			; define si hay una colision
pantalla_fin	DCB		71,65,77,69,32,79,86,69,82,46,32,71,65,78,65,68,79,82,32,74,85,71,65,68,79,82,32 ; mensaje gameover
exit			DCB		83,65,76,73,69,78,68,79,46,46,46; mensaje se pulsa q
;posibles modificaciones para el 10 -> quitar cola,poner pantalla de volver a jugar + poner marcador
		
		
		AREA codigo,CODE
		EXPORT inicio			; forma de enlazar con el startup.s
		IMPORT srand			; para poder invocar SBR srand
		IMPORT rand				; para poder invocar SBR rand
			
		

			LDR r0,=VICVectAddr0 ;salva guarda de la timer del sistema operativo
			LDR r1,=reloj_so
			mov r2,#4
			ldr r3,[r0,r2,LSL #2]
			str r3,[r1]	
			
			LDR r0,=VICVectAddr0 	;salva guarda de la teclado del sistema operativo
			LDR r1,=teclado_so
			mov r2,#7
			ldr r3,[r0,r2,LSL #2]
			str r3,[r1]
			
			
			LDR r1,=RSI_reloj		; programar @IRQ4 -> RSI_reloj
			mov r2,#4
			str r1,[r0,r2,LSL #2]	; Guardamos RSI_reloj en la posición 4 de vector Addr
			LDR r1,=RSI_teclado		; programar @IRQ7 -> RSI_teclado
			mov r2,#7
			str r1,[r0,r2,LSL #2]	; Guardamos RSI_reloj en la posición 7 de vector Addr
			
			LDR r0,=VICIntEnable	; activar IRQ4,IRQ7
			mov r1,#2_10010000
			str r1,[r0]				
			
			LDR r0,=semilla			;  llamanda a srand
			ldr r0,[r0]
			PUSH{r0}
			bl srand
			add sp,sp,#4			
									
									; dibujar pantalla inicial
			bl borra_pant
									; POSICION Y MOVIMIENTO PJ1
			sub sp,sp,#4			; añadimos un hueco para el resultado
			bl rand
			pop{r0}					; r0= numero aleatorio sin limitar
			
			mov r1,#512				
			sub r1,r1,#1			; r1 = 511	
			and r0,r0,r1			; r0 = primero 9 bits del numero aleatorio
			ldr r1,=dir1x			; r1 =@dirx
			ldr r2,=dir1y			; r2 =@diry
			ldr r3,=posicion1		; r3 =@posicion
			mov r4,#'X'				; r4 = X
			
			push{r0,r1,r2,r3,r4}		; pasamos {9 bits,@dirx,@diry,@posicion}
			bl tab_inicial			; subrutina que nos configur la primera posicion y movieminto aleatorio del personaje
			add sp,sp,#16
			

			sub sp,sp,#4			; POSICION Y MOVIMIENTO PJ2
			bl rand
			pop{r0}					; r0= numero aleatorio nuevo sin limitar
									
			mov r1,#512				
			sub r1,r1,#1			; r1= 511
			and r0,r0,r1			; r0 = primero 9 bits del numero aleatorio
			ldr r1,=dir2x			; r1 =@dirx
			ldr r2,=dir2y			; r2 =@diry
			ldr r3,=posicion2		; r3 =@posicion	
			mov r4,#'O'				; r4 = O			
			
			push{r0,r1,r2,r3,r4}	; pasamos {9 bits,@dirx,@diry,@posicion,letra,caracter}
			bl tab_inicial			; subrutina que nos configur la primera posicion y movieminto aleatorio del personaje
			add sp,sp,#16
			
			
					
			LDR r0, =fin			; r0 = @fin
			LDR r1, =mover			; r1 = @mover
			
bucle 		ldr r2,[r0]				;r2 = fin
			cmp r2,#1				; si fin == 1
			beq pulsa_q			; 	salto a desactivar
									; sino
			ldr r2,[r1]				;  	r2 = mover
			cmp r2,#1				; 	si mover != 1
			bne	bucle				; 		salta a bucle
									;	si no:
									
	;MOVIMIENTO DE PERSONAJE 1
			
jugador1	ldr r2, =posicion1		; r2 = @posicion1
			ldr r3, =dir1x			; r3 = @dir1x
			ldr r4, =dir1y			; r4 = @dir1y
			ldr r5, =colis			; r5 = @colis
			ldr r6, =pos_pos		; r6 = @pos_pos
			
			sub sp,sp,#4			; dejamos espacio para el resultado de las subrutina
			push{r2-r6}					; pasamos los parametros//posicion,dirx,diry,colis,pos_pos
			bl movimiento			;
			add sp,sp,#20			; desapilamos los parametro que no nos interesa recuperar
			pop{r7}					; cargamos el resultado en r2
			cmp r7,#1				; si el resultado = 1
			moveq r7,#50				; 	r7 = 2 porque si no encuentra movimiento gana el jugador 2
			beq  gameover			;	fin del prgrama(no hya movimientos posibles)
			
			ldr r7,[r2]
			mov	r8,#'X'			;	pintarlo
			strb r8,[r7]			; 		
			
jugador2	ldr r2, =posicion2		; r2 = @posicion1
			ldr r3, =dir2x			; r3 = @dir1x
			ldr r4, =dir2y			; r4 = @dir1y
			
			sub sp,sp,#4			; dejamos espacio para el resultado de las subrutina
			push{r2-r6}					; pasamos los parametros
			bl movimiento			;
			add sp,sp,#	20			; desapilamos los parametro que no nos interesa recuperar
			pop{r7}					; cargamos el resultado en r2
			cmp r7,#1				; si el resultado = 1
			moveq r7,#49
			beq  gameover			;	fin del prgrama(no hya movimientos posibles)
									; 	r7 = 1 porque si no encuentra movimiento gana el jugador 1
			
			ldr r7,[r2]
			mov	r8,#'O'				;	pintarlo
			strb r8,[r7]			; 			
			
			
			eor r7,r7,r7			; 	r7 = 0
			str r7,[r1]				; 	mover = 0
			
			
			b bucle					
pulsa_q
			
			LDR r0,=ARRIBA		 
			add r0,r0,#162
			ldr r1,=exit
			mov r2,#11
			
			push{r0,r1,r2}
			bl imp_mensaje
			add sp,sp,#12
			b desactivar
								 
gameover	
			
			LDR r0,=ARRIBA		 
			add r0,r0,#162
			ldr r1,=pantalla_fin
			strb r7,[r1,#27]
			mov r2,#28
			
			push{r0,r1,r2}
			bl imp_mensaje
			add sp,sp,#12
			
			
			
desactivar	LDR r0,=VICIntEnClr		;desactivar IRQ4,IRQ7
			mov r1,#2_10010000
			str r1,[r0] 		 
								
			ldr r0,=VICVectAddr0 	; r0 = @VICVectAddr0
			LDR r1,=reloj_so	 	; recuperacion reloj_so; r1 = @reloj_so
			ldr r1,[r1]			 	; r1 = reloj_so
			mov r2,#4			 	; 
			str r1,[r0,r2,LSL#4] 	; VI[4]=@RSI_reloj_SO
			
			LDR r1,=teclado_so	 	; recuperacion reloj_so; r0 = @teclado_so
			ldr r1,[r1]			 	; r1 = teclado_so
			mov r2,#7
			str r1,[r0,r2,LSL#4] 	; VI[7]=@RSI_teclado_SO
								 
bfin b bfin

imp_mensaje	push{lr,fp}
			mov fp,sp
			push{r0-r3}
			
			bl borra_pant		; subrutina para poner la pantalla en blanco
			
			ldr r0,[fp,#8]		; memoria donde empezar mensaje
			ldr r1,[fp,#12]		; primer @ del vectore del mensaje
			ldr r2,[fp,#16]		; tamaño del mensaje

escribir	ldrb r3,[r1],#1		; escribimos bit a bit el mensaje
			strb r3,[r0],#1
			subs r2,r2,#1
			bne escribir
			
			pop{r0-r3,fp,pc}

borra_pant
			push{lr,fp}
			mov fp,sp
			push{r0-r2}
			LDR r0,=ARRIBA
			LDR r1,=VACIO
			mov r2,#128
			
borra		str r1,[r0],#4
			subs r2,r2,#1
			bne borra
			
			pop{r0-r2,fp,pc}
			

tab_inicial
			push{lr,fp}
			mov fp,sp
			push{r0-r4}
			
			ldr r0,[fp,#8]			;r0 = 9 bits
			ldr r1,[fp,#20]			;r1 = posicion
			ldr r2,[fp,#12]			;r2 = dirx
			
			mov r3,#127
			cmp r0,r3				; 0-127 = izq,128-255 = dch,255-383 = arriba,384-511 = abajo
			movle r4,#-1			; si r0 <= 127 --> 4 = -1
			ble mov_ini
			
			add r3,#128
			cmp r0,r3
			movle r4,#1				; si r10 <=255  --> r4 =  1
			ble mov_ini
			
			ldr r2,[fp,#16]			;r2 = @diry
			
			add r3,#128
			cmp r0,r3
			movle r4,#-32			; si r0 <= 383 --> r4 = -32
			ble mov_ini
			
			add r3,#128
			cmp r0,r3				; 					
			movle r4,#32				; si r0 <= 511 --> r4 =  31	
			
mov_ini		str r4,[r2]				; dir en r2 = r4
			
			LDR r2,=ARRIBA			; r2 = @ARRIBA; al ser una constante "global" no la paso por parametro	
			add r0,r2,r0			; r0 = limite de arriba del vector + r0(primeros 9 bit)= posicion elegida definitiva
			str r0,[r1]				; posicion = r0(posicion elegida definitiva)
			ldr r2,[fp,#24]			; r2 = 'X'
			strb r2,[r0]			; r2 se almacena/dibuja en r0
			pop{r0-r4,fp,pc}





movimiento 	push{lr,fp}
			mov fp,sp
			push{r0-r10}
			ldr r0,[fp,#8]			; r0 = @posicion
			ldr r1,[fp,#12]			; r1 = @dirx
			ldr r2,[fp,#16]			; r2 = @diry
			ldr r3,[fp,#20]			; r3 = @colis
			ldr r4,[fp,#24]			; r4 = @pos_pos
			eor r10,r10,r10			; r10 = 0 [será donde almacenamos si es game over para pasarlo al final como resultado de la subrutina]
									
									; realmente podrias pasar como parametro @fin, con un store modificarlo directamente y
									; hacer que la subrutina no tuviese resultado, pero al final 
									; se usan los mismos registros asi que me queda con esta porque era la que ya tenia implementada.
						
			ldr r5,[r0]				; r5 = posicion1
			ldr r6,[r1]				; r6 = dir1x
			cmp r6,#0				;
			bmi izq					; si r6 < 0 --> salto a izq
			bgt dch					; si r6 > 0 -->  salto a dch
			
			ldr r6,[r2]				; r6 = dir1y
			cmp r6,#0				; si r6 == 0
			blt arriba				; si r6 < 0 --> salto a arriba
			bgt abajo				; si r6 > 0 -->  salto a abajo
									; si ninguno de los dos salta significa que no se ha escogido tecla
			mov r6,r5				
				
			b fin_mov				;seguir direccion anterior
									; r5 = posicion1
izq								
			sub r6,r5,#1			; r6 = r5 - 1(dir1x)
			and r7, r6, #31			; r7 = r6(posible posicion final) and 31(numero de columnas)
			cmp r7,#31				; si r7 == 31
			addeq r6,r5,#31			; 	r6 = r5(pos inicial) - 31(una fila entera)
			ldr r7,[r3]				; r7 = colis
			cmp r7,#1
			beq col_izq
			b colision
			
dch			add r6,r5,#1			; r6 = r5 + 1(dir1x)
			and r7,r6,#31			; r7 = r6(posible posicion final) and 31(numero de columnas
			cmp r7,#0				; si r7 == 0
			subeq r6,r5,#31			; 	r6 = r5(pos inicial) - 31(una fila entera) 
			ldr r7,[r3]				; r7 = colis
			cmp r7,#1
			beq col_dch
			b colision

arriba		
			sub r6,r5,#32			; r6 = r5 - 32(dir1y)
			ldr r7,=ARRIBA			; si no: r7 = @ARRIBA
			cmp r7,r6				; si r7 > r6
			addhi r6,r6,#512		; 	r8 = r8 + 512(un tablero entero)
			ldr r7,[r3]				; r7 = colis
			cmp r7,#1
			beq col_ar
			b colision

abajo		add r6,r5,#32			;r6 = r5 + 32(dir1y)
			ldr r7,=ABAJO			; si no: r7 = @ABAJO
			cmp r6,r7				; si r6 > r7
			subhi r6,r6,#512		; 	r6 = r6 - 512(un tablero entero)
			ldr r7,[r3]				; r7 = colis
			cmp r7,#1
			beq col_ab
			
							
			
			
colision	
			
			ldrb r7,[r6]			; r7 = ascii que hay en r6(posible posicion final )
			cmp r7,#32				; si r7 != 32(space en ascii)
			beq fin_mov				;	hay colision
			
			mov r7,#1				;
			str r7,[r3]				; colis = 1		
			eor r8,r8,r8			; r8 = 0
			mov r9,r4				; r9 = @pos_pos; hacemos esto porque vamos a modificar la @ en r9 pero necesitamos la principal r4 intacta
			
			;ARRIBA		
 			b arriba
col_ar		ldrb r7,[r6]			; r7 = r6(el ascii)
			cmp r7,#32				; si r7 == 32
			addeq r8,r8,#1			; 	r8++
			streq r6,[r9],#4		;   pos_pos + posiciones @ = r6
			
			;ABAJO
			b abajo
col_ab		ldrb r7,[r6]			; r7 = r6(el ascii)
			cmp r7,#32				; si r7 == 32
			addeq r8,r8,#1			; 	r8++
			streq r6,[r9],#4		;   pos_pos + posiciones @ = r6
			
			;IZQUIERDA
			b izq
col_izq		ldrb r7,[r6]			; r7 = r6(el ascii)
			cmp r7,#32				; si r7 == 32
			addeq r8,r8,#1			; 	r8++
			streq r6,[r9],#4		;   pos_pos + posiciones @ = r6
			
			;DERECHA
			b dch
col_dch		ldrb r7,[r6]			; r7 = r6(el ascii)
			cmp r7,#32				; si r7 == 32
			addeq r8,r8,#1			; 	r8++
			streq r6,[r9],#4		;   pos_pos + posiciones @ = r6
			
			cmp r8,#1
			moveq r6,#0
			beq unico
			movlt r10,#1
			strlt r10,[fp,#28]		; cargas si es game over en el resultado 
			blt fin_mov				; fin del juego, hay un ganador;METERLE RESULTADO
			
			sub sp,sp,#4			; añadimos un hueco para el resultado
			bl rand
			pop{r7}					; r7 = numero aleatorio
			and r6, r7,#1			; r6  r7 and 1 para coger un bit
			
unico		
			ldr r6,[r4,r6,LSL#2]	; r6 = r4[r6] = a la posicion guardad en streq
			mov r8,#0				; r8 = 0
			str r8,[r3]				; colis = r8
			
			mov r7,#0
			sub r7,r6,r5			; r7 = posicion corregida - posicion inicial = {1,-1,32,-32}
			cmp r7,#1				; si r7 >= 1 solo puede ser abajo o derecha
			streq r7,[r1]			; posicionx = r7			
			streq r8,[r2]			; posiciony = 0
			strgt r7,[r2]			; posiciony = r7
			strgt r8,[r1]			; posicionx = 0
			cmp r7,#-1				; si r7 <= -1 solo puede ser arriba o izquierda
			streq r7,[r1]			; posicionx = r7			
			streq r8,[r2]			; posiciony = 0
			strlt r7,[r2]			; posiciony = r7
			strlt r8,[r1]			; posicionx = 0		
			
			
fin_mov		cmp r10,#1				; si no es gameover r8 != 1
			strne r6,[r0]			; 		posicion = r6
			pop{r0-r10,fp,pc}				



RSI_reloj ;Rutina de servicio a la interrupcion IRQ4 (timer 0)
			;Cada 0,01 s. llega una peticion de interrupcion
			;usada la rsi timer de las notas de apoyo como referencia
			
			sub lr,lr,#4		;prologo
			PUSH {lr}
			mrs r14,spsr
			PUSH {r14}
			msr cpsr_c,#2_01010010
			
			PUSH {r0-r3} 
			
			LDR r0,=T0_IR		;EOI: escribir un 1 en el registro T0_IR
			mov r1,#1
			str r1,[r0] 
			
			ldr r0,=reloj		; r0 = @reloj
			ldr r1,[r0]			; r1 = reloj
			add r1,r1,#1		; r1++
			ldr r2,= max		; r2 = @max
			ldr r3,[r2]			; r3 = max
			cmp r1,r3			; si r1(reloj) == r3(max)
			bne fin_reloj
			ldr r1,=velocidad	; r1 = @veolcidad
			ldr r1,[r1]			; r1 = velocidad
			cmp r1,r3			; si r1 != r2
			strne r1,[r2]		; 	max = velocidad 
			
			
			mov r1,#1			; r2 = 1
			ldr r3,=mover		; 	r3 = @mover
			str r1,[r3]			;	mover = r1 = 1
			mov r1,#0

fin_reloj	str r1,[r0]			; reloj = r1
			
			POP {r0-r3} 
								;epilogo
			msr cpsr_c,#2_11010010
			POP {r14}
			msr spsr_fsxc,r14
			LDR r14,=VICVectAddr
			str r14,[r14]
			POP {pc}^ 					
			
								
RSI_teclado ;Rutina de servicio a la interrupcion IRQ7 (teclado)
			;al pulsar cada tecla llega peticion de interrupcion IRQ7
			;usada la rsi teclado de las notas de apoyo como referencia
			
			sub lr,lr,#4		;prologo
			PUSH {lr}
			mrs r14,spsr
			PUSH {r14}
			msr cpsr_c,#2_01010010
			PUSH {r0-r4}

			LDR r1,=R_DAT		;r1=@R_DATOS teclado
			ldrb r0,[r1]		;r0=codigo ASCII tecla, al leer se completa el EOI
			
			LDR r1,= velocidad	; r1 = @velocidad
			ldr r2,[r1]			; r2 = velocidad
			cmp r2,#1			; si r2 == 1
			beq max_vel				; 	solo puede ir mas lento, se ha alcanzado el maximo de velocidad
			cmp r0,#'+'			; si r0 == 43 = '+'	
			moveq r2,r2,lsr#1	; 	r2 = r2/2 para que se haga un movimiento cada menos decimas, disminuimos el numero de ticks necesarios para moverse
			cmp r2 ,#128		; si r2 == 128
			beq act				; 	solo puede ir más rápido, se ha alcanzado el minimo de velocidad
max_vel		cmp r0,#'-'			; si r0 == 45 = '-'
			moveq r2,r2,lsl#1	; 	r2 = r2*2 para que se haga un movimiento cada más decimas, aumentamos el numero de ticks necesarios para moverse
			
act			str r2,[r1]			; max = r2
			
			
								; Tratamiento: paso a mayusculas 
			bic r0,r0,#2_100000	; r1 = r0 and not(00100000) [importante --> r0 mantiene ascii original de la tecla pulsada]
			cmp r0,#81			; si r1 == 81 = Q
			bne sigue
								
			LDR r1,=fin			; 	r1 = @fin
			mov r0,#1			;	r0 = 1
			str r0,[r1]			; 	fin = r0 = 1
			b epilogo           ; 	salta al epilogo
		   
								;
sigue       					
			
			cmp r0,#'I'			; si r0 < I
			blt p1x				;	salta al movimiento en x del p1
			cmp r0,#'L'			; si r0 > L
			bgt p1y				; 	salta al movimiento en y del p1
								; movimiento p2
			ldr r1,=dir2x		; r1 = @dir2x [ya no necestimos el ascii orginal asi que podemos reescrbir]
			ldr r2,=dir2y		; r2 = @dir2y
								; si r0 == 11(L)(usamos las flags de la ultima comparación)
			moveq r3,#1			; 	r3 = 1(derecha)
			moveq r4,#0			; 	r4 = 0
			cmp r0,#'K'			; si r0 == K-> r3 = 0
			moveq r3,#0			;   r3 = 0
			moveq r4,#1			; 	r4 = 1(abajo)			
			cmp r0,#'J'			; si r0 == 9(J) 
			moveq r3,#-1		;   r3 = -1(izq)
			moveq r4,#0			; 	r4 = 0
			cmp r0,#'I'			; si r0 == 8(I)-> r3 = 0
			moveq r3,#0			;   r3 = 0
			moveq r4,#-1		; 	r4 = -1(arriba)
			
			b act_dir			; salto a actualizar direcciones

p1x			ldr r1,=dir1x		; r0 = @dir2x [ya no necestimos el ascii orginal asi que podemos reescrbir en r0]
			ldr r2,=dir1y		; r2 = @dir2y	
			mov r4,#0			; r4 = 0 porque dir1y siempre va a ser 0
			
			cmp r0,#'A'			; si r1 == 0(A)
			moveq r3,#-1		; 	r3 = -1(izquierda)
			cmp r0,#'D'			; si r1 == 3(D)
			moveq r3,#1			;  	r3 = 1 (derecha)
			b act_dir			; salto a actualizar direcciones

p1y			ldr r1,=dir1x		; r1 = @dir2x [ya no necestimos el ascii orginal asi que podemos reescrbir en r0]
			ldr r2,=dir1y		; r2 = @dir2y
			mov r3,#0			; r3 = 0 porque dir1x siempre va a ser 0
			
			cmp r0,#'W'			; si r1 == 22(W)
			moveq r4,#-1		; 	r4 = -1(arriba)
			cmp r0,#'S' 			; si r1 == 18(S)
			moveq r4,#1			;  	r4 = 1 (abajo)

act_dir		str r3,[r1]			; dir1x/dir2x = r3
			str r4,[r2]			; dir1y/dir2y = r4
 
epilogo     POP {r0-r4}
			
			msr cpsr_c,#2_11010010
			POP {r14}
			msr spsr_fsxc,r14
			LDR r14,=VICVectAddr
			str r14,[r14]
			POP {pc}^


						


		END
