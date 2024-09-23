	AREA datos,DATA
n DCD 5 ;numero para calcular el factorial
fact DCD 0 ;resultado del factorial
	AREA codigo,CODE
	ENTRY
	sub sp,sp,#4 ;espacio para resultado
	LDR r1,=n ;r1=direccion de n
	ldr r0,[r1] ;r0=n
	PUSH {r0} ;apilar n (por valor)
	bl facto ;llamar a SBR facto
	add sp,sp,#4 ;liberar parametro
	POP {r0} ;r0=n!
	LDR r1,=fact ;r1=@fact
	str r0,[r1] ;fact=n!

fin b fin

;SBR recursiva FACTO
facto 	PUSH {lr,r11} ;apilar r14=@ret y r11
		mov fp,sp ;r11=fp=frame pointer
		PUSH {r0,r1} ;apilar registros a utilizar
		ldr r0,[fp,#8] ;r0=n (valor)
		cmp r0,#1
		beq fins ;salta si n=1 (caso trivial)
		sub r1,r0,#1 ;r1=n-1
		sub sp,sp,#4 ;espacio para resultado
		PUSH {r1} ;apilar n-1 (por valor)
		bl facto ;llamada recursiva a SBR facto
		add sp,sp,#4 ;liberar parametro
		POP {r1} ;desapila resul. r1=(n-1)!
		mul r0,r1,r0 ;r0=n*(n-1)!=n!=F(n)
fins 	str r0,[fp,#12] ;res=F(n)
		POP {r0-r1,r11,pc} ;rec. reg. utilizados y retornar
		
	END 