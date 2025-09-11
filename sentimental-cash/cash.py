from cs50 import get_float

  # Prompt the user for the amount of change
  dollars = get_float("Change owed: ")

   # Ensure a non-negative amount is entered
   while dollars < 0:
        dollars = get_float("Change owed: ")

    # Convert dollars to cents to avoid floating-point inaccuracies
    cents = int(round(dollars * 100))

    # Initialize the coin counter
    coins = 0

    # Calculate quarters
    coins += cents // 25
    cents %= 25

    # Calculate dimes
    coins += cents // 10
    cents %= 10

    # Calculate nickels
    coins += cents // 5
    cents %= 5

    # Calculate pennies
    coins += cents // 1

    # Print the total number of coins
    print(coins)
