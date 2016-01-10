%{
#include<stdio.h>
#include<stdlib.h>

#include "parse.h"


int *sym[26];
bool divError;
struct returnType ret;

%}

%union
{
int ival;
float fval;
char cval;
struct NodeTag* nval;
}

%token EXIT READ WRITE EQUALS LE GE
%token <ival> INTEGER 
%token <cval> VAR
%type <nval> expr stmt


%left '+' '-'
%left '*' '/'
%nonassoc '=' EQUALS '>' '<' LE GE

%%

program: program stmt '\n'	{if (!divError)	
					{
					ret = interpret($2);
					if(ret.printable)		
						printf("= %d\n",ret.value);//freeNode($2);
						
					}
					
				else
					{
					printf("Division by Zero Error\n");
					divError = false;
					}
				}
	|error '\n'
	|EXIT '\n'		{return 0;}
	|
	;

stmt: stmt expr '\n'		{$$ = $2;				}
	|READ '(' VAR ')'	{$$ = makeOperNode(READ,1,makeVarNode($3));		}
	|WRITE '(' VAR ')'	{$$ = makeOperNode(WRITE,1,makeVarNode($3));		}
	|WRITE '(' expr ')'	{$$ = makeOperNode(WRITE,1,makeConNode(interpret($3).value));	}
	|expr EQUALS expr	{$$ = makeOperNode(EQUALS,2,$1,$3)	;	}
	|expr '<' expr		{$$ = makeOperNode('<',2,$1,$3);		}
	|expr '>' expr		{$$ = makeOperNode('>',2,$1,$3);		}
	|expr LE expr		{$$ = makeOperNode(LE,2,$1,$3);			}
	|expr GE expr		{$$ = makeOperNode(GE,2,$1,$3);			}

	|expr
	;

expr :
	 expr '+' expr 		{$$ = makeOperNode('+',2,$1,$3);	}
	|expr '-' expr		{$$ = makeOperNode('-',2,$1,$3);	}
	|expr '*' expr		{$$ = makeOperNode('*',2,$1,$3);	}
	|expr '/' expr		{if (interpret($3).value!=0)
					$$ = makeOperNode('/',2,$1,$3);	
				else
					divError = true;
					
					
				}
	|VAR '=' expr		{$$ = makeOperNode('=',2,makeVarNode($1),$3);	}
	|INTEGER		{$$ = makeConNode($1);}
	|VAR			{$$ = makeVarNode($1);}
	|EXIT			{return 0;		}				
	;
%%

int main()
{
yyparse();
return 0;
}


void yyerror(char * s)
{
printf("%s\n",s);
}


	
Node * makeConNode(int value)
{

Node * p;
if((p =malloc(sizeof(Node))) == NULL)
	{
	printf("No memory\n");
	exit(0);
	}
p->nodeType = CONSTANT;
p->con.value = value;
return p;
}

Node * makeVarNode(char id)
{
Node *p;
if((p =malloc(sizeof(Node))) == NULL)
	{
	printf("No memory\n");
	exit(0);
	}
p->nodeType = VARIABLE;
p->var.id = id - 'a';
return p;
}

Node * makeOperNode(int oper,int nops,...)
{

va_list temp_args;
va_start(temp_args,nops);

Node * p;
if((p =malloc(sizeof(Node))) == NULL)
	{
	printf("No memory\n");
	exit(0);
	}

p->nodeType = OPERATOR;
p->oper.op = oper;
p->oper.nops = nops;

if((p->oper.operands = malloc(nops * sizeof(Node)))==NULL)
	{
	printf("No memory\n");
	exit(0);
	}
	
int i=0;
for(i=0;i<nops;i++)
{
p->oper.operands[i] = *va_arg(temp_args,Node*);
}

return p;
}


