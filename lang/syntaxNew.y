
%{
  import java.io.*;
%}
      
%token NL          /* newline  */
%token  INT, CHAR, BOOLEAN, IF, ELSE, WHILE, RETURN, FUNCDEFBLOCK, VARBLOCK, 
CODEBLOCK, INPUT, PRINT, TRUE, FALSE, AND_OP, OR_OP, LE_OP, GE_OP, EQ_OP, NE_OP
%token <ival> CONSTANT, CHARACTER
%token <sval> VARIABLE, OPERATOR, LITERAL



%type <obj> expression

%left '-' '+'
%left variables
%left '*' '/'
//%left NEG          /* negation--unary minus */
//%right '^'       /* exponentiation        */
%start program

%%

  program
  : FUNCDEFBLOCK':' func_def_list VARBLOCK':' declaration_list CODEBLOCK':' statement_list    // полная программа
  { System.out.printf("\nProgram "); }
  | VARBLOCK':' declaration_list //CODEBLOCK':' statement_list                     // если нет пользовательских функций
  { System.out.printf("\nProgram "); }
  | FUNCDEFBLOCK':' func_def_list CODEBLOCK':' statement_list                   // если нет объявлений переменных
  { System.out.printf("\nProgram "); }
  | CODEBLOCK':' statement_list                                 // если нет ничего кроме кода
  { System.out.printf("\nProgram "); }
  ;

func_def_list         // "Накручиваем" объявления функций до нужного количеста
  : func_def  { System.out.printf("\nfunc_def_list "); } 
  | func_def_list func_def { System.out.printf("\nfunc_def_list "); }
  ;
func_def
  : type_specifier func_declorator compound_statement  // тип -- деклоратор   --  блок кода 
  { System.out.printf("\nfunc_def "); }               // int     foo()       { code goes here }
  ;

type_specifier                       // спецификатор типа - ничего необычного
  : INT
  { System.out.printf("\nint_specificator "); }
  | CHAR
  { System.out.printf("\nchar_specificator "); }
  | BOOLEAN
  { System.out.printf("\nboolean_specificator "); }
  ;

func_declorator
  : VARIABLE '('')'                       // пустой лист входных параметров
  { System.out.printf ("\nfunc_declorator "); }
  | VARIABLE '('parametr_declaration_list')'            // очевидно, не пустой, но это не точно
  { System.out.printf ("\nfunc_declorator "); }
  ;
parametr_declaration_list
  : type_specifier VARIABLE {System.out.printf("\nparam_declaration_list");}
  | parametr_declaration_list',' type_specifier VARIABLE {System.out.printf("\nparam_declaration_list");}
  ;

compound_statement                  
  :'{''}'                        // лучший код - тот, которого нет
  { System.out.printf("\nempty compound_statement "); }
  |'{'statement_list'}'                // тут код уже есть... наверное
  { System.out.printf("\ncompound_statement "); }
  ;

statement_list                  
  : statement  {System.out.printf("\nstatement_list");}       
  | statement_list statement {System.out.printf("\nstatement_list");}
  ;

statement
  :/* expression';'                   
  { System.out.printf("\nexpression "); }
  | */
  IF'('conditions')'compound_statement %prec IFX     // if
  { System.out.printf("\nif <if>"); }
  | IF'('conditions')'compound_statement ELSE compound_statement    
  { System.out.printf("\nif else"); }
  | WHILE'('conditions')'compound_statement     // while
  { System.out.printf("\nwhile "); }
  | RETURN';'                      // return 
  { System.out.printf("\nreturn "); }
  | RETURN expression';'
  { System.out.printf("\nreturn "); }
  | INPUT'('expression')'';'               //input()
  { System.out.printf("\ninput() ");
    memoryManager.printProgram(); }
  | PRINT'('expression')'';'               //print()
  { System.out.printf("\nprint() "); 
  memoryManager.printProgram(); }
  | VARIABLE'('expression')'';'                //пользовательская функция
  { System.out.printf("\nUser_func() "); }
  | VARIABLE '=' expression';'                 //присваивание
  { System.out.printf("\nassignment"); }
  | VARIABLE '=' conditions ';'
  //| error';'
  ;

conditions :
  TRUE 
  | FALSE
  | expression'<'expression
  | expression'>'expression
  | expression GE_OP expression
  | expression LE_OP expression
  | expression EQ_OP expression
  | expression NE_OP expression
  | expression AND_OP expression
  | expression OR_OP expression

expression                  // Лень расписывать
  : VARIABLE //not implemented yet (Реализовать сначала список идентификаторов )
  | CONSTANT { $$ = new Expression(Types.CONSTANT, memoryManager.getAvailableShift(java.lang.Integer.BYTES), $1, memoryManager);}
  | LITERAL 
  | CHARACTER 
  | expression'+'expression  {
    $$ = new Expression(
        Types.COMPOSITE,
        memoryManager.getAvailableShift(java.lang.Integer.BYTES),
        $1,
        $3,
        Operations.ADD,
        memoryManager); 
    }       // и так ведь понятно
  | expression'-'expression {
  $$ = new Expression(
        Types.COMPOSITE,
        memoryManager.getAvailableShift(java.lang.Integer.BYTES),
        $1,
        $3,
        Operations.SUB,
        memoryManager); 
    }
  | expression'*'expression {
    $$ = new Expression(
        Types.COMPOSITE,
        memoryManager.getAvailableShift(java.lang.Integer.BYTES),
        $1,
        $3,
        Operations.MUL,
        memoryManager); 
    }
  | expression'/'expression {
    $$ = new Expression(
        Types.COMPOSITE,
        memoryManager.getAvailableShift(java.lang.Integer.BYTES),
        $1,
        $3,
        Operations.DIV,
        memoryManager); 
    }
  | '('expression')'
  //| error';'
  ;

declaration_list
  : declaration { System.out.printf("\ndeclaration_list");}
  | declaration_list declaration { System.out.printf("\ndeclaration_list");}
  ;

declaration
  : INT VARIABLE'='CONSTANT';'  { System.out.println("int " + $2 + " = " + $4); }
  | CHAR VARIABLE'='CHARACTER';' { System.out.printf("\nchar init declaration"); }
  | BOOLEAN VARIABLE'='TRUE';'  { System.out.printf("\nbool init declaration"); }
  | BOOLEAN VARIABLE'='FALSE';' { System.out.printf("\nbool init declaration"); }
  | INT VARIABLE';' { System.out.printf("\nno init declaration"); }
  | CHAR VARIABLE';' { System.out.printf("\nno init declaration"); }
  | BOOLEAN VARIABLE';' { System.out.printf("\nno init declaration"); }
  | error';' { System.out.printf("\nERROR");}
  ;

%%

  private Yylex lexer;
  private MemoryManager memoryManager = new MemoryManager();

  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }


  public void yyerror (String error) {
  	//ignore underflow exception 
    System.err.println ("Error :" + error);
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);
  }

  public static void main(String args[]) throws IOException {

    Parser yyparser;
    if ( args.length > 0 ) {
      yyparser = new Parser(new FileReader(args[0]));
    } else {
    	throw new IllegalStateException("В программу не передано исходного файла");
    }

    yyparser.yyparse();
   
  }
