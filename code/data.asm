.data
CHAR_POS:	.half 16,16			# x, y
OLD_CHAR_POS:	.half 16,16			# x, y

CHAR_DIR: 	.byte 0				# direção do char, Dir = 0, Cima = 1, Esq = 2, Baixo = 3
PORTAO_LIFE:	.byte 3				# vida do portao
FUEL: 		.half 110			# quantidade de combustivel restante
COR_FUNDO: 	.byte 0				# cor do tile do fundo

COORDS_MAP: 	.half 0, 0			# coordenadas inicias do mapa
COORDS_KEY0:	.half 48, 192			# coordenadas inicias de uma chave
COORDS_KEY1:	.half 176, 0			# coordenadas inicias de outra chave
COORDS_GATE: 	.half 256, 192			# coordenadas inicias do portao
