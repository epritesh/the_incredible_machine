while True:
    try:
        if 1 <= (num := int(input("Height: "))) <= 8:
            print(f"You entered: {num}")
            break
    except ValueError:
        pass

for (
