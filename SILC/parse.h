#include<stdbool.h>
#include<stdarg.h>

typedef enum  {CONSTANT,OPERATOR,VARIABLE} NodeType ;

typedef struct typetable TypeTable;
typedef struct  typetableid
{
char * name;
TypeTable * type;
struct typetableid * next;
}TypeTableId;

typedef struct typetable
{
char * name;
TypeTableId * members;
struct typetable * next;
}TypeTable;

typedef struct 
{
int value;
}ConNode;

typedef struct 
{
char * name;
struct NodeTag *index;
struct ArgList * argList;
int size;
}VarNode;

typedef struct 
{
int op;
int nops;
struct NodeTag *operands;
}OperNode;

typedef struct NodeTag
{
NodeType nodeType;
TypeTable *type;
int lineNo;
union
{
ConNode con;
OperNode oper;
VarNode var;
};

}Node;

typedef struct ArgList
{
char * name;
TypeTable *type;
Node * value;
int ref;
struct ArgList * next;
}ArgList;


typedef struct LSymTable
{
char * name;
TypeTable *type;
int size;
int binding;
int ref;
struct LSymTable * next;
}LTable;

typedef struct SymTable
{
char * name;
TypeTable *type;
int size;
int binding;
ArgList * args;
LTable * symbolTable;
struct SymTable * next;
}STable;

typedef struct IdList
{
char * name;
TypeTable *type;
int size;
ArgList * argList;
int ref;
struct IDList * next;
}IdList;


//function declarations
Node * makeConNode(TypeTable *,int);
Node * makeVarNode(char *,Node *,ArgList *,int);
Node * makeOperNode(int,int,...);

int interpret(Node *);
void semanticAnalyzer(Node *);
void freeNode(Node *);

void initializeTypeTable();
void typeTableInstall();

void makeSTable(IdList *,TypeTable *);
STable * GInstall(char *,TypeTable *,int,ArgList *, int);
STable * LookUp(char *);

void makeLTable(IdList *,TypeTable *);
LTable * LInstall(char *,TypeTable *,int);
LTable * LLookUp(char *,LTable *);

ArgList * makeCallList(ArgList *,Node *);

IdList * makeIdList(IdList *,char *,TypeTable *,int,ArgList *,int);

void setVariableValue(char * name,Node * index);
void getVariableValue(char * name,Node * index);

void showContents(STable *);
void LshowContents(LTable *);
void showTypeTable();


//global variables
STable *sTableBeg=NULL,*sTableEnd;
LTable *lTableBeg=NULL,*lTableEnd;
IdList * idListBeg=NULL, *idListEnd;
TypeTable *typeTableBeg=NULL,*typeTableEnd;
TypeTable *INT,*BOOLEAN;
int lineNo;
bool has_error = false,has_main=false;
FILE * out;
int reg_count=-1;
int mem = 0,if_count=1,while_count=1,fmem=1;


