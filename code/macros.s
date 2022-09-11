.macro Draw(%img, %x, %y)		# Desenha a imagem que tá no endereço img começando em (x, y)
	la a0, %img			# carrega o endereço da imagem em a0
	li a1, %x			# carrega o x em a1
	li a2, %y			# carrega o y em a2
	li a3, 0			# frame 0
	call PRINT			# desenha
	li a3, 1			# frame 1
	call PRINT			# desenha
.end_macro

.macro Draw(%address, %frame)		# Desenha a imagem que tá no endereço address no frame <frame>
	la t0, %address			# carrega o endereço em t0
	lh a1,0(t0)			# carrega o x em a1
	lh a2,2(t0)			# carrega o y em a2
	mv a3, %frame			# coloca o frame em a3
	call PRINT			# desenha
.end_macro

.macro DrawNumber(%num, %x, %y, %frame)	# Desenha um numero na posição dada
	li a0, %num			# Numero que será desenhado
	li a1, %x			# posição x
	li a2, %y			# posição y
	li a3, 0x000000ff		# cor do texto ff e fundo preto 00
	li a4, %frame			#escolhe o frame
	li a7, 101			# ecall do print
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
