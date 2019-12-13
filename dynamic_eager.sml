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
    
    | evalDE (env, Var x) = #1find(env, x) (*cerchiamo semplicemente x nell'ambiente: visto che siamo eager è già tutto valutato. NB: prendiamo il primo elemento*)
    
    | evalDE (env, Let (x, m, n)) = evalDE(Concat(x, evalDE(m), Empty, env), n) (*valutiamo m, creiamo l'ambiente env(x, m), e poi valutiamo n in quell'ambiente*)

    | evalDE(env, App(m, n)) = let val f = evalDE(env, m) in (*valutiamo m e deve essere Fn*)
                                
                               end
    | evalDE (env, _) = Const 42;

evalDE(Empty, Sum(Const 41, Fn (Name "x", Const 5)));