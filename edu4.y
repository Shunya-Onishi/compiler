%{
#include <stdio.h>
#include "edu4.tab.h"
#include "makeast.h"
  extern int yylex();
  extern int yyerror();
  extern char *yytext;
  %}
%union{
  struct node *node;
  int ival;
  char *sval;
  int *dummy;
  double dval;
 }

%token <sval> IDEN 
%token <ival> NUMBER
%token <dummy> array
%token <node> define
%token <dummy> ELSE
%token <dummy> IF
%token <dummy> WHILE
%token <dummy> adsub
%token <dummy> muldiv
%token <dummy> compari
%token <node> cricri
%token <dummy> FOR

%type <node> program
%type <node> unions
%type <node> decsen
%type <node> sentences
%type <node> sentence
%type <node> asastate
%type <node> incri
%type <node> assignment
%type <node> expression
%type <node> term
%type <node> fact
%type <node> variable
%type <node> identyan
%type <node> loopsen
%type <node> brasen
%type <node> forsen
%type <node> condition
%type <node> ntyan


%%

program: unions sentences {
  $$ = build_node2(PROGRAM, $1, $2);
  printNodes($$);
};

unions: decsen unions  {$$ = build_node2(UNIONS, $1, $2);}
| decsen  {$$ = build_node1($1);}; //??????

decsen: define IDEN ';' {$$ = build_node1(IDENT, $1);} //?????????
| array identyan'['ntyan']' ';' {$$ = build_node2(ARRAY, $2, $4);}
| array identyan'['identyan']' ';' {$$ = build_node2(ARRAY, $2, $4);}
| array identyan'['ntyan']''['ntyan']'';' {$$ = build_node3(ARRAY, $2, $4, $7);}
| array identyan'['identyan']''['identyan']'';' {$$ = build_node3(ARRAY, $2, $4, $7);};

sentences: sentence sentences {$$ = build_node2(SENS, $1, $2);}
| sentence {$$ = build_node1($1);}; //?????????

sentence: asastate {$$ = build_node1($1);} //?????
| loopsen {$$ = build_node1($1);} //?????
| brasen {$$ = build_node1($1);} //????
| forsen {$$ = build_node1($1);}; //????/

asastate: identyan '=' expression ';' {$$ = build_node2(ASSIGN, $1, $3);}
  | assignment '=' expression ';' {$$ = build_node2(ASSIGN, $1, $3);}
  | incri ';' {$$ = build_node1($1);} //?????????

incri: identyan cricri {$$ = build_node2(INCRI, $1, $2);}
| cricri identyan {$$ = build_node2(INCRI, $1, $2);}

 assignment:identyan'['ntyan']' {$$ = build_node2(ARRAY, $1, $3);}
| identyan'['identyan']' {$$ = build_node2(ARRAY, $1, $3);}
| identyan'['ntyan']''['ntyan']' {$$ = build_node3(ARRAY, $1, $3, $6);}
| identyan'['identyan']''['identyan']'  {$$ = build_node3(ARRAY, $1, $3, $6);};

expression : expression adsub term {$$ = build_node2(ADSUB, $1, $3);}
| term {$$ = build_node1($1);};  //????

term : term muldiv fact {$$ = build_node2(MULDIV, $1, $3);}
| fact {$$ = build_node1($1);}; //????

fact : variable {$$ = build_node1($1);} //?????
| '('expression')' {$$ = build_node1($2);};  //?????

  //adsub: '+' | '-'; //?????
  //muldiv:'*' | '/'; //?????

variable: identyan {$$ = build_node1($1);} //?????
| ntyan {$$ = build_node1($1);} //?????
| identyan'['ntyan']' {$$ = build_node2(ARRAY, $1, $3);}
| identyan'['identyan']' {$$ = build_node2(ARRAY, $1, $3);}
| identyan'['ntyan']''['ntyan']' {$$ = build_node3(ARRAY, $1, $3, $6);}
| identyan'['identyan']''['identyan']'{$$ = build_node3(ARRAY, $1, $3, $6);};

identyan:IDEN {$$ = build_ident_node(IDENT, yytext);};

ntyan:NUMBER {$$ = build_num_node(NUM, $1);}; 

loopsen: WHILE '('condition')''{'sentences'}'{$$ = build_node2(WHILE_N, $3, $6);};

brasen: IF'('condition')''{'sentences'}'{$$ = build_node2(IF_N, $3, $6);};
| IF'('condition')''{'sentences'}'ELSE'{'sentences'}'{$$ = build_node3(IF_N, $3, $6, $10);};

forsen: FOR '('asastate  condition ';' asastate ')' '{'sentences'}'{$$ = build_node4(FOR_N, $3, $4, $6, $9);};

condition: expression compari expression {$$ = build_node2(compari_N, $1, $3);};

//compari: '=''=' | '<' | '>' | '<''=' | ">=";

%%

int main(void)
{
  if(yyparse()){
    fprintf(stderr, "Error\n");
    return 1;
  }

  return 0;
}
