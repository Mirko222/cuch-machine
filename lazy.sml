use "syntax.sml";

datatype ENV = Emp 
             | Env of (VAR*FUN*ENV) list;

(* da definire find che trova una variabile in un ambiente e restituisce la
 * chiusura *) 

(* lazy dinamico *)

(* ovviamente non e' finita ma vogliamo "eval (e, Empty)" o "eval e Empty"? *) 
fun eval (e, Empty) = Empty
  | eval (e, Const n) = Const n;

(* Test *)
val x = Var (Name "x");
val y = Var (Name "y");
val z = Var (Name "x");

equal x x;
x = x;
equal x y;
x = y;
equal x z;
x = z;
