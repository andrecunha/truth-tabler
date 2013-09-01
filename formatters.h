#ifndef FORMATTERS_H_INCLUDED
#define FORMATTERS_H_INCLUDED

#include "logic_tree.h"

void print_header_tabular(variable *vars, int n_variables);

void print_row_tabular(variable *vars, int n_variables, bool value);

void print_footer_tabular(variable *vars, int n_variables);

void print_header_terminal(variable *vars, int n_variables);

void print_row_terminal(variable *vars, int n_variables, bool value);

void print_footer_terminal(variable *vars, int n_variables);

#endif /* FORMATTERS_H_INCLUDED */
