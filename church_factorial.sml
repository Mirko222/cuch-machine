use "static_eager.sml";

val evalBool = Fn(Name "x", App(App(Var(Name "x"), Const 1), Const 0));
(*true = Fn x, y => x*)
val True = Fn(Name "x", Fn(Name "y", Var(Name "x")));
(*false = Fn x, y => y*)
val False = Fn(Name "x", Fn(Name "y", Var(Name "y")));

val evalNumber = Fn(Name "x", App(App(Var (Name "x"), Fn(Name "y", Sum(Var (Name "y"), Const 1))), Const 0));
val zero = Fn(Name "x", Fn(Name "y", Var (Name "y")));
val due = Fn(Name "x", Fn(Name "y", App(Var (Name "x"), App(Var (Name "x"), Var (Name "y")))));
val tre = Fn(Name "x", Fn(Name "y", App(Var (Name "x"), App(Var (Name "x"), App(Var (Name "x"), Var (Name "y"))))));
val prod = Fn(Name "w", Fn(Name "z", Fn(Name "x", Fn(Name "y", App(App(Var (Name "w"), App(Var (Name "z"), Var (Name "x"))), Var (Name "y"))))));

(*isZero = Fn z => z (Fn x => False) True*)
val isZero = Fn(Name "z", App(App(Var(Name "z"), Fn(Name "x", False)), True));

(*predecessore di church = Fn n,f,x => n (Fn p,q => q(p f)) (Fn f => x) (Fn z => z) *)
val pred = Fn(Name "n", Fn(Name "f", Fn(Name "x", 
            App(App(App(Var(Name "n"), Fn(Name "p", Fn(Name "q", App(Var(Name "q"), App(Var(Name "p"), Var(Name "f")))))),
                Fn(Name "f", Var(Name "x"))), Fn(Name "z", Var(Name "z")))  )));

(*combinatore di punto fisso:
Y = Fn f => (Fn x => f x x) (Fn x => f x x) *)
val Y = Fn(Name "f", App(Fn(Name "x", App(Var(Name "f"), App(Var(Name "x"), Var(Name "x")))), Fn(Name "x", App(Var(Name "f"), App(Var(Name "x"), Var(Name "x"))))));

(*Fn f,x => if isZero(x) then 1 else x * (f pred(x))
cioè: Fn f,x => isZero(x) 1 x*(f pred(x)) *)
val factUtil = Fn(Name "f", Fn(Name "x", App(App(App(isZero, Var(Name "x")), Const 1), App(App(prod, Var(Name "x")), App(Var(Name "f"), App(pred, Var(Name "x"))))  )  ));

(*fact = Y factUtil*)
val fact = App(Y, factUtil);

#1(evalSE(Empty, App(fact, tre)));