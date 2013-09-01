#include "colors.h"

void text_color(int attr, int fg)
{
    printf("\x1b[%d;%dm", attr, fg + 30);
}

void reset_colors()
{
    printf("\x1b[%dm", 0); 
}
