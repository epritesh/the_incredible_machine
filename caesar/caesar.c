#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool only_digits(string arg_str);
char rotate(char c, int n);

int main(int argc, string argv[])
{
    if (argc != 2 || !only_digits(argv[1])) // Make sure program run with only one argument & every
                                            // char in argv[1] is a digit
    {
        printf("Usage: ./caesar key\n");
        return (1);
    }
    int key =
        atoi(argv[1]); // Convert argv[1] from a `string` to an `int`// Prompt user for plaintext
    string plaintext = get_string("Plaintext:  ");
    printf("Ciphertext:  ");
    for (int i = 0, n = strlen(plaintext); i < n; i++) // For each character in the plaintext:
    {
        // Rotate the character and print it
        printf("%c", rotate(plaintext[i], key));
    }
    printf("\n");
    return 0;
}
// Rotates a character by a given number of places
char rotate(char c, int n)
{
    if (isalpha(c))
    {
        if (isupper(c))
        {
            return ((c - 'A' + n) % 26 +
                    'A'); // If it's an uppercase letter, rotate the character and return it
        }
        else if (islower(c))
        {
            return ((c - 'a' + n) % 26 +
                    'a'); // If it's a lowercase letter, rotate the character and return it
        }
    }
    // If it's not a letter, return it as is
    return c;
}
// Checks if a string contains only digits
bool only_digits(string arg_str)
{
    for (int i = 0, n = strlen(arg_str); i < n; i++)
    {
        if (!isdigit(arg_str[i]))
        {
            return false;
        }
    }
    return true;
}
