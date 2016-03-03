%{
#include<stdio.h>
%}

%token NUM

%left '+' '-'
%left '*' '/'



%%

program: program expr '\n'	{printf("\n");}	
	|error '\n'
	|		
	;

expr:
	 expr '+' expr	{printf("+ ");}
	|expr '-' expr  {printf("- ");}
	|expr '*' expr  {printf("* ");}
	|expr '/' expr  {printf("/ ");}
	|NUM		{printf("NUM ");}
	;

%%

int main()
{
yyparse();
return 0;
}





