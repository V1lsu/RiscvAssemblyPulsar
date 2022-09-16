.macro Draw(%address, %frame)		# Desenha a imagem que tá em a0 no frame <frame> e nas coords salva em <address>
	la t0, %address			# carrega o endereço em t0
	lh a1,0(t0)			# carrega o x em a1
	lh a2,2(t0)			# carrega o y em a2
	mv a3, %frame			# coloca o frame em a3
	call PRINT			# desenha
.end_macro

.macro DrawWithImmCoords(%address, %x, %y)
	la a0, %address
	li a1, %x
	li a2, %y
	li a3, 0
	#desenhar nos dois frames por enquanto
	call PRINT
	li a3, 1
	call PRINT
	
.end_macro

.macro DrawNumber(%num, %x, %y, %frame, %corFundo, %corTexto)		# Desenha um numero na posição dada
	add a0, zero, %num						# Numero que será desenhado
	addi a1, zero, %x						# Posição x
	addi a2, zero, %y						# posição y
	
	add a3, zero, zero						# faz a3 = 0
	addi a3, a3, %corFundo						# adiciona a cor do fundo
	srli a3, a3, 2							# shifta duas vezes pra cor do texto não sobrepor a do fundo
	addi a3, a3, %corTexto						# add a cor do fundo
	
	li a4, %frame
	li a7, 101							# ecall do print
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
	bgt t1, t0, DrawGreenFuel
			
	#bne t1, t0, DrawRedFuel

	# if(fuel == 9) 
	#	desenha tile na segunda posição
	# desenha numero em vermelho
	
	#nesse momento o fuel é 9
	#DrawWithImmCoords(tile, 308, 16)
			
#DrawRedFuel:
	DrawNumber(t1, 300, 16, 0, 0x2f, 0xff) #corrigir esse 0x2f pra ser um vermelho bem claro
	DrawNumber(t1, 300, 16, 1, 0x2f, 0xff)
	j FuelRet	
		
DrawGreenFuel:
	DrawNumber(t1, 300, 16, 0, 0xf0, 0xff)
	DrawNumber(t1, 300, 16, 1, 0xf0, 0xff)
	
FuelRet:
	beq t1, zero, GAME_OVER
	
.end_macro
