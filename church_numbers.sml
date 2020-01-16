use "static_eager.sml";


#1(evalSE(Empty,
    Let(Name "eval", Fn(Name "x", App(App(Var (Name "x"), Fn(Name "y", Sum(Var (Name "y"), Const 1))), Const 0)), (*funzione eval: gli diamo un numero di church e ci dà un const: let eval=Fn x => ( x (Fn y=>y+1) 0 ) in ...*)
        Let(Name "due", Fn(Name "x", Fn(Name "y", App(Var (Name "x"), App(Var (Name "x"), Var (Name "y"))))), (*let due=Fn x,y => x(x y) in ... *)
            Let(Name "tre", Fn(Name "x", Fn(Name "y", App(Var (Name "x"), App(Var (Name "x"), App(Var (Name "x"), Var (Name "y")))))), (*tre di church*)
                Let(Name "zero", Fn(Name "x", Fn(Name "y", Var (Name "y"))), (*zero di church*)
                    Let(Name "succ", Fn(Name "z", Fn(Name "x", Fn(Name "y", App(Var(Name "x"), App(App(Var(Name "z"), Var(Name "x")), Var(Name "y")))))), (*succ di church: let succ=Fn z=>(Fn x, y=> x (z x y)) in ...*)
                        Let(Name "sum", Fn(Name "w", Fn(Name "z", Fn(Name "x", Fn(Name "y", App(App(Var (Name "z"), Var (Name "x")), App(App(Var (Name "w"), Var (Name "x")), Var (Name "y"))))))), (*somma di church: let sum=Fn w,z,x,y => z x (w x y)*)
                            Let(Name "prod", Fn(Name "w", Fn(Name "z", Fn(Name "x", Fn(Name "y", App(App(Var (Name "w"), App(Var (Name "z"), Var (Name "x"))), Var (Name "y")))))), (*prod = Fn w,z,x,y => w (z x) y*)
                                Let(Name "pow", Fn(Name "w", Fn(Name "z", Fn(Name "x", App(App(Var (Name "z"), Var (Name "w")), Var (Name "x"))))), (*pow = Fn w,z,x => w z x*)


                                    App(Var (Name "eval"), App(App(Var (Name "pow"), Var (Name "tre")), 
                                                                App(App(Var (Name "prod"), Var (Name "due")), Var (Name "due")))) (*eval pow 3 (prod 2 2)*)

                                    (*App(Var (Name "eval"), App(App(Var (Name "pow"), Var (Name "tre")), App(Var (Name "succ"), Var (Name "due"))))*) (*eval pow 3 succ(2) --> 27*)
                                    (*App(Var (Name "eval"), App(App(Var (Name "prod"), Var (Name "tre")), App(Var (Name "succ"), Var (Name "due"))))*) (*eval prod tre succ(due) --> 9*)
                                    (*App(Var (Name "eval"), App(App(Var (Name "sum"), Var (Name "tre")), App(Var (Name "succ"), Var (Name "due"))))*) (*eval(sum tre succ(due)) --> 6 *)
                                    (*App(Var (Name "eval"), App(Var (Name "succ"), Var (Name "tre"))) *) (*esempio: eval(succ tre) --> 4*)

                                    
                                )
                            )
                        )
                    )
                )
            )
        )  
    )
));