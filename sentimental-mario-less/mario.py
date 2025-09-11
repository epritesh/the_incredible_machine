from cs50 import get_int

# Repeatedly prompts for height until valid entry received
while True:
    height = get_int("Height: ")
    if 1 <= height <= 8:
        break

for i in range(1, height + 1):
    # Print spaces
    print(" " * (height - i), end="")

    # Print hashes
    print("#" * i)
