use "syntax.sml";

(* lazy dinamica *)

(* serve per trovare una variabile in un ambiente
 * option ci evita di introdurre l'espressione vuota in FUN 
 *
 * find: ENV * VAR -> FUN option *)
fun find (Empty, x) = NONE 
  | find (Concat(x, m, e1, e), y) = if x = y then SOME m else find(e, y);

(* restituisce il valore int contenuto in un Const: int -> FUN 
 *
 * value: FUN option -> int option *)
fun value (SOME (Const n)) = SOME n
  | value _ = NONE; 

(* valuta espressioni
 *
 * eval: ENV * FUN -> FUN option *)
fun eval (e, Const n) = SOME (Const n)
  | eval (e, Var x) = find(e, x)
  | eval (e, Sum(a, b)) = 
  SOME (Const (valOf(value(eval(e, a))) + valOf(value(eval(e, b)))));
       (*fare let*) 

(* Test *)
val x = Name "x";
val e = Concat(Name "x", Const 3, Empty, Empty);
(* da' giustamente errore perche' si ha Sum(NONE, Const 2) e Sum: FUN * FUN -> FUN *) 
(* eval(Empty, Sum(Var x, Const 2));*)
eval(e, Sum(Var x, Const 2));

