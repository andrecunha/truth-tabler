#include <stdio.h>
#include <stdlib.h>
#include "logic_tree.h"
#include "tabler.tab.h"

void append(variable *table, variable *new_var) {
    while (table->next) {
        table = table->next;
    }

    table->next = new_var;
}


char *get_operation_name(int operation) {
    switch (operation) {
        case NOT:
            return "NOT";
        case AND:
            return "AND";
        case OR:
            return "OR";
        case IFF:
            return "IFF";
        case IMPLIES:
            return "IMPLIES";
        default:
            return "<OP>";
    }
}

/* 0 == Left; 1 == Right */
static int *which_subtree;

void __print_tree(node *root, int level) {
    if (root == NULL) {
        return;
    }

    which_subtree = realloc(which_subtree, (level + 1) * sizeof(int));
    printf("    ");

    for (int i = 0; i < level; i++) {
        if (i == level - 1) {
            if (which_subtree[i] == 1) {
                printf("'---");
            } else {
                printf("|---");
            }
        } else if (which_subtree[i] == 0) { // Left
            printf("|   ");
        } else { // Right
            printf("    ");
        }
    }

    if (root->is_leaf) {
        printf("%s\n", root->value.var->name);
    } else {
        printf("%s\n", get_operation_name(root->value.operation));
        which_subtree[level] = 0; // Left
        __print_tree(root->left_child, level + 1);
        which_subtree[level] = 1; // Right
        __print_tree(root->right_child, level + 1);
    }
}

void print_tree(node *root) {
    which_subtree = malloc(sizeof(int));
    __print_tree(root, 0);
    free(which_subtree);
}

bool eval_tree(node *root) {
    bool left, right;

    if (root->is_leaf) {
        return root->value.var->value;
    }

    if (root->value.operation != NOT) {
        left = eval_tree(root->left_child);
    }
    right = eval_tree(root->right_child);

    switch (root->value.operation) {
        case OR:
            return left || right;
        case AND:
            return left && right;
        case NOT:
            return !right;
        case IMPLIES:
            return !left || right;
        case IFF:
            return (!left || right) && (!right || left);
        default:
            printf("PANIC: Invalid operator.\n");
            exit(EXIT_FAILURE);
    }
}

node *mk_leaf(variable *var) {
    node *tree = malloc(sizeof(node));
    
    tree->left_child = NULL;
    tree->right_child = NULL;
    tree->is_leaf = true;
    tree->value.var = var;

    return tree;
}

node* mk_tree(node *left, node *right, int op) {
    node *tree = malloc(sizeof(node));
                                                                        
    tree->is_leaf = false;
    tree->left_child = left;
    tree->right_child = right;
    tree->value.operation = op;

    return tree;
}

void destroy_tree(node *root) {
    if (root->left_child) {
        destroy_tree(root->left_child);
    }

    if (root->right_child) {
        destroy_tree(root->right_child);
    }

    free(root);
}

void test_tree()
{
    node *root = malloc(sizeof(node)),
         *left = malloc(sizeof(node)),
         *right = malloc(sizeof(node));

    variable *a = malloc(sizeof(variable)),
             *b = malloc(sizeof(variable));

    a->name = "a";
    a->value = 1;

    b->name = "b";
    b->value = 1;

    root->is_leaf = false;
    root->value.operation = IMPLIES;

    left->is_leaf = true;
    left->value.var = a;

    right->is_leaf = true;
    right->value.var = b;

    root->left_child = left;
    root->right_child = right;

    print_tree(root);
    printf("Result: %d\n", eval_tree(root));
}
