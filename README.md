# JuliaSkriptumKontrolle

[![Build Status](https://travis-ci.org/sebastianpech/JuliaSkriptumKontrolle.jl.svg?branch=master)](https://travis-ci.org/sebastianpech/JuliaSkriptumKontrolle.jl)

## Sandbox

Every assessment of an exercise runs in its own sandbox in a temporary directory.

## Setup

Functions defined in the `Dict` `setup_functions` run before every call to the assessment function.
The function `setup(identifier)` should also be used by students if additional actions are needed before starting with the exercise.

A special setup case is providing data for an exercise. This can be done by putting a folder named like the exercise `identifer` into `exercise_data`.
If the `setup` function finds such a folder, the content is copied to the current directory.

## Defining exercises

### Exercise 1.1

Assessment functions need to be added to `Dict` `JuliaSkriptumKontrolle.check_functions`. 
The only attribute those function get passed is the result of the expression the students wrote.
So this can be a simple block, or another function.
Additionally, the score for the exercise must be defined using `set_score`.

The assessment function must throw an error in order to keep track of done, open and wrong exercises.
Here, a function must be written that returns `x^2` if `x>0` and `0` otherwise.

```julia
set_score("1.1", 1.0)
check_functions["1.1"] = function(result)
    @assert result(2) === 4
    @assert result(-2.) === 0.0
end
```

### Exercise 1.2 -- `stdin` and `stdout`

A utility function `run_redirected` is provided that allows capturing output and providing input.
Here, a function must be written that prints every text sent to `stdin` twice until `"exit"` is read.
The function must then return the number of read values.

```julia
set_score("1.2", 2.0)
check_functions["1.2"] = function(result)
    out = String[]
    inp = ["foo", "bar", "baz", "exit"]
    count = run_redirected(input=inp,output=out) do
        result()
    end
    @assert out == ["foofoo", "barbar", "bazbaz"] 
    @assert count == 3
end
```

### Exercise 1.3 -- Restrict or require usage of certain functions 

Often exercises require students to rewrite already existing functions.
By just checking the result, those exercises would be very simple, because the already implemented version could be used.
For such cases the functions `do!` and `dont!` are provided.
The macro throws an `ErrorException` if a wrong function is used.
In the following example a function should be written that sums the absolute values of all numbers provided, without using `sum` and `abs` but using `sign`.

```julia
set_score("1.3", 3.0)
check_functions["1.3"] = function(result)
    t = [-1,-2,3,4,5]
    t2 = [3,4,5]
    @donts result(t) :sum :abs
    @dos result(t) :sign
    @assert result(t) === sum(abs.(t))
    @assert result(t2) === sum(abs.(t2))
end
```

## Checking exercises (Student view)

A block or function can be checked by using the macro `@Exercise` on this function or block.
The progress can be viewed with `JuliaSkriptumKontrolle.status()`.
Before any of the examples is tried `JuliaSkriptumKontrolle.status()` prints:

```
│ Exercise │ Status │     Score │
├──────────┼────────┼───────────┤
│      1.1 │      ? │       1.0 │
│      1.2 │      ? │       2.0 │
│      1.3 │      ? │       3.0 │
├──────────┼────────┼───────────┤
│          │      ∑ │ 0.0 / 6.0 │
```

### Exercise 1.1

```julia
@Exercise "1.1" function square_if_positive(x)
    return x^2
end
# --> ERROR: AssertionError: result(-2.0) === 0.0
```

```
│ Exercise │ Status │     Score │
├──────────┼────────┼───────────┤
│      1.1 │      × │       1.0 │
│      1.2 │      ? │       2.0 │
│      1.3 │      ? │       3.0 │
├──────────┼────────┼───────────┤
│          │      ∑ │ 0.0 / 6.0 │
```
```julia
@Exercise "1.1" function square_if_positive(x)
    if x < 0
        return zero(x)
    else
        return x^2
    end
end
```

```
│ Exercise │ Status │     Score │
├──────────┼────────┼───────────┤
│      1.1 │      ✓ │       1.0 │
│      1.2 │      ? │       2.0 │
│      1.3 │      ? │       3.0 │
├──────────┼────────┼───────────┤
│          │      ∑ │ 1.0 / 6.0 │
```

### Aufgabe 1.2

```julia
@Exercise "1.2" function double_input()
    counter = 0
    while true
        inp = readline()
        counter += 1
        if inp == "exit"
            break
        end
        println(inp^2)
    end
    return counter-1
end
```

```
│ Exercise │ Status │     Score │
├──────────┼────────┼───────────┤
│      1.1 │      ✓ │       1.0 │
│      1.2 │      ✓ │       2.0 │
│      1.3 │      ? │       3.0 │
├──────────┼────────┼───────────┤
│          │      ∑ │ 3.0 / 6.0 │
```

### Aufgabe 1.3

```julia
@Exercise "1.3" function my_sum(x)
    return sum(abs.(x)) 
end # --> ERROR: Usage of 'sign' is required. Find a solution where you use 'sign'.
```

```julia
@Exercise "1.3" function my_sum(x)
    s = zero(eltype(x))
    for _x in x
        s += sign(_x)*_x
    end
    return s
end
```

```
│ Exercise │ Status │     Score │
├──────────┼────────┼───────────┤
│      1.1 │      ✓ │       1.0 │
│      1.2 │      ✓ │       2.0 │
│      1.3 │      ✓ │       3.0 │
├──────────┼────────┼───────────┤
│          │      ∑ │ 6.0 / 6.0 │
```

## Batch checking

`JuliaSkriptumKontrolle.suppress_errors()` can be called at the beginning of a file, to suppress error throwing.
This way it's easier to check multiple files an return the exercise status for all of them, even if some of the exercises are wrong.
