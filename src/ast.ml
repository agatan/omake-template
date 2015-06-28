open! Core.Std

type ast =
  | Int of int
  | Float of float
  | Add of ast * ast
  | Sub of ast * ast
  | Mul of ast * ast
  | Div of ast * ast
             [@@deriving show]
