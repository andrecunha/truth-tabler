%{
#include <stdio.h>
#include <string.h>
#include "logic_tree.h"
#include "formatters.h"
#include "colors.h"

#ifdef NDEBUG
#define trace(x)
#define tracev(...)
#else
#define trace(x) text_color(RESET, BLUE); printf("%s\n", x); reset_colors();
#define tracev(...) text_color(RESET, BLUE); printf(__VA_ARGS__); reset_colors();

#endif

int yylex(void);
void yyerror(char *msg);

static bool bool_values[2] = {false, true};

static variable *variables = NULL;
static int n_variables = 0;
static variable *constants = NULL;

variable* add_variable(char *var);
variable* add_constant(bool value);

static bool expression_is_valid;
static bool expression_is_unsat;

static void (*print_header)(variable *vars, int n_variables) = NULL;
static void (*print_row)(variable *vars, int n_variables, bool value) = NULL;
static void (*print_footer)(variable *vars, int n_variables) = NULL;

void print_table(node *tree);
void print_satisfiability(node *tree);
//void print_variables(variable *table);

void clear(void);
%}

%union {
    struct node *tree;
    char *id;
    bool value;
}

%token NOT IMPLIES IFF OR AND TABULAR EOE
%token <id> IDENTIFIER
%token <value> CONSTANT
%type <tree> expression conj_expression disj_expression factor

%start line

%%

line                    : expression EOE            {   print_header = print_header_terminal;
                                                        print_row = print_row_terminal;
                                                        print_footer = print_footer_terminal;

                                                        text_color(BOLD, WHITE);
                                                        printf("\nTruth table:\n\n");
                                                        reset_colors();

                                                        print_table($1);

                                                        text_color(BOLD, WHITE);
                                                        printf("\nTree:\n\n");
                                                        reset_colors();
                                                        
                                                        print_tree($1);
 
                                                        print_satisfiability($1);

                                                        destroy_tree($1);
                                                        clear();
                                                    }
                        | TABULAR expression EOE    {   print_header = print_header_tabular;
                                                        print_row = print_row_tabular;
                                                        print_footer = print_footer_tabular;

                                                        text_color(BOLD, WHITE);
                                                        printf("\nTruth table:\n\n");
                                                        reset_colors();

                                                        print_table($2);

                                                        text_color(BOLD, WHITE);
                                                        printf("\nTree:\n\n");
                                                        reset_colors();
                                                        
                                                        print_tree($2);
 
                                                        print_satisfiability($2);

                                                        destroy_tree($2);
                                                        clear();
                                                    }
                        | EOE
                        ;

expression              : expression IMPLIES disj_expression   { $$ = mk_tree($1, $3, IMPLIES); }
                        | expression IFF disj_expression       { $$ = mk_tree($1, $3, IFF); }          
                        | disj_expression                      { $$ = $1; }
                        ;

disj_expression         : disj_expression OR conj_expression    { $$ = mk_tree($1, $3, OR); }
                        | conj_expression                       { $$ = $1; }
                        ;

conj_expression         : conj_expression AND factor    { $$ = mk_tree($1, $3, AND); }
                        | factor                        { $$ = $1; }
                        ;

factor                  : NOT factor            { $$ = mk_tree(NULL, $2, NOT); }
                        | '(' expression ')'    { $$ = $2; }
                        | IDENTIFIER            { variable *var = add_variable($1);
                                                  $$ = mk_leaf(var);
                                                }
                        | CONSTANT              { variable *var = add_constant($1);
                                                  $$ = mk_leaf(var);
                                                }
                        ;
%%

void print_variables(variable *table)
{
    if (table != NULL) {
        printf("%s", table->name);
        
        if (table->next) {
            print_variables(table->next);
        } else {
            printf("\n");
        }
    }
}

variable* get_variable(variable *table, char *var)
{
    if (!strcmp(table->name, var)) {
        return table;
    } else if (!table->next) {
        return NULL;
    } else {
        return get_variable(table->next, var);
    }
}

variable* add_variable(char *var)
{
    tracev("# syn # Will add variable %s.\n", var);

    if (!variables) {
        variables = malloc(sizeof(variable));

        char *name = malloc((strlen(var) + 1) * sizeof(char));
        strcpy(name, var);

        variables->name = name;
        variables->value = false;
        variables->next = NULL;
        
        n_variables++;
        
        return variables;
    } else {
        variable *__var;
        if (!(__var = get_variable(variables, var))) {
            variable *new_variable = malloc(sizeof(variable));
         
            char *name = malloc((strlen(var) + 1) * sizeof(char));
            strcpy(name, var);
            
            new_variable->name = name;
            new_variable->value = false;
            new_variable->next = NULL;

            append(variables, new_variable);
            
            n_variables++;

            return new_variable;
        }
        return __var;
    }
    //print_table(variables);
}

variable* add_constant(bool value)
{
    char *name = value ? "true" : "false";
    if (!constants) {
        constants = malloc(sizeof(variable));

        constants->name = name;
        constants->next = NULL;
        constants->value = value;

        return constants;
    } else {
        variable *__var;
        if (!(__var = get_variable(constants, name))) {
            variable *new_constant = malloc(sizeof(variable));

            new_constant->name = name;
            new_constant->next = NULL;
            new_constant->value = value;        

            append(constants, new_constant);

            return new_constant;
        }
        return __var;
    }
}

void print_variable_values(variable *table)
{
    if (table) {
        printf("%d ", table->value);
        
        if (table->next) {
            print_variable_values(table->next);
        }
    }
}

void print_rows(variable *table, node *tree)
{
    for (int i = 0; i < 2; i++) {
        table->value = bool_values[i];
        
        if (table->next) {
            print_rows(table->next, tree);
        } else {
            (*print_row)(variables, n_variables, eval_tree(tree));
        }
    }
}

void print_table(node *tree)
{
    (*print_header)(variables, n_variables);
    print_rows(variables, tree);
    (*print_footer)(variables, n_variables);
}

void determine_satisfiability(variable *table, node *tree)
{
    for (int i = 0; i < 2; i++) {
        table->value = bool_values[i];
        
        if (table->next) {
            determine_satisfiability(table->next, tree);
        } else {
            bool value = eval_tree(tree); 
            expression_is_valid &= value;
            expression_is_unsat &= !value;
        }
    }
}

void print_satisfiability(node *tree)
{
    expression_is_valid = true;
    expression_is_unsat = true;

    determine_satisfiability(variables, tree);

    text_color(BOLD, WHITE);

    printf("\nThe expression is ");
    if (expression_is_valid) {
        printf("valid.\n\n");
    } else if (expression_is_unsat) {
        printf("unsat.\n\n");
    } else {
        printf("sat.\n\n");
    }
   
    reset_colors(); 
}

void clear_table_and_names(variable *table)
{
    if (table) {
        if (table->next) {
            clear_table_and_names(table->next);
        } else {
            free(table->name);
            free(table);
        }
    }
}

void clear_table(variable *table)
{
    if (table) {
        if (table->next) {
            clear_table(table->next);
        } else {
            //free(table->name);
            free(table);
        }
    }
}

void clear(void)
{
    clear_table_and_names(variables);
    variables = NULL;
    n_variables = 0;
    trace("# syn # Cleared variables table.");
    
    clear_table(constants);
    constants = NULL;
    trace("# syn # Cleared constants table.");
}

void yyerror(char *msg)
{
    printf("%s\n", msg);
}

int main(int argc, char* argv[])
{
    yyparse();
    
    return 0;
}
