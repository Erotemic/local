GaussianProcess
Laplacian kernel
cross-validation of training
hyperparamater conjugate gradient maximization of the log marginal likelihood. 
Flow is constrained to be non-negative (log transform of observation space was used) 
2/3 training 1/3 test. 

Error measures:
Coefficient of Determination 
R^2 = ((sum y_i - yhat )*(f4 - fhat)) / (n-1)sigma_ysigma_f 

Root Mean Squared Error 
RMSE = \sqrt(1/m \frac sum_t(y_i-f_i)^2)


grammar:
    list = expr
           list_expr
           
    list_expr = expr list_expr
                (expr list_expr)
                expr\nexpr

    expr: = atom 
            list
            list_expr
            expr op expr
            expr expr
            expr

    atom := func(expr) 
            number
            string
            space
            None
            newline

    # Intrinsics
            
    func = op(expr)
           op expr
           expr space op space expr

    decimal_number := 0d[01].+[01]*
                      od.[01]*

    binary_number := 0b[0-0x9].+[0-0x9]*
                     0b.[0-0x9]*

    hex_number    := 0x[0-0xF].+[0-F]*
                     0x.[0-F]*

    oct_number := 0o[0-0o8].+[0-0o8]*
                     0o.[0-0o8]*

    number := oct_number
              hex_number
              binary_number
            
    string := '''**'''
              '''**''' % expr
              ''

    variable := alpha
                beta 
                '[A-Z]+'

    space = 

    newline = \n

    # Variables are the greediest. They take what they want
    var := CUSTOM_VAR
           varNEXT_TOKEN

    class  vector := expr\n{expr}

    list_vector = [sized_type]
                  [vector list_vector]
                  []

    # Let things have multiple types and then unify the types later with 
    # some argument which says the type of type that it would really like
    
    matrix := list_vector 

    # Operator. It is greedy. It takes its arguments. 
    op := sin
          cos
          sqrt
          frac 
          summation  sum
          add  +
          minus  -
          multiply  *
          divide  /
          equals  ==  =
          assign  := 
          transform  -op>

          transpose   `#I want to use a sybmol here
          power pow  ^  **
          modulus mod  %
          convolve conv (*)
          function_composition func_comp ()

          factorial  !
          inverse inv
          gaussian_distribution gauss
          integrate int i expr d atom

          derivative der d
          parial_derivative partial pd expr / pd var
          CUSTOM_OPERATIONS
# PErformance things
          evaluated := eval(expr) # Magic, will use parents behavior and not eval until end. Do data packing right. 
          evaluate  eval

          ...

# Special things 
NEXT_TOKEN := 
CUSTOM_VAR :=
CUSTOM_OPERATIONS :=