struct returnType interpret(Node * root)
{

ret.printable = true;

if(!root)
	{
	ret.printable = false;
	return ret;
	}


switch(root->nodeType)
{
case CONSTANT:
	{
	;
	ret.value = root->con.value;
	return ret;
	break;
	}

case VARIABLE:
	{
	if(sym[root->var.id]==NULL)
		{
		printf("Error: Variable %c not initialized\n",root->var.id+'a');
		ret.printable = false;
		return ret;
		}
	ret.value = *sym[root->var.id];
	return ret;
	break;
	}

case OPERATOR:
	{
	
	switch(root->oper.op)
	{
		case '+':
			{
			ret.value = interpret(&root->oper.operands[0]).value + interpret(&root->oper.operands[1]).value;
			return ret;
			break;
			}

		case '-':
			{
			ret.value = interpret(&root->oper.operands[0]).value - interpret(&root->oper.operands[1]).value;
			return ret;
			break;
			}
	
		case '*':
			{
			ret.value = interpret(&root->oper.operands[0]).value * interpret(&root->oper.operands[1]).value;
			return ret;
			break;
			}
	
		case '/':
			{
			ret.value = interpret(&root->oper.operands[0]).value / interpret(&root->oper.operands[1]).value;
			return ret;
			break;
			}

		case '=':
			{
			if (sym[root->oper.operands[0].var.id]==NULL)
				sym[root->oper.operands[0].var.id] = malloc(sizeof(int));

			*sym[root->oper.operands[0].var.id] = interpret(&root->oper.operands[1]).value;
			ret.printable = false;
			return ret;
			break;
			}	
			
		case EQUALS:
			{
			
			if (interpret(&root->oper.operands[0]).printable==true)
			{
			if (interpret(&root->oper.operands[0]).value==interpret(&root->oper.operands[1]).value)
				printf("True\n");
			else
				printf("False\n");
			}
			ret.printable = false;
			return ret;
				
			}

		case '<':
			{
			if (interpret(&root->oper.operands[0]).printable==true)
			{
			if (interpret(&root->oper.operands[0]).value<interpret(&root->oper.operands[1]).value)
				printf("True\n");
			else
				printf("False\n");
			}
			ret.printable = false;
			return ret;
				
			}

		case '>':
			{
			if (interpret(&root->oper.operands[0]).printable==true)
			{
			if (interpret(&root->oper.operands[0]).value>interpret(&root->oper.operands[1]).value)
				printf("True\n");
			else
				printf("False\n");
			}
			ret.printable = false;
			return ret;
				
			}

		case LE:
			{
			if (interpret(&root->oper.operands[0]).printable==true)
			{
			if (interpret(&root->oper.operands[0]).value<=interpret(&root->oper.operands[1]).value)
				printf("True\n");
			else
				printf("False\n");
			}
			ret.printable = false;
			return ret;
				
			}

		case GE:
			{
			if (interpret(&root->oper.operands[0]).printable==true)
			{
			if (interpret(&root->oper.operands[0]).value>=interpret(&root->oper.operands[1]).value)
				printf("True\n");
			else
				printf("False\n");
			}
			ret.printable = false;
			return ret;
				
			}
	
		case READ:
			{
			
			if (sym[root->oper.operands[0].var.id]==NULL)
				sym[root->oper.operands[0].var.id] = malloc(sizeof(int));

			scanf("%d\n",sym[root->oper.operands[0].var.id]);
			
			ret.printable = false;
			return ret;
			break;
			}

		case WRITE:
			{
			if(root->oper.operands[0].nodeType == VARIABLE)
			{
			 if (sym[root->oper.operands[0].var.id]==NULL)
				printf("Error: Variable %c Not initialized\n",root->oper.operands[0].var.id+'a');

			 else
				printf("%d\n",*sym[root->oper.operands[0].var.id]);
			}

			else
				printf("%d\n",root->oper.operands[0].con.value);
			ret.printable = false;
			return ret;
			break;
			}
	}
	}
}
}

void freeNode (Node * node)
{
switch(node->nodeType)
{
case CONSTANT:
	{
	
	free(node);
	break;
	}

case VARIABLE:
	{
	sym[node->var.id] = 0;
	free(node);
	break;
	}

case OPERATOR:
	{
	
	freeNode(&node->oper.operands[0]);
	freeNode(&node->oper.operands[1]);
	free(&node->oper.op);
	free(node);
	break;
	}
}
}








