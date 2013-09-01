#ifndef LOGIC_TREE_INCLUDED
#define LOGIC_TREE_INCLUDED

#include <stdbool.h>

/* Logic variables. */

struct variable {
    char *name;
    bool value;
    struct variable *next;
};

typedef struct variable variable;

void append(variable *table, variable *new_var);

/* Expression trees. */

struct node {
    struct node *left_child;
    struct node *right_child;
    bool is_leaf;
    union value {
        int operation;
        variable *var;
    } value;
};

typedef struct node node;

node *mk_leaf(variable *var);
node* mk_tree(node *left, node *right, int op);
void print_tree(node *root);
bool eval_tree(node *root);
void destroy_tree(node *root);
void test_tree(void);

#endif /* LOGIC_TREE_INCLUDED */
