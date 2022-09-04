.macro Draw(%img, %x, %y)
.text
	la a0, %img			#carrega o endereço da imagem em a0
	li a1, %x			#carrega o x em a1
	li a2, %y			#carrega o y em a2
	li a3, 0			#frame 0
	call PRINT			#desenha
	li a3, 1			#frame 1
	call PRINT			#desenha
.end_macro

.macro Draw(%address, %frame)
.text
	la t0, %address			#carrega o endereço em t0
	lh a1,0(t0)			#carrega o x em a1
	lh a2,2(t0)			#carrega o y em a2
	mv a3, %frame			#coloca o frame em a3
	call PRINT			#desenha

.end_macro

.macro OpenGate()
.text
	la t0,PORTAO_LIFE		# carrega o endereço do portão
	lb t0,0(t0)			# carrega a vida dele
	bne t0,zero,GAME_LOOP		# se for > 0, entao nao abre agora	
	#aqui o portão vai abrir, pra não ficar renderizando ele toda iteração, deixa ele com -1 de vida
	addi t0, t0, -1			# deixa o portão com -1 de vida
	la t1, PORTAO_LIFE		# carrega o endereço do portão
	sb t0,0(t1)			# salva a nova vida	
	Draw(tile,304,208)
.end_macro

.data
CHAR_POS:	.half 16,16			# x, y
OLD_CHAR_POS:	.half 16,16			# x, y
COR_FUNDO: 	.byte 0				# cor do tile do fundo
CHAR_DIR: 	.byte 0				#direção do char, Dir = 0, Cima = 1, Esq = 2, Baixo = 3
PORTAO_LIFE:	.byte 3		

.text
SETUP:		
		Draw(map,0,0)			#Desenha o mapa inicial em (0, 0)
		Draw(key00,48,224)		#Desenha uma chave em (48, 224)
		Draw(key01,176,0)		#Desenha outra chave em (176,0)
		Draw(porta,304,208)		#Desenha o portão em (304, 208)

GAME_LOOP:	call KEY2			# chama o procedimento de entrada do teclado
		
		xori s0,s0,1			# inverte o valor frame atual (somente o registrador)
		
		call LOAD_SPRITE_CHAR 		# carrega o sprite de acordo com a direção em a0
		
		Draw(CHAR_POS,s0)
		
		li t0,0xFF200604		# carrega em t0 o endereco de troca de frame
		sw s0,0(t0)			# mostra o sprite pronto para o usuario
			
		la a0,tile			# carrega o endereco do sprite 'tile' em a0
		mv a3,s0			# pega o frame atual
		xori a3,a3,1			# inverte o frame
		Draw(OLD_CHAR_POS, a3)		# Limpa o rastro
		
		OpenGate()			#verifica se pode abrir o portão e, se puder, abre
		
		j GAME_LOOP			# continua o loop
		
