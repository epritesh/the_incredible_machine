#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    // Check for exactly 1 command-line argument
    if (argc != 2)
    {
        printf("Usage: ./recover IMAGE\n");
        return 1;
    }

    // Open input file
    FILE *input_file = fopen(argv[1], "r");
    if (input_file == NULL)
    {
        printf("Could not open file.\n");
        return 1;
    }

    // Initialize variables
    uint8_t buffer[512];
    int count = 0;
    FILE *output_file = NULL;

    // Read 512 bytes at a time
    while (fread(buffer, sizeof(uint8_t), 512, input_file) == 512)
    {
        // Check for JPEG signature
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff &&
            (buffer[3] & 0xf0) == 0xe0)
        {
            // Found new JPEG
            // If already writing a file, close it
            if (output_file != NULL)
            {
                fclose(output_file);
            }

            // Else, create new filename and open new output file
            char filename[8];
            sprintf(filename, "%03i.jpg", count);
            output_file = fopen(filename, "w");
            if (output_file == NULL)
            {
                // Handle error
                fclose(input_file);
                return 1;
            }
            count++;

            // Write first block
            fwrite(buffer, sizeof(uint8_t), 512, output_file);
        }
        else
        {
            // If already writing, continue writing to the same file
            if (output_file != NULL)
            {
                fwrite(buffer, sizeof(uint8_t), 512, output_file);
            }
        }
    }

    // Cleanup
    if (output_file != NULL)
    {
        fclose(output_file);
    }
    fclose(input_file);
    return 0;
}
