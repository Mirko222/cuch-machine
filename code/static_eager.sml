use "syntax.sml";

(* evalSE: ENV * FUN -> FUN * ENV *)
fun evalSE (env, Const n) = (Const n, env)
  (* cerca x nell'ambiente ed essendo gia' valutato lo ritorna *)
  | evalSE (env, Var x) = find(env, x)

  | evalSE (env, Sum(a, b)) =   let val k1 = #1(evalSE(env, a)) in (* valuta a *)
                                let val k2 = #1(evalSE(env, b)) in (* valuta b *)
                                case k1 of
                                     Const k1 => (
                                        case k2 of 
                                             Const k2 => (Const (k1 + k2), env)
                                           | _ => raise CannotPerformSum
                                     )
                                   | _ => raise CannotPerformSum
                                end
                                end
  
  | evalSE (env, Let(x, m, n)) = evalSE(Concat(x, #1(evalSE(env,m)), env, env), n)

  | evalSE (env, Fn(x, m)) = (Fn(x, m), env)

  | evalSE (env, App(m, n)) =   let val f = evalSE(env, m) in (* valuto m *)
                                case #1(f) of 
                                     Fn(x, m1) => (
                                        evalSE(Concat(x, #1(evalSE(env, n)), #2(evalSE(env, n)), #2(f)), m1)
                                     ) 
                                   | _ => raise CannotPerformApp
                                end;


(* Test *) 

(* x+19 --> VarNotFound *)
(* #1(evalSE(Empty, Sum(Var (Name "x"), Const 19))); *)

(* 41 + (fn x => 5) --> CannotPerformSum *) 
(* #1(evalSE(Empty, Sum(Const 41, Fn (Name "x", Const 5)))); *)

(* (let y=5 in y+10) (let y=5 in y+10)  --> CannotPerformApp *) 
(* #1(evalSE(Empty,  App(Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)),
 * Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10))))); *)

(* (x, 10) |- 41+x --> 51 *)
#1(evalSE(Concat(Name "x", Const 10, Empty, Empty), 
 Sum(Const 41, Var (Name "x"))));

(* let y=5 in y+10  --> 15 *)
#1(evalSE(Empty, Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10))));

(* (Fn x => x+1) (let y=5 in y+10)  --> 16 *)
#1(evalSE(Empty, App ( Fn(Name "x", Sum(Var (Name "x"), Const 1)), Let (Name "y",
 Const 5, Sum(Var (Name "y"), Const 10)) )));

(* (Fn x => xx) (Fn x => xx)  --> loop :) *)
(* #1(evalSE(Empty, App( Fn(Name "x", App(Var(Name "x"), Var(Name "x"))), Fn(Name "x",
 App(Var(Name "x"), Var(Name "x"))) ) )); *)

(* let x=2 in x+x -> 4 *)
#1(evalSE(Empty, Let(Name "x", Const 2, Sum(Var (Name "x"), Var (Name "x")))));

(* (x, 3) |- (fn y => y) x --> 3 *)
#1(evalSE(Concat(Name "x", Const 3, Empty, Empty), 
 App( Fn(Name "y", Var(Name "y")), Var (Name "x") )));

(* (y, 2) |- let x=y+1 in (let y=5 in x) --> 3 *)
#1(evalSE(Concat(Name "y", Const 2, Empty, Empty),
  Let(Name "x", Sum(Var(Name "y"), Const 1), Let(Name "y", Const 5, Var(Name "x")) )));

(* (x, 3) |-  (fn x => x) x --> 3 *) 
 #1(evalSE(Concat(Name "x", Const 3, Empty, Empty), 
 App(Fn(Name "x", Var (Name "x")), Var (Name "x"))));
