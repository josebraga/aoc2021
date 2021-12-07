import sys

f = open("input.txt", "r")
l = list(map(int, f.read().split(",")))

min1 = sys.maxsize
min2 = sys.maxsize

def getFuelConsumption(dist):
    return int(abs(dist) * (abs(dist) + 1) / 2)

for idx, val in enumerate(l):
    fuel = sum(list(map(lambda x: abs(idx - x), l)))
    if fuel < min1:
        min1 = fuel

    fuel = sum(list(map(lambda x: getFuelConsumption(idx - x), l)))
    if fuel < min2:
        min2 = fuel

print("Day 7, part 1: ", min1)
print("Day 7, part 2: ", min2)
