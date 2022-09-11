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
		la t5,PORTAO_LIFE			#pega o endereço da vida do portao
		lb t1,0(t5)				#carrega a vida do portao
		sub t1,t1,t2				#remove o numero da posição
		sb t1,0(t5)				#salva a nova vida

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

		CheckFuel()				# Diminue um do combustivel e, se ele ficar zerado, encerra

        	MOVE_CHAR_RET: ret