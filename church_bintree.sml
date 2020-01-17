
(* use "dynamic_lazy.sml"; (* VarNotFound perchè non si memorizza l'ambiente in Fn *) *)
use "static_eager.sml"; 

(* church numbers *) 

(* one = fn x => fn y => x y *)
val one = Fn(Name "x", Fn(Name "y", App(Var(Name "x"), Var(Name "y"))));

(* sum = fn w => fn z => fn x => fn y => w x(z x y) *)
val sum = Fn(Name "w", Fn(Name "z", Fn(Name "x", Fn(Name "y", 
 App(App(Var(Name "w"), Var(Name "x")), 
  App(App(Var(Name "z"), Var(Name "x")),Var(Name "y"))
 )))));

(* decode = fn z => z(fn x => x+1)0 *)
val decode = Fn(Name "z", 
 App(
 App(Var(Name "z"), Fn(Name "x", Sum(Var(Name "x"), Const 1))), Const 0));



 let val k = #1(evalSE(Empty,  App(decode, one))) in 
   case k of 
        Const k => k
      | _ => raise VarNotFound (* eccezione a caso *)
 end;

(* church booleans *) 

(* false = fn x => fn y => y *)
val False = Fn(Name "x", Fn(Name "y", Var(Name "y")));

(* true = fn x => fn y => x *)
val True = Fn(Name "x", Fn(Name "y", Var(Name "x")));

(* church binary trees *)

(* albero vuoto *)
val empty = Fn(Name "b", Fn(Name "l", Fn(Name "r",
 App(App(True, False), False))));

(* albero non vuoto *)
val node = Fn(Name "b", Fn(Name "l", Fn(Name "r",
 App(App(False, Var(Name "l")), Var(Name "r")))));

(* ricorsore di punto fisso *)
val Y = Fn(Name "f", 
 App(Fn(Name "x", App(Var(Name "f"), App(Var(Name "x"), Var(Name "x")))),
 Fn(Name "x", App(Var(Name "f"), App(Var(Name "x"), Var(Name "x"))))));

(* F *)
val F = Fn(Name "f", Fn(Name "x", Fn(Name "b", Fn(Name "l", Fn(Name "r",
 App(App(Var(Name "b"), one), App(App(sum, 
 App(Var(Name "f"), Var(Name "l"))), App(Var(Name "f"), Var(Name "r"))))))))); 


(* fun leaves empty = 1 
 *   | leaves node = (leaves (getLeft node)) + (leaves (getRight node)) *)
val leaves = Fn(Name "b", Fn(Name "l", Fn(Name "r",
 App(App(Var(Name "b"), one), App(App(sum, 
 App(App(Y,F), Var(Name "l"))), App(App(Y,F), Var(Name "r"))))))); 

val one_node = Fn(Name "b", Fn(Name "l", Fn(Name "r",
 App(App(False, empty), empty))));

let val k = #1(evalSE(Empty, App(decode, App(leaves, one_node)))) in 
   case k of 
        Const k => k
      | _ => raise VarNotFound (* eccezione a caso *)
 end;
