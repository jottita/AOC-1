	AREA datos,DATA,READWRITE		; area de datos
	tabla DCD 4,8,5,9,1,6,2,7,3,0	; tabla de n enteros de 32 bits


   	AREA prog,CODE,READONLY			; area de codigo
    	ENTRY						; primera instruccion a ejecutar
		
		ldr r0,=tabla					; r0 = @tabla
		eor r1,	r1, r1					; r1 = izq = 0
		mov r2,#9						; r2 = dch = size tabla
		push {r1,r2}					; pasamos parametros por pila
		bl qksort						; llamada a la subconsulta
		pop {r1,r2}						; sacamos los parametros de la pila
       
fin 	b fin							; fin de programa

qksort 	push{r11,lr}
		mov r11,sp
		push{
		ldr r1,[fp,#12] 				; r1 = izq = i
		ldr r2,[fp,#8]					; r2 = dch = j
		add r3, r2,r1					; r3 = r2+r1
		ldr r4,[r0,lsl#2]				; r4 = x = T[(iz+de)/2]
		eor r5,r5,r5					; r5 = 0 = w
do		cmp r2,r1
		bhi rcrsv
		
while 	ldr r6,[r0,r1 lsl#2]			; r5 = T[i] 
		cmp r6, r4						; T[i] >= x
		bge while2
		add r1,r1,#1					; i++
		cmp r6,r4						; T[i]<=x
		bls while

while2	ldr r7,[r0,r2 lsl#2]			; T[j] 
		cmp r4, r7						; x >= T[j]
		bge si	
		sub r2,r2,#1					; j--
		cmp r4,r7						; x<= T[j]
		bls while2

si		cmp r1,r2
		bhi do
		ldr r7,[r0,r1 lsl#2]			; r7 = T[j] --> T[i]
		ldr r6,[r0,r2 lsl#2]			; r6 = T[i] --> T[j]
		add r1,r1,#1					; i=i+1
		sub r2,r2,#1					; j=j-1; 

		b do
		
rcrsv	ldr r8,[fp,#12] 				; r8 = izq
		cmp r8,r2						; iz<j
		bge rcrsv2
		push {r8,r2}					; pasamos parametros por pila
		bl qksort						; llamada a la subconsulta
		pop {r8,r2}						; sacamos los parametros de la pila
		
rcrsv2	ldr r9,[fp,#8] 					; r9 = dch 
 		cmp r1,r9						; i<de
		bge res	
		push {r1,r9}					; pasamos parametros por pila
		bl qksort						; llamada a la subconsulta
		pop {r1,r9}						; sacamos los parametros de la pila		
		
res 	pop{r1-r9 ,r11,lr}
		mov pc,lr


    	END							; fin de ensamblado