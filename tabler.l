%option noyywrap

%{
#include <stdio.h>
#include <stdbool.h>
#include "tabler.tab.h"
#include "logic_tree.h"
#include "colors.h"

#ifdef NDEBUG
#define trace(x)
#else
#define trace(x) text_color(RESET, GREEN); printf("%s\n", x); reset_colors();
#endif
%}

%%

"~"                 { trace("# lex # NOT"); return NOT; }
"->"                { trace("# lex # IMPLIES"); return IMPLIES; }
"<->"               { trace("# lex # IFF"); return IFF; }
"or"                { trace("# lex # OR"); return OR; }
"and"               { trace("# lex # AND"); return AND; }
"("                 { trace("# lex # ("); return yytext[0]; }
")"                 { trace("# lex # )"); return yytext[0]; }

"true"              { trace("# lex # CONST"); yylval.value = true; return CONSTANT; }
"false"             { trace("# lex # CONST"); yylval.value = false; return CONSTANT; }
[0-1]               { trace("# lex # CONST"); yylval.value = yytext[0] - '0'; return CONSTANT; }

"tabular"           { trace("# lex # TABULAR"); return TABULAR; }

[a-z][a-zA-Z0-9]*   { trace("# lex # ID"); yylval.id = yytext; return IDENTIFIER; }

[ \t]               {;}

\n                  { trace("# lex # EOE"); return EOE; }

.                   { ECHO; printf(": Unrecognized character.\n"); }

%%
