corFundo = 50

print("tile: .word 16, 16")
print(".byte ", end="")

for i in range(16):
    for j in range(16):
        print(str(corFundo) + ",", end="")
    print()