#Move o personagem usando o incremento para x em t3 e o para y em t4
#A nova direção vem em t6
MOVE_CHAR:	la t0,CHAR_POS			#carrega em t0 o endereço de CHAR_POS		
		
		# ### Evita de entrar nas bordas ### #
		lh t1,0(t0)				#Testando se ele vai sair pela esquerda
        	add t1,t1,t3
        	blt t1,zero,MOVE_CHAR_RET

        	li t2, 320				#Testando se ele vai sair pela direita
        	bge t1,t2,MOVE_CHAR_RET

        	lh t1,2(t0)				#Testando se ele vai sair por cima
        	add t1,t1,t4
        	blt t1,zero,MOVE_CHAR_RET

       		li t2, 240				#Testando se ele vai sair por baixo
        	bge t1,t2,MOVE_CHAR_RET
        	#######################################

        	# ### Evita ele entrar nas paredes ### #
        	li t1,0xFF000000			#Endereço base
        	lh t2,0(t0)				#Carrega o x atual
        	add t1,t1,t2				#t1 = endereço base + x
        	add t1,t1,t3				#add o movimento de x em t1
        	lh t2,2(t0)				#carrega o y
        	add t2,t2,t4				#add o movimento do y
        	li t5, 320				#largura da tela
        	mul t2,t2,t5				#320y
        	add t1,t1,t2				#endereço base + x + incx + 320 * (y + incy)
        	lb t2,0(t1)				#carrega a cor que tá naquela posição
        	la t5, COR_FUNDO			#pega o endereço da cor do fundo
        	lb t5,0(t5)				#Carrega a cor do fundo
        	bne t2,t5,MOVE_CHAR_RET			#se for parede, entao nao anda
        	########################################

		addi t1,t1,1				#pega exatamente a direita
		lb t2,0(t1)				#pega a cor que está naquela posição
		la t5,PORTAO_LIFE
		lb t1,0(t5)
		sub t1,t1,t2
		sb t1,0(t5)

		la t0,CHAR_DIR				#carrega a direção atual
		sb t6,0(t0)				#salva a nova direção
		
		la t0,CHAR_POS				#carrega o endereço da posição atual
        	la t1,OLD_CHAR_POS			#carrega o endereço da posiçõ antiga

        	lw t2,0(t0)				#Carrega a posição atual
        	sw t2,0(t1)				#Salva a posição atual em OLD_CHAR_POS

        	lh t1,0(t0)				#Carrega o x em t1
        	add t1,t1,t3				#add o incremento no x
        	sh t1,0(t0)				#Salva o novo x

        	lh t1,2(t0)				#Carrega o y em t1
        	add t1,t1,t4				#add o incrementono t
        	sh t1,2(t0)				#Salva o novo y

        	MOVE_CHAR_RET: ret
        	
#Carrega o sprite certo do personagem dado sua direção
#Deixa o endereço em a0, usa t0 e t1
LOAD_SPRITE_CHAR:

		la t0, CHAR_DIR 			#endereço da direção do personagem
		lb t0,0(t0)				#carrega a direção do personagem
	
		li t1,0
		la a0,charDireita			#testa se está para direita
		beq t0, t1, LOAD_SPRITE_CHAR_RET

		li t1,1					#testa se está para cima
		la a0,charCima				
		beq t0, t1, LOAD_SPRITE_CHAR_RET

		li t1,2					#testa se está para esquerda
		la a0,charEsquerda			
		beq t0, t1, LOAD_SPRITE_CHAR_RET
	
		la a0,charBaixo				#se chegou até aqui, entao está para baixo

		LOAD_SPRITE_CHAR_RET: ret

KEY2:		li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
		lw t0,0(t1)			# Le bit de Controle Teclado
		andi t0,t0,0x0001		# mascara o bit menos significativo
   		beq t0,zero,FIM   	   	# Se nao ha tecla pressionada entao vai para FIM
   		
  		lw t2,4(t1)  			# le o valor da tecla tecla
		
		li t0,'w'
		li t3, 0			#add em x para subir
		li t4, -16			#add em y para subir
		li t6, 1			#Nova direção
		beq t2,t0,MOVE_CHAR		# se tecla pressionada for 'w', move pra cima
		
		li t0,'a'
		li t3,-16			#add em x para ir pra esq			
		li t4,0				#add em y para ir pra esq
		li t6, 2			#Nova direção do personagem
		beq t2,t0,MOVE_CHAR		# se tecla pressionada for 'a', move pra esquerda
		
		li t0,'s'
		li t3,0				#add em x para descer
		li t4,16			#add em y para descer
		li t6,3				#Nova direção
		beq t2,t0,MOVE_CHAR		# se tecla pressionada for 's', move para descer
		
		li t0,'d'
		li t3,16			#add em x para ir pra direita
		li t4,0				#add em y pra ir pra direita
		li t6,0				#Nova direção
		beq t2,t0,MOVE_CHAR		# se tecla pressionada for 'd', move para direita
	
FIM:		ret				# retorna

.data
.include "sprites/tile.s"
.include "sprites/map.s"
.include "sprites/char.s"
.include "sprites/key00.s"
.include "sprites/key01.s"
.include "sprites/charCima.s"
.include "sprites/charBaixo.s"
.include "sprites/charEsquerda.s"
.include "sprites/charDireita.s"
.include "sprites/porta.s"

.text
.include "code/print.s"
