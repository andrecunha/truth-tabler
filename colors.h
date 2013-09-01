#ifndef COLORS_H_INCLUDED
#define COLORS_H_INCLUDED

#include <stdio.h>

/* Text attributes. */

#define RESET       0
#define BOLD        1
#define UNDERSCORE  4
#define BLINK       5
#define REVERSE     7
#define CONCEALED   8

/* Foreground and background colors. */

#define BLACK       0
#define RED         1
#define GREEN       2
#define YELLOW      3
#define BLUE        4
#define MAGENTA     5
#define CYAN        6
#define WHITE       7

void text_color(int attr, int fg);

void reset_colors();

#endif /* COLORS_H_INCLUDED */
