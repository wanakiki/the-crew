color = ["B", "G", "P", "Y"]

res = []
for c in color:
    for i in range(9):
        res.append(c + str(i+1))

res.extend(["A1", "A2", "A3", "A4"])

print(res)