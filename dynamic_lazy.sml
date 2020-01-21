use "syntax.sml";

(* evalDL: ENV * FUN -> FUN *)
fun evalDL (env, Const k) = Const k
  (* cerca x nell'ambiente env e se lo trova lo valuta *)
  | evalDL (env, Var x) = evalDL(env, #1( find(env, x) ))
 
  | evalDL (env, Sum(a, b)) =   let val k1 = evalDL(env, a) in (* valuta a *)
                                let val k2 = evalDL(env, b) in (* valuta b *)
                                case k1 of 
                                     (* per eseguire la somma k1 e k2 devono
                                      * essere Const *)
                                     Const k1 => (
                                        case k2 of 
                                             Const k2 => Const (k1+k2)
                                           | _ => raise CannotPerformSum
                                     )
                                   | _ => raise CannotPerformSum
                                end
                                end

  | evalDL (env, Let(x, m, n)) = evalDL(Concat(x, m, env, env), n)
  
  | evalDL (env, Fn(x, m)) = Fn(x, m)

  | evalDL (env, App(m, n)) =   let val f = evalDL(env, m) in (* valuta m *) 
                                case f of 
                                     (* per eseguire l'applicazione
                                      * m deve essere della forma Fn *)
                                     Fn(x, m1) => evalDL(Concat(x, n, env, env), m1)
                                   | _ => raise CannotPerformApp
                                end;

                             


(* Test *)

(* x+19 --> VarNotFound *)
(* evalDL(Empty, Sum(Var (Name "x"), Const 19)); *)

(* 41 + (fn x => 5) --> CannotPerformSum *) 
(* evalDL(Empty, Sum(Const 41, Fn (Name "x", Const 5))); *)

(* (let y=5 in y+10) (let y=5 in y+10)  --> CannotPerformApp *) 
(* evalDL(Empty,  App(Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)),
 * Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)))); *)

(* (x, 10) |- 41+x --> 51 *)
evalDL(Concat(Name "x", Const 10, Empty, Empty), Sum(Const 41, Var (Name "x")));

(* let y=5 in y+10  --> 15 *)
evalDL(Empty, Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)));

(* (Fn x => x+1) (let y=5 in y+10)  --> 16 *)
evalDL(Empty, App ( Fn(Name "x", Sum(Var (Name "x"), Const 1)), Let (Name "y",
 Const 5, Sum(Var (Name "y"), Const 10)) ));

(* (Fn x => xx) (Fn x => xx)  --> loop :) *)
(* evalDL(Empty, App( Fn(Name "x", App(Var(Name "x"), Var(Name "x"))), Fn(Name "x",
 App(Var(Name "x"), Var(Name "x"))) ) ); *)

(* let x=2 in x+x *)
evalDL(Empty, Let(Name "x", Const 2, Sum(Var (Name "x"), Var (Name "x"))));

(* (x, 3) |- (fn y => y) x --> 3 *)
evalDL(Concat(Name "x", Const 3, Empty, Empty), 
 App( Fn(Name "y", Var(Name "y")), Var (Name "x") ));

(* (y, 2) |- let x=y+1 in (let y=5 in x) --> 6 *)
evalDL(Concat(Name "y", Const 2, Empty, Empty),
  Let(Name "x", Sum(Var(Name "y"), Const 1), Let(Name "y", Const 5, Var(Name "x")) ));

(* (x, 3) |-  (fn x => x) x --> cattura (?) *) 
 (* evalDL(Concat(Name "x", Const 3, Empty, Empty), 
 App(Fn(Name "x", Var (Name "x")), Var (Name "x"))); *)


(* (x, 3) |-  (fn y => y) x --> 3 *) 
 evalDL(Concat(Name "x", Const 3, Empty, Empty), 
 App(Fn(Name "y", Var (Name "y")), Var (Name "x")));
