.macro Draw(%img, %x, %y)		# Desenha a imagem que tá no endereço img começando em (x, y)
	la a0, %img			# carrega o endereço da imagem em a0
	li a1, %x			# carrega o x em a1
	li a2, %y			# carrega o y em a2
	li a3, 0			# frame 0
	
	#Corrigir isso aqui!!! Não desenhar nos dpos frames!!!!!!!!!!!!!!!
	
	call PRINT			# desenha
	li a3, 1			# frame 1
	call PRINT			# desenha
.end_macro

.macro Draw(%address, %frame)		# Desenha a imagem que tá em a0 no frame <frame> e nas coords salva em <address>
	la t0, %address			# carrega o endereço em t0
	lh a1,0(t0)			# carrega o x em a1
	lh a2,2(t0)			# carrega o y em a2
	mv a3, %frame			# coloca o frame em a3
	call PRINT			# desenha
.end_macro

.macro DrawNumber(%num, %x, %y, %frame)			# Desenha um numero na posição dada
	add a0, zero, %num			# Numero que será desenhado
	addi a1, zero, %x			# Posição x
	addi a2, zero, %y			# posição y
	li a3, 0x000000ff			# cor do texto ff e fundo preto 00
	li a4, %frame
	li a7, 101				# ecall do print
	ecall		
.end_macro

.macro OpenGate()			# Checa se é possivel abrir o portão e, se for, abre apenas uma vez
	la t0,PORTAO_LIFE		# carrega o endereço do portão
	lb t0,0(t0)			# carrega a vida dele
	bne t0,zero,OpenGateRet		# se for > 0, entao nao abre agora	
	#aqui o portão vai abrir, pra não ficar renderizando ele toda iteração, deixa ele com -1 de vida
	addi t0, t0, -1			# deixa o portão com -1 de vida
	la t1, PORTAO_LIFE		# carrega o endereço do portão
	sb t0,0(t1)			# salva a nova vida	
	Draw(tile,256,192)
	OpenGateRet:			#continua com o codigo no game loop
.end_macro

.macro DrawImageInHiddenFrame(%address, %regx, %regy)
	la a0, %address
	mv a1, %regx
	mv a2, %regy
	
	li a3, 0xFF200604
	lw a3, 0(a3)
	xori a3, a3, 1
	
	call PRINT
.end_macro

.macro DrawImageInHiddenFrame(%address, %coordsAddress)
	la a0, %address
	
	mv a1, %regx
	mv a2, %regy
	
	li a3, 0xFF200604
	lw a3, 0(a3)
	xori a3, a3, 1
	
	call PRINT
.end_macro

.macro CheckFuel()
	la t0, FUEL
	lb t1, 0(t0)
	addi t1,t1,-1
	sb t1, 0(t0)
	DrawNumber(t1, 300, 16, 0)
	DrawNumber(t1, 300, 16, 1)
	beq t1, zero, GAME_OVER
.end_macro