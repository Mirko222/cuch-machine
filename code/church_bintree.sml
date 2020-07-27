use "static_lazy.sml";  (*static_eager va in loop... probabilmente perché cerca di "valutare il ricorsore" *)

(*utility per booleani di church*)

(*valuta un booleano di church (0=false, 1=true)*)
val evalChurchBool = Fn(Name "x", App(App(Var(Name "x"), Const 1), Const 0));
(*true = Fn x, y => x*)
val True = Fn(Name "x", Fn(Name "y", Var(Name "x")));
(*false = Fn x, y => y*)
val False = Fn(Name "x", Fn(Name "y", Var(Name "y")));
(*not = Fn z => (Fn x, y => z y x)*)
val NOT = Fn(Name "z", Fn(Name "x", Fn(Name "y", App(App(Var(Name "z"), Var(Name "y")), Var(Name "x")))));
(*and = Fn z,w => z w False*)
val AND = Fn(Name "z", Fn(Name "w", App(App(Var (Name "z"), Var (Name "w")), False)));
(*or = Fn z,w => z True w*)
val OR = Fn(Name "z", Fn(Name "w", App(App(Var (Name "z"), True), Var (Name "w"))));

(*utility per liste di church. NB: <a, b, c> --> Fn x => x a b c*)
(*Pni(w) = i-esimo elemento della lista w di lunghezza n: Fn w=> w (Fn x1, x2, ..., xn => xi) (proiezione)*)

(*P31: Fn w => w (Fn x1, x2, x3 => x1) *)
val P31 = Fn(Name "w", App(Var (Name "w"), Fn(Name "x1", Fn(Name "x2", Fn (Name "x3", Var (Name "x1")))))); (*proiezione 1° elemento*)
val P32 = Fn(Name "w", App(Var (Name "w"), Fn(Name "x1", Fn(Name "x2", Fn (Name "x3", Var (Name "x2")))))); (*proiezione 2° elemento*)
val P33 = Fn(Name "w", App(Var (Name "w"), Fn(Name "x1", Fn(Name "x2", Fn (Name "x3", Var (Name "x3")))))); (*proiezione 3° elemento*)

(*combinatore di punto fisso:
Y = Fn f => (Fn x => f (x x)) (Fn x => f (x x)) *)
val Y = Fn(Name "f", App(Fn(Name "x", App(Var(Name "f"), App(Var(Name "x"), Var(Name "x")))), Fn(Name "x", App(Var(Name "f"), App(Var(Name "x"), Var(Name "x"))))));


(*Alberi binari: sono una lista di 3 elementi:
1° elemento: booleano, se false -> albero vuoto, se true -> albero non vuoto
2° elemento: sottoalbero sinistro (valido solo se il booleano è True, altrimenti può essere qualsiasi cosa)
3° elemento: sottoalbero destro (valido solo se il booleano è True, altrimenti può essere qualsiasi cosa) 
quindi: empty = <False, False, False> 
        branch(t1, t2) = <True, t1, t2> *)

(*alcuni alberi di prova*)

(*albero vuoto = <False, False, False> = Fn x => x False False False (NB: gli ultimi due False potevano essere qualsiasi altra cosa) *)
val emptyTree = Fn(Name "x", App(App(App(Var (Name "x"), False), False), False));

(*albero con un nodo = branch(empty, empty) = <True, empty, empty> *)
val oneNode = Fn(Name "x", App(App(App(Var (Name "x"), True), emptyTree), emptyTree)); 

(*tree1 = branch(oneNode, oneNode): *)
val tree1 = Fn(Name "x", App(App(App(Var (Name "x"), True), oneNode), oneNode));

(*tree2 = branch(tree1, oneNode)  (3 foglie) *)
val tree2 = Fn(Name "x", App(App(App(Var (Name "x"), True), tree1), oneNode));

(*tree3 = branch(tree1, tree2)  (5 foglie) *)
val tree3 = Fn(Name "x", App(App(App(Var (Name "x"), True), tree1), tree2));

(*tree4 = branch(tree3, tree3)  (10 foglie) *)
val tree4 = Fn(Name "x", App(App(App(Var (Name "x"), True), tree3), tree3));

(*tree5 = branch(empty, tree4)  (10 foglie) *)
val tree5 = Fn(Name "x", App(App(App(Var (Name "x"), True), emptyTree), tree4));

(*tree6 = branch(tree4, tree5)  (20 foglie) *)
val tree6 = Fn(Name "x", App(App(App(Var (Name "x"), True), tree4), tree5));

(*alcune funzioni sugli alberi binari*)

(*controlla se l'albero è vuoto: restituisce booleano di church
Fn z => not P13(z) *)
val isEmptyTree = Fn(Name "z", App(NOT, App(P31, Var(Name "z"))));

(*controlla se l'albero è una foglia: Fn z => P13(z) (isEmptyTree(P23(z)) AND isEmptyTree(P33(z))) False
cioè se non è vuoto, controlliamo se sono vuoti sia sx che dx, altrimenti sicuramente non è una foglia (perché l'albero vuoto non è una foglia) *)
val isLeaf = Fn(Name "z", App(App(App(P31, Var(Name "z")), 
                                        App(App(AND, App(isEmptyTree, App(P32, Var(Name "z"))) ), App(isEmptyTree, App(P33, Var(Name "z")))) ),
                                        False));

(*numero foglie: prende f e t, t è l'albero binario, e f è la "funzione stessa", cioè possiamo usare f per fare ricorsione (verrà poi fornita dal combinatore di punto fisso) *)
val leavesUtil = Fn(Name "f", Fn(Name "t",  
                    App(App(App(isEmptyTree, Var(Name "t")), Const 0), (*if isEmptyTree(t) then return 0*)
                         App(App(App(isLeaf, Var(Name "t")), Const 1), (*else if isLeaf(t) then return 1*)
                              Sum(App(Var(Name "f"), App(P32, Var(Name "t"))), App(Var(Name "f"), App(P33, Var(Name "t")))) )) (*else return (f P32(t)) + (f P33(t))*) 
                    ));
(*numero foglie = Y leavesUtil --> diamo la util al ricorsore e poi ci pensa lui*)
val numLeaves = App(Y, leavesUtil);


(*----------test vari--------*)

(* (*test su isLeaf e isEmptyTree*)
#1(evalSL(Empty, App(evalChurchBool, App(isEmptyTree, emptyTree))));
#1(evalSL(Empty, App(evalChurchBool, App(isEmptyTree, oneNode))));
#1(evalSL(Empty, App(evalChurchBool, App(isEmptyTree, tree2))));
#1(evalSL(Empty, App(evalChurchBool, App(isLeaf, emptyTree))));
#1(evalSL(Empty, App(evalChurchBool, App(isLeaf, oneNode))));
#1(evalSL(Empty, App(evalChurchBool, App(isLeaf, tree2))));


 (*Test sulle liste: *)
val list1 = Fn(Name "x", App(App(App(Var (Name "x"), Const 5), True), Const 12)); (*<5, True, 12> = Fn x => x 5 True 12*)
#1(evalSL(Empty, App(P31, list1))); (*1° elemento di list1 -> 5*)
#1(evalSL(Empty, App(P32, list1))); (*2° elemento di list1 -> True*)
#1(evalSL(Empty, App(P33, list1))); (*3° elemento di list1 -> 12*)
*)

#1(evalSL(Empty, App(numLeaves, tree6))); (*#foglie dell'albero 6 --> 20*)
