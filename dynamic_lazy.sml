use "syntax.sml";

(* valuta espressioni
 *
 * eval: ENV * FUN -> FUN *)
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
  
  | evalDL (env, Fn(x, m)) = Fn(x, m);
                             


(* Test *)
val x = Name "x";
val e = Concat(Name "x", Const 3, Empty, Empty);

evalDL(e, Let(x, Const 2, Sum(Var x, Var x)));
evalDL(e, Fn(x, Var x));
