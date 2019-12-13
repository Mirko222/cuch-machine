(*algebra delle variabili*)
datatype VAR = Name of string;

(*algebra induttiva di FUN*)
datatype FUN = Const of int (*le costanti sono solo interi*)
             | Sum of FUN * FUN (*FUN * FUN, ma in realtà devono essere valutati e devono venire costanti*)
             | Var of VAR
             | Fn of VAR * FUN (*usiamo Fn per rappresentare anche le chiusure: perché alla fine le chiusure sono solo una riscrittura di Fn*) 
             | Let of VAR * FUN * FUN
             | App of FUN * FUN; (*applicazione di Fn: il primo argomento deve venire fuori Fn*)

(*ambiente: è in sostanza una lista, ma conviene farla come datatype
perché nelle semantiche statiche diventa scomodo (forse impossibile?) farlo con le liste, a causa della definizione ricorsiva di ambiente *)
(*NB: usiamo un solo ambiente per tutte le semantiche, gestiremo poi nelle semantiche le varie cose
per esempio: quando valutiamo eager, il secondo elemento può essere solo Fn (una chiusura) o Const, 
             quando valutiamo dinamico, il terzo parametro verrà ignorato (perché è l'ambiente in cui valutare, ma in eager è sempre quello attuale),
             ecc..*)
datatype ENV = Empty (*ambiente vuoto*)
    | Concat of VAR * FUN * ENV * ENV; (* variabile, valore, ambiente in cui valutare, resto della lista dell'ambiente: è in sostanza una lista di (VAR, FUN, ENV) *) 

fun varEq (Name x, Name y) = x=y; (*confronta due tipi VAR*)

exception VarNotFound; (*eccezione sollevata se non si trova una variabile in un'ambiente*)
exception CannotPerformSum; (*eccezione se si prova a sommare cose che non si possono sommare: Fn + x*)

(*cerca una VAR in un ENV*)
fun find (Empty, x) = raise VarNotFound (*x sicuramente non è nell'ambiente vuoto*)
  | find (Concat(x, m, e1, e), y) = if varEq(x, y) then (m, e1) else find(e, y);


(*Esempi di come usare i costruttori: *)
(*
val x = Let (Name "x", Const 5, Sum(Var (Name "x"), Const 10));  // let x=5 in (sum x + 10)
val y = App ( Fn(Name "x", Sum(Var (Name "x"), Const 1)), Let (Name "y", Const 5, Sum(Var (Name "y"), Const 10)) ); // (Fn x => x+1) (let y=5 in y+10)

val env1 = Concat(Name "x", Const 1, Empty, Concat(Name "y", Const 10, Empty, Empty));
*)

(*Ci serve veramente?*)
(* verifica uguaglianza tra due Var, In "lazy.sml" ci sta un test che puoi eseguire *)
fun equal (Var (Name x)) (Var (Name y)) = (x=y)  (*if x=y then true else false; *)
    | equal _ _ = false; (*qualsiasi altra cosa dà false*)