.macro Draw(%address, %frame)		# Desenha a imagem que tá em a0 no frame <frame> e nas coords salva em <address>
	la t0, %address			# carrega o endereço em t0
	lh a1,0(t0)			# carrega o x em a1
	lh a2,2(t0)			# carrega o y em a2
	mv a3, %frame			# coloca o frame em a3
	call PRINT			# desenha
.end_macro

.macro DrawNumber(%num, %x, %y, %frame, %corFundo, %corTexto)		# Desenha um numero na posição dada
	add a0, zero, %num						# Numero que será desenhado
	addi a1, zero, %x						# Posição x
	addi a2, zero, %y						# posição y
	
	li a3, 0x000000ff						# cor do texto ff e fundo preto 00
	add a3, zero, zero						# faz a3 = 0
	addi a3, a3, %corFundo						# adiciona a cor do fundo
	srli a3, a3, 2
	addi a3, a3, %corTexto
	
	li a4, %frame
	li a7, 101				# ecall do print
	ecall		
.end_macro

.macro DrawImageInBothFrames(%imgName, %coordsName)
	la a0, %imgName
	la t0, %coordsName
	lh a1, 0(t0)
	lh a2, 2(t0)
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT
.end_macro

.macro DrawImageInHiddenFrame(%address, %coordsAddress)
	la a0, %address
	la t0, %coordsAddress
	lh a1, 0(t0)
	lh a2, 2(t0)
	li a3, 0xFF200604
	lw a3, 0(a3)
	xori a3, a3, 1
	call PRINT
.end_macro

.macro OpenGate()			# Checa se é possivel abrir o portão e, se for, abre apenas uma vez
	la t0,PORTAO_LIFE		# carrega o endereço do portão
	lb t0,0(t0)			# carrega a vida dele
	bne t0,zero,OpenGateRet		# se for > 0, entao nao abre agora	
	#aqui o portão vai abrir, pra não ficar renderizando ele toda iteração, deixa ele com -1 de vida
	addi t0, t0, -1			# deixa o portão com -1 de vida
	la t1, PORTAO_LIFE		# carrega o endereço do portão
	sb t0,0(t1)			# salva a nova vida	
	DrawImageInBothFrames(tile, COORDS_GATE)
	OpenGateRet:			#continua com o codigo no game loop
.end_macro

.macro CheckFuel()
	la t0, FUEL
	lb t1, 0(t0)
	addi t1,t1,-1
	sb t1, 0(t0)
	li t0, 9
	bne t0, t1, FUEL_CONTINUE
	
	#la a0, tile
	#li a1, 316
	#li a2, 16
	#li a3, 0
	#call PRINT
	#li a3, 1
	#call PRINT
		
FUEL_CONTINUE:
	DrawNumber(t1, 300, 16, 0, 0x00, 0xff)
	DrawNumber(t1, 300, 16, 1, 0x00, 0xff)
	
	beq t1, zero, GAME_OVER
.end_macro
