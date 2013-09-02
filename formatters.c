#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "formatters.h"

static int total_length = 0;

void print_header_tabular(variable *vars, int n_variables) {
    /* Open the tabular environment. */
    printf("\\begin{tabular}{");
    
    for (int i = 0; i < n_variables; i++) {
        printf("l");
    }
    printf("|l}\n\\hline\n");

    /* Print the variables names. */
    for (int i = 0; i < n_variables; i++) {
        printf("%s & ", vars->name);
        vars = vars->next;
    }

    printf("V\\\\\n\\hline\n");
}

void print_row_tabular(variable *vars, int n_variables, bool value) {
    for (int i = 0; i < n_variables; i++) {
        printf("%d", vars->value);

        for (int j = 0; j < strlen(vars->name) - 1; j++) {
            printf(" ");
        }

        printf(" & ");
        vars = vars->next;
    }

    printf("%d", value);
    
    for (int j = 0; j < strlen("V") - 1; j++) {
        printf(" ");
    }

    printf("\\\\\n");
}

void print_footer_tabular(variable *vars, int n_variables) {
    /* Close the tabular environment. */
    printf("\\hline\n\\end{tabular}\n");
}

void print_header_terminal(variable *vars, int n_variables) {
    total_length = 0;

    variable *__vars = vars;
    while (__vars) {
        total_length += (strlen(__vars->name) + 3);
        __vars = __vars->next;
    }
    total_length += strlen("V");

    printf("    ");
    for (int i = 0; i < total_length; i++) {
        printf("-");
    }
    printf("\n    ");
    
    /* Print the variables names. */
    for (int i = 0; i < n_variables; i++) {
        printf("%s | ", vars->name);
        vars = vars->next;
    }

    printf("V\n");

    printf("    ");
    for (int i = 0; i < total_length; i++) {
        printf("-");
    }
    printf("\n");
}

void print_row_terminal(variable *vars, int n_variables, bool value) {
    printf("    ");
    
    for (int i = 0; i < n_variables; i++) {
        printf("%d", vars->value);

        for (int j = 0; j < strlen(vars->name) - 1; j++) {
            printf(" ");
        }

        printf(" | ");
        vars = vars->next;
    }

    printf("%d", value);
    
    for (int j = 0; j < strlen("V") - 1; j++) {
        printf(" ");
    }

    printf("\n");
}

void print_footer_terminal(variable *vars, int n_variables) {
    printf("    ");
    for (int i = 0; i < total_length; i++) {
        printf("-");
    }
    printf("\n");
}

