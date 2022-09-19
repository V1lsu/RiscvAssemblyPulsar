.macro Draw(%address, %frame)		# Desenha a imagem que t√° em a0 no frame <frame> e nas coords salva em <address>
	la t0, %address			# carrega o endere√ßo em t0
	lh a1,0(t0)			# carrega o x em a1
	lh a2,2(t0)			# carrega o y em a2
	mv a3, %frame			# coloca o frame em a3
	call PRINT			# desenha
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

.macro OpenGate()			# Checa se √© possivel abrir o port√£o e, se for, abre apenas uma vez
	la t0,PORTAO_LIFE		# carrega o endere√ßo do port√£o
	lb t0,0(t0)			# carrega a vida dele
	bne t0,zero,OpenGateRet		# se for > 0, entao nao abre agora	
	#aqui o port√£o vai abrir, pra n√£o ficar renderizando ele toda itera√ß√£o, deixa ele com -1 de vida
	addi t0, t0, -1			# deixa o port√£o com -1 de vida
	la t1, PORTAO_LIFE		# carrega o endere√ßo do port√£o
	sb t0,0(t1)			# salva a nova vida	
	DrawImageInBothFrames(tile, COORDS_GATE)
	OpenGateRet:			#continua com o codigo no game loop
.end_macro



# CheckFuel() n„o precisa chamar DrawNumber
# Est· desenhando 3 dÌgitos, mesmo que seja um zero ‡ esqueda
# Quando FUEL < 10, desenha em vermelho, do contr·rio, desenha em verde
# Atribui valores pra todos os argumentos sempre que desenho pra evitar comportamento n„o previsto
.macro CheckFuel()
	# Carrega FUEL, FUEL -= 1, guarda FUEL
	la t0, FUEL
	lb t1, 0(t0)
	addi t1,t1,-1
	sb t1, 0(t0)
	
	# if(FUEL < 10){ ...
	addi t0, zero, 10
	blt t1, t0, DEZ
	
	# esle if(FUEL < 100){ ...
	addi t0, zero, 100
	blt t1, t0, CEM

	# Essas 5 linhas se repetem muitas vezes abaixo, elas atribuem os valores dos argumentos
	# a3 = 0x38 È bit 1 apenas para verde
	# Os bits de 15 a 8 s„o todos 0, determinando preto como cor de fundo
	addi a1, zero, 290
	addi a2, zero, 16
	addi a3, zero, 0x38
	addi a4, zero, 0
	addi a7, zero, 101
	
	# Desenha no frame a4 = 0
	add a0, zero, t1
	ecall
	
	addi a1, zero, 290
	addi a2, zero, 16
	addi a3, zero, 0x38
	addi a4, zero, 1
	addi a7, zero, 101
	
	# Desenha no freme a4 = 1
	add a0, zero, t1
	ecall
	
	# Quando a funÁ„o desenha um n˙mero, a cordenada 'x' aumenta automaticamente
	# ISSO INFLUENCIA O OUTRO FRAME!!!

CHECA_ZERO:
	# Os casos de FUEL < 10, 10 <= FUEL < 100 e 100 <= FUEL pulam para c· e checam se deu GAME OVER
	# Depois pulam para o fim do macro
	beq t1, zero, GAME_OVER
	j FIM_CheckFuel

CEM:
	addi a1, zero, 290
	addi a2, zero, 16
	addi a3, zero, 0x38
	addi a4, zero, 0
	addi a7, zero, 101
	
	# Desenha o 0 uma vez antes do n˙mero
	add a0, zero, zero
	ecall
	add a0, zero, t1
	ecall
	
	addi a1, zero, 290
	addi a2, zero, 16
	addi a3, zero, 0x38
	addi a4, zero, 1
	addi a7, zero, 101
	
	add a0, zero, zero
	ecall
	add a0, zero, t1
	ecall
	
	j CHECA_ZERO

DEZ:
	# Repare que a3 = 0x07, bit 1 apenas para vermelho
	addi a1, zero, 290
	addi a2, zero, 16
	addi a3, zero, 0x07
	addi a4, zero, 0
	addi a7, zero, 101
	
	# Desenha 0 duas vezes antes do n˙mero
	add a0, zero, zero
	ecall
	add a0, zero, zero
	ecall
	add a0, zero, t1
	ecall
	
	addi a1, zero, 290
	addi a2, zero, 16
	addi a3, zero, 0x07
	addi a4, zero, 1
	addi a7, zero, 101
	
	add a0, zero, zero
	ecall
	add a0, zero, zero
	ecall
	add a0, zero, t1
	ecall
	
	j CHECA_ZERO

FIM_CheckFuel:

# Podemos diminuir o cÛdigo desse macro, ou deixar como est· para debug mais f·cil
# Os valores imediatos se repetem muitas vezes
.end_macro
