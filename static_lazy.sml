use "syntax.sml";

fun evalSL (env, Const k) = (Const k, Empty)
    
    | evalSL (env, Fn(x, M)) = (Fn(x, M), env)
    
    | evalSL (env, Sum(a, b)) = let val k1 = #1(evalSL(env, a)) in (*valutiamo a*)
                                let val k2 = #1(evalSL(env, b)) in (*valutiamo b*)
                                case k1 of Const k1 => ( (*a e b devono essere una costante intera*)
                                        case k2 of Const k2 => (Const (k1+k2), Empty) (*possiamo effettuare la somma*)
                                                | _ => raise CannotPerformSum  (*altrimenti la somma non può essere effettuata*)
                                    )
                                    | _ => raise CannotPerformSum
                                end end

    | evalSL (env, Var x) = let val c=find(env, x) in (*trova x nell'ambiente*)
                                evalSL(#2(c), #1(c)) (*poi valuta l'espressione associata ad x nell'ambiente salvato*)
                            end
        
    | evalSL (env, Let (x, m, n)) = (evalSL(Concat(x, m, env, env), n)) (*aumentiamo l'ambiente con (x, m, env) senza valutare m, poi valutiamo n*)

    | evalSL(env, App(m, n)) = let val f = evalSL(env, m) in (*valutiamo m e deve essere Fn*)
                                case #1(f) of Fn(x, c) => evalSL(Concat(x, n, env, #2(f)), c) (*nell'ambiente associato a Fn, aumentato con (x, n, env), valutiamo il corpo della funzione*)
                                | _ => raise CannotPerformApp
                               end;


(*test*)
evalSL(Concat(Name "x", Const 10, Empty, Empty), Sum(Const 41, Var (Name "x"))); (* (x, 10) |- 41+x  -->  51*)
evalSL(Empty, Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10))); (* let y=5 in y+10  --> 15 *)
evalSL(Empty, App ( Fn(Name "x", Sum(Var (Name "x"), Const 1)), Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)) )); (* (Fn x => x+1) (let y=5 in y+10)  --> 16*)

(* evalSL(Empty, App(Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)), Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)))); (* (let y=5 in y+10) (let y=5 in y+10)  --> CannotPerformApp *) *)
(* evalSL(Empty, Sum(Var (Name "x"), Const 19)); (* x+19 --> VarNotFound *) *)
(* evalSL(Empty, Sum ( Fn(Name "x", Sum(Var (Name "x"), Const 1)), Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)) )); (* (Fn x => x+1) + (let y=5 in y+10)  --> CannotPerformSum*) *)


evalSL(Empty, App( Fn(Name "x", App(Var (Name "x"), Const 5)), Fn(Name "x", Sum(Var(Name "x"), Const 10))) ); (* (Fn x => x 5) (Fn x => x+10) --> 15*)
evalSL(Empty, App( Fn(Name "x", Var (Name "x")), Fn(Name "x", Sum(Var(Name "x"), Const 10))) ); (* (Fn x => x) (Fn x => x+10)  --> (x, x+10)*)

(* (x, 3) |-  (fn x => x) x --> 3 *) 
evalSL(Concat(Name "x", Const 3, Empty, Empty), App(Fn(Name "x", Var (Name "x")), Var (Name "x"))); 

(* evalSL(Empty, App( Fn(Name "x", App(Var(Name "x"), Var(Name "x"))), Fn(Name "x", App(Var(Name "x"), Var(Name "x"))) ) ); (* (Fn x => xx) (Fn x => xx)  --> loop :) *) *)

(* let x = [(Fn x=>xx)(Fn x=>xx)] in 42  --> 42*)
evalSL(Empty, Let(Name "x", App( Fn(Name "x", App(Var(Name "x"), Var(Name "x"))), Fn(Name "x", App(Var(Name "x"), Var(Name "x"))) ), Const 42));