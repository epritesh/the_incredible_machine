#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

int get_score(string word)
{
    int points[] = {1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10};
    int score = 0;
    for (int k = 0; word[k] != '\0'; k++)
    {
        if (word[k] >= 'a' && word[k] <= 'z')
        {
            score += points[word[k] - 'a'];
        }
    }
    return score;
}

int main(void)
{
    // Prompt the user for two words
    string word1 = get_string("Enter Player 1's Word: ");
    string word2 = get_string("Enter Player 2's Word: ");

    // Compute the score of each word
    for (int i = 0; word1[i] != '\0'; i++)
    {
        word1[i] = tolower(word1[i]);
    }
    for (int j = 0; word2[j] != '\0'; j++)
    {
        word2[j] = tolower(word2[j]);
    }

    int score1 = get_score(word1);
    int score2 = get_score(word2);

    // Print the winner
    if (score1 > score2)
    {
        printf("Player 1 wins\n");
    }
    else if (score2 > score1)
    {
        printf("Player 2 wins!\n");
    }
    else
    {
        printf("Tie!\n");
    }
}
