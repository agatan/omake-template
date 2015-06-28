open! Core.Std

module L = Llvm

let context = L.global_context ()
let the_module = L.create_module context "callvm"
let builder = L.builder context
let i8_type = L.i8_type context
let i32_type = L.i32_type context
let double_type = L.double_type context

let rec codegen_ast = function
  | Ast.Int i -> L.const_int i32_type i
  | Ast.Float x -> L.const_float double_type x
  | Ast.Add (lhs, rhs) ->
    let (l, r) = (codegen_ast lhs, codegen_ast rhs) in
    L.build_add l r "addtmp" builder
  | Ast.Sub (lhs, rhs) ->
    let (l, r) = (codegen_ast lhs, codegen_ast rhs) in
    L.build_sub l r "subtmp" builder
  | Ast.Mul (lhs, rhs) ->
    let (l, r) = (codegen_ast lhs, codegen_ast rhs) in
    L.build_mul l r "multmp" builder
  | Ast.Div (lhs, rhs) ->
    let (l, r) = (codegen_ast lhs, codegen_ast rhs) in
    L.build_sdiv l r "sdivtmp" builder

let cnt = ref 0
let new_func_name () =
  let name = sprintf "toplevel%d" !cnt in
  cnt := !cnt + 1;
  name

let decl_printf () =
  let ft = L.var_arg_function_type i32_type [| (L.pointer_type i8_type) |] in
  L.declare_function "printf" ft the_module

let init () =
  let str = Llvm.const_string context "%d\n" in
  Llvm.define_global "str" str the_module |> ignore;
  let pf = decl_printf () in
  let ft = L.function_type (L.void_type context) [| i32_type |] in
  let f = L.declare_function "print_i32" ft the_module in
  let bb = L.append_block context "entry" f in
  L.position_at_end bb builder;
  ignore (L.build_call pf [| str; (L.params f).(0) |] "retval" builder)

let () = init ()

let codegen ast =
  let args = [| |] in
  let ft = L.function_type i32_type args in
  let f = L.declare_function (new_func_name ()) ft the_module in
  let bb = L.append_block context "entry" f in
  L.position_at_end bb builder;
  let ret_val = codegen_ast ast in
  ignore (L.build_ret ret_val builder);
  Llvm_analysis.assert_valid_function f;
  f
