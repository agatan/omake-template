open! Core.Std

type eval_result = [
  | `Int of int
  | `Float of float
]

let rec eval = function
  | Ast.Int i -> `Int i
  | Ast.Float x -> `Float x
  | Ast.Add (lhs, rhs) -> begin match (eval lhs, eval rhs) with
      | `Int l, `Int r -> `Int (l + r)
      | `Float l, `Int r -> `Float (l +. Float.of_int r)
      | `Int l, `Float r -> `Float (Float.of_int l +. r)
      | `Float l, `Float r -> `Float (l +. r)
    end
  | Ast.Sub (lhs, rhs) -> begin match (eval lhs, eval rhs) with
      | `Int l, `Int r -> `Int (l - r)
      | `Float l, `Int r -> `Float (l -. Float.of_int r)
      | `Int l, `Float r -> `Float (Float.of_int l -. r)
      | `Float l, `Float r -> `Float (l -. r)
    end
  | Ast.Mul (lhs, rhs) -> begin match (eval lhs, eval rhs) with
      | `Int l, `Int r -> `Int (l * r)
      | `Float l, `Int r -> `Float (l *. Float.of_int r)
      | `Int l, `Float r -> `Float (Float.of_int l *. r)
      | `Float l, `Float r -> `Float (l *. r)
    end
  | Ast.Div (lhs, rhs) -> begin match (eval lhs, eval rhs) with
      | `Int l, `Int r -> `Int (l / r)
      | `Float l, `Int r -> `Float (l /. Float.of_int r)
      | `Int l, `Float r -> `Float (Float.of_int l /. r)
      | `Float l, `Float r -> `Float (l /. r)
    end
