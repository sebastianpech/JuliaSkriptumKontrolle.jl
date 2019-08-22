using Test
using JuliaSkriptumKontrolle

@testset "Sandbox" begin
    @test JuliaSkriptumKontrolle.eval_sandboxed(:(1+1)) == 2
    x = 10
    @test_throws UndefVarError JuliaSkriptumKontrolle.eval_sandboxed(:(x+2)) == 2
end

@testset "IO Redirection" begin
    output = String[]
    input = ["got this"
             "from the outside"]
    res = JuliaSkriptumKontrolle.run_redirected(output=output,input=input) do
        println("Hello")
        inp = readline()
        println(inp)
        inp = readline()
        println(inp)
        println("World")
        10
    end
    @test res == 10
    @test output == ["Hello", "got this", "from the outside", "World"]
end

# Define check function for test 001
JuliaSkriptumKontrolle.check_functions["test 001"] = function(result)
    @assert result(2) === 4
    @assert result(-2.) === 0.0
end

# Define check function test 002
JuliaSkriptumKontrolle.check_functions["test 002"] = function(result)
    out = String[]
    inp = ["foo", "bar", "baz", "exit"]
    res = JuliaSkriptumKontrolle.run_redirected(input=inp,output=out) do
        result()
    end
    # Mark as passed
    @assert out == ["foofoo", "barbar", "bazbaz"]
    @assert res == 4
end

@testset "Check" begin
    @testset "test 001" begin
        @Aufgabe "test 001" function square_if_positive(x)
            if x < 0
                return zero(x)
            else
                return x^2
            end
        end
        @test JuliaSkriptumKontrolle.check_function_passed["test 001"]
        @test_throws AssertionError @Aufgabe "test 001" function square_if_positive(x)
            if x < 0
                return 0
            else
                return x^2
            end
        end
    end
    @testset "test 002" begin
        @Aufgabe "test 002" function double_input()
            counter = 0
            while true
                inp = readline()
                counter += 1
                if inp == "exit"
                    break
                end
                println(inp^2)
            end
            return counter
        end
    end
    @test !JuliaSkriptumKontrolle.check_function_passed["test 001"]
    @test JuliaSkriptumKontrolle.check_function_passed["test 002"]
end


@testset "Datadir" begin
    identifier = "1-1"
    dirpath = joinpath(JuliaSkriptumKontrolle.exercise_data_dir,identifier)
    JuliaSkriptumKontrolle.setup_functions[identifier] = function ()
        open(joinpath(identifier,"testfile_from_function"),"w") do f
            write(f,"nothing")
        end
    end
    mkdir(dirpath)
    open(joinpath(dirpath,"testfile"),"w") do f
        write(f,"nothing")
    end
    JuliaSkriptumKontrolle.setup(identifier)
    @test isdir(identifier)
    @test isfile(joinpath(identifier,"testfile"))
    @test isfile(joinpath(identifier,"testfile_from_function"))
    @test_throws ArgumentError JuliaSkriptumKontrolle.setup(identifier)
    JuliaSkriptumKontrolle.setup(identifier,force=true)
    rm(dirpath,recursive=true)
    rm(identifier,recursive=true)
end
