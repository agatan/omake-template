{
open Parser
open Lexing

exception SyntaxError of string
}

let digit = ['0'-'9']

let int = '-'? digit+

let frac = '.' digit*
let exp = ['e' 'E'] ['-' '+']? digit+
let float = digit* frac? exp?

let white = [' ' '\t']
let newline = ['\n' '\r'] | "\r\n"

rule read =
  parse
    | white { read lexbuf }
    | newline { new_line lexbuf; read lexbuf }
    | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
    | float { FLOAT ( float_of_string (Lexing.lexeme lexbuf)) }
    | '+' { ADD }
    | '-' { SUB }
    | '*' { MUL }
    | '/' { DIV }
    | '(' { LEFT_PAREN }
    | ')' { RIGHT_PAREN }
    | _  { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
    | eof { EOF }
