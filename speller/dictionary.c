// Implements a dictionary's functionality

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include "dictionary.h"

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
} node;

// Sets number of buckets in hash table
const unsigned int N = 149993; // 149993 is prime and large enough for the expected dictionary sizes

// Creates Hash table
node *table[N];

// Creates variable to keep track of number of words in dictionary
unsigned int word_count = 0;

// Returns true if word in dictionary, else false
bool check(const char *word)
{
    // Gets hash value for word
    unsigned int hash_value = hash(word);

    // Accesses linked list at that index
    node *cursor = table[hash_value];

    // Goes through the linked list
    while (cursor != NULL)
    {
        // Uses strcasecmp for case-insensitive comparison
        if (strcasecmp(cursor->word, word) == 0)
        {
            return true;
        }
        cursor = cursor->next;
    }

    // Returns false if word not found
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    unsigned long hash_value = 5381;
    int c;
    while ((c = *word++))
    {
        // Converts character to lowercase before hashing to ensure case-insensitivity
        hash_value =
            ((hash_value << 5) + hash_value) + tolower(c); // djb2 algorithhm chosen for efficiency
    }
    return hash_value % N; // Modulo for error checking
}

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    // Initializes hash table to NULL
    for (int i = 0; i < N; i++)
    {
        table[i] = NULL;
    }

    // Opens the dictionary file
    FILE *file = fopen(dictionary, "r");
    if (file == NULL)
    {
        return false;
    }

    // Buffers to store words read from the file
    char buffer[LENGTH + 1];

    // Reads words from the dictionary one by one
    while (fscanf(file, "%s", buffer) != EOF)
    {
        // Creates a new node for the word
        node *new_node = malloc(sizeof(node));
        if (new_node == NULL)
        {
            fclose(file);
            return false;
        }

        // Copies the word into the new node
        strcpy(new_node->word, buffer);

        // Hashes the word to get hash value
        unsigned int hash_value = hash(buffer);

        // Inserts the new node at the beginning of the linked list
        new_node->next = table[hash_value];
        table[hash_value] = new_node;

        // Increments the word count
        word_count++;
    }

    // Closes the dictionary file
    fclose(file);

    return true;
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size(void)
{
    return word_count;
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    // Iterate through each bucket in the hash table
    for (int i = 0; i < N; i++)
    {
        // Get the head of the linked list
        node *cursor = table[i];

        // Traverse the linked list and free each node
        while (cursor != NULL)
        {
            node *temp = cursor;
            cursor = cursor->next;
            free(temp);
        }
    }

    // Reset the word count
    word_count = 0;
    return true;
}
