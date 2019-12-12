datatype VAR = Name of string;

datatype FUN = Empty
             | Const of int
             | Var of VAR
             | Fn of VAR*FUN 
             | Let of VAR*FUN*FUN;

(* verifica uguaglianza tra due Var, = funziona ma da' un warning (su
 * StackOverflow dicono di ignorarlo e rende solo il codice un po' meno
 * efficiente. In "lazy.sml" ci sta un test che puoi eseguire *)
fun equal (Var (Name x)) (Var (Name y)) = if x=y then true else false; 

