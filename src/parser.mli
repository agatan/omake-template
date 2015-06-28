(* The type of tokens. *)
type token = 
  | SUB
  | RIGHT_PAREN
  | MUL
  | LEFT_PAREN
  | INT of (int)
  | FLOAT of (float)
  | EOF
  | DIV
  | ADD

(* This exception is raised by the monolithic API functions. *)
exception Error

(* The monolithic API. *)
val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.ast option)

