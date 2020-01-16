use "static_eager.sml";


evalSE(Empty,
    Let(Name "eval", Fn(Name "x", App(App(Var(Name "x"), Const 1), Const 0)), (*eval = Fn x => x 1 0 (0 = false, 1 = true)*)
        Let(Name "true", Fn(Name "x", Fn(Name "y", Var(Name "x"))), (*true = Fn x, y => x*)
            Let(Name "false", Fn(Name "x", Fn(Name "y", Var(Name "y"))), (*true = Fn x, y => x*)
                Let(Name "not", Fn(Name "z", Fn(Name "x", Fn(Name "y", App(App(Var(Name "z"), Var(Name "y")), Var(Name "x"))))), (*not = Fn z => (Fn x, y => z y x)*)
                    App(Var(Name "eval"), App(Var(Name "not"), Var(Name "true"))) (*esempio: eval(not true) --> 0 (false) *)
                )
            )    
        ) 
    )
);