#include <cs50.h>
#include <stdio.h>

int main(void)
{
    int change = 0;
    int coins = 0;
    while (change <= 0) // Prompt for amount change needed
    {
        change = get_int("Change needed (in cents):\n");
    }
    while (change >= 25) // Quarters
    {
        change = change - 25;
        coins++;
    }
    while (change >= 10) // Dimes
    {
        change = change - 10;
        coins++;
    }
    while (change >= 5) // Nickels
    {
        change = change - 5;
        coins++;
    }
    while (change >= 1) // Pennies
    {
        change = change - 1;
        coins++;
    }
    printf("Coins required: %d\n", coins);
}
