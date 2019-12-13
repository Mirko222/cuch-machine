use "syntax.sml";

fun evalDE (env, Const k) = Const k
    
    | evalDE (env, Fn(x, M)) = Fn(x, M)
    
    | evalDE (env, Sum(a, b)) = let val k1 = evalDE(env, a) in (*valutiamo a*)
                                let val k2 = evalDE(env, b) in (*valutiamo b*)
                                case k1 of Const k1 => ( (*a e b devono essere una costante intera*)
                                        case k2 of Const k2 => Const (k1+k2) (*possiamo effettuare la somma*)
                                                | _ => raise CannotPerformSum  (*altrimenti la somma non può essere effettuata*)
                                    )
                                    | _ => raise CannotPerformSum
                                end end
    
    | evalDE (env, Var x) = #1(find(env, x)) (*cerchiamo semplicemente x nell'ambiente: visto che siamo eager è già tutto valutato. NB: prendiamo il primo elemento*)
    
    | evalDE (env, Let (x, m, n)) = (evalDE(Concat(x, evalDE(env, m), Empty, env), n)) (*valutiamo m, creiamo l'ambiente env(x, m), e poi valutiamo n in quell'ambiente*)

    | evalDE(env, App(m, n)) = let val f = evalDE(env, m) in (*valutiamo m e deve essere Fn*)
                                case f of Fn(x, c) => evalDE(Concat(x, evalDE(env, n), Empty, env), c) (*valutiamo n, e poi valutiamo c aumentando l'ambiente con (x, n valutato)*)
                                | _ => raise CannotPerformApp
                               end;

(*test*)
evalDE(Concat(Name "x", Const 10, Empty, Empty), Sum(Const 41, Var (Name "x"))); (* (x, 10) |- 41+x  -->  51*)
evalDE(Empty, Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10))); (* let y=5 in y+10  --> 15 *)
evalDE(Empty, App ( Fn(Name "x", Sum(Var (Name "x"), Const 1)), Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)) )); (* (Fn x => x+1) (let y=5 in y+10)  --> 16*)

(* evalDE(Empty, App(Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)), Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)))); (* (let y=5 in y+10) (let y=5 in y+10)  --> CannotPerformApp *) *)
(* evalDE(Empty, Sum(Var (Name "x"), Const 19)); (* x+19 --> VarNotFound *) *)
(* evalDE(Empty, Sum ( Fn(Name "x", Sum(Var (Name "x"), Const 1)), Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)) )); (* (Fn x => x+1) + (let y=5 in y+10)  --> CannotPerformSum*) *)

evalDE(Empty, App( Fn(Name "x", App(Var (Name "x"), Const 5)), Fn(Name "x", Sum(Var(Name "x"), Const 10))) ); (* (Fn x => x 5) (Fn x => x+10) *)
evalDE(Empty, App( Fn(Name "x", Var (Name "x")), Fn(Name "x", Sum(Var(Name "x"), Const 10))) ); (* (Fn x => x) (Fn x => x+10) *)

evalDE(Empty, App( Fn(Name "x", App(Var(Name "x"), Var(Name "x"))), Fn(Name "x", App(Var(Name "x"), Var(Name "x"))) ) ); (* (Fn x => xx) (Fn x => xx)  --> loop :) *)