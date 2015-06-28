open! Core.Std
open Lexing

let print_position outc lexbuf =
  let pos = lexbuf.lex_curr_p in
  fprintf outc "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parse_with_error lexbuf =
  try Parser.prog Lexer.read lexbuf with
  | Lexer.SyntaxError e ->
    fprintf stderr "%a: %s\n%!" print_position lexbuf e;
    None
  | Parser.Error ->
    fprintf stderr "%a: syntax error\n" print_position lexbuf;
    exit (-1)

let rec parse () =
  printf "user> %!";
  let line = read_line () in
  if line = "quit" then exit 0;
  begin match parse_with_error (Lexing.from_string line) with
  | Some ast ->
    print_endline (Ast.show_ast ast)
  | None -> ()
  end;
  parse ()

let parser_command =
  Command.basic ~summary:"parse input to abstract syntax tree"
    Command.Spec.empty
    parse

let rec eval () =
  printf "user> %!";
  let line = read_line () in
  if line = "quit" then exit 0;
  begin match parse_with_error (Lexing.from_string line) |> Option.map ~f:Eval.eval with
    | Some (`Int i) ->
      print_endline (string_of_int i)
    | Some (`Float x) ->
      printf "%.2f\n" x
    | None -> ()
  end;
  eval ()

let eval_command =
  Command.basic ~summary:"evaluate input expression"
    Command.Spec.empty
    eval

let rec codegen () =
  printf "user> %!";
  let line = read_line () in
  if line = "quit" then begin
    Llvm.dump_module Codegen.the_module;
    exit 0
  end;
  begin match parse_with_error (Lexing.from_string line) |> Option.map ~f:Codegen.codegen with
    | Some ir ->
      Llvm.dump_value ir
    | None -> ()
  end;
  codegen ()

let codegen_command =
  Command.basic ~summary:"code generate from input expression"
    Command.Spec.empty
    codegen

let () =
  Command.group ~summary:"Command Line Calculator"
    ["parse", parser_command; "eval", eval_command; "codegen", codegen_command]
  |> Command.run
