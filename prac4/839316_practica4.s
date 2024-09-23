
   	AREA codigo,CODE					; area de codigo
									
	EXPORT ordena

ordena		
		push{lr}
		mov r2,r0						; r2 = @T 
		mov r3,#0						; r3 = 0 = izq	
		sub r4,r1,#1					; r4 = n-1 = dch
		
		PUSH {r2,r3,r4}					; empujamos t,izq,dch			
		bl qksort
		add sp,sp,#12					; liberamos las 3 posiciones que hemos pusheado
		pop{pc}				
		
       
fin 	b fin							
							
			
qksort 	push{fp,lr}
		mov fp,sp
		push{r0-r8}
										
		ldr r0,[fp,#8] 					; r0 = @T
		ldr r1,[fp,#12]					; r1 = izq = i
		ldr r2,[fp,#16]					; r2 = dch = j
		add r3, r2,r1 					; r3 = r2+r1 
		mov r3, r3,LSR#1				; r3 = r3/2
		ldr r4,[r0,r3,LSL#2]			; r4 = x = T[(iz+de)/2]
		mov r7,r1						; r7 = izq
		mov r8,r2						; r8 = dch
						
while 	ldr r5,[r0,r1,lsl#2]			; r5 = T[i] 
		cmp r5,r4						; si T[i] >= x saltamos a while2
		bge while2
		add r1,r1,#1					; i++
		b while

while2	ldr r6,[r0,r2,lsl#2]			; r6 = T[j] 
		cmp r4,r6						; si x(r4) >= T[j](r6) salto a si
		bge si							; 	sino
		sub r2,r2,#1					; j--
		b while2

si		cmp r1,r2						; si r1 > r2 saltar a do
		bgt do							;	sino
		str r6,[r0,r1,lsl#2]			; r6 = T[j] --> T[i]
		str r5,[r0,r2,lsl#2]			; r5 = T[i] --> T[j]
		add r1,r1,#1					; i=i+1
		sub r2,r2,#1					; j=j-1; 

do		cmp r1,r2						; si r1 <= r2 salto a while
		ble while

rcrsv									; r7 = izq
		cmp r7,r2						; si iz >= j saltas a rcrsv2
		bge rcrsv2
		push {r2}
		push {r0,r7}					; pasamos parametros por pila
		bl qksort						
		add sp, sp,#12					; sacamos los parametros de la pila
		
rcrsv2					 				; r8 = dch 
 		cmp r1,r8						; si i >= dch salto a res
		bge res	
		push {r0,r1,r8}					; pasamos parametros por pila
		bl qksort						; llamada a la subconsulta
		add sp,sp,#12					
										; sacamos los parametros de la pila		
		
res 	pop{r0-r8}
		pop{fp}
		pop{pc}
	
   END	 	
			
			
	