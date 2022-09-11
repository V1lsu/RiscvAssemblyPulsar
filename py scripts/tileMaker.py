corFundo = 0
corBorda = 15
corFuel = 100

print("fuel: .word 288, 18")
print(".byte ", end="")

for i in range(16 * 20):
    for j in range(18):
        if j % 2 == 0 : 
        	print(str(corFundo) + ",", end="")
        else :
        	print(str(corFuel) + ",", end="")
    print()
