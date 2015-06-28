%token <int> INT
%token <float> FLOAT
%token ADD
%token SUB
%token MUL
%token DIV
%token LEFT_PAREN
%token RIGHT_PAREN
%token EOF

%start<Ast.ast option> prog

%%

primary:
    | i = INT { Ast.Int i }
    | x = FLOAT { Ast.Float x }
    | LEFT_PAREN; x = expr; RIGHT_PAREN { x }
    ;

mul_expr:
    | p = primary { p }
    | lhs = mul_expr; MUL; rhs = primary { Ast.Mul (lhs, rhs) }
    | lhs = mul_expr; DIV; rhs = primary { Ast.Div (lhs, rhs) }
    ;

add_expr:
    | m = mul_expr { m }
    | lhs = add_expr; ADD; rhs = mul_expr { Ast.Add (lhs, rhs) }
    | lhs = add_expr; SUB; rhs = mul_expr { Ast.Sub (lhs, rhs) }
    ;

expr:
    | a = add_expr { a }
    ;

prog:
    | EOF { None }
    | e = expr; EOF { Some e }
    ;
