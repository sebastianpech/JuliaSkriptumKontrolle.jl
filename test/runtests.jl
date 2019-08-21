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
    checks = [
        result(2) === 4,
        result(-2.) === 0.0]
    all(checks) && JuliaSkriptumKontrolle.passed("test 001")
    # This is just returned for the test
    checks
end

# Define check function test 002
JuliaSkriptumKontrolle.check_functions["test 002"] = function(result)
    out = String[]
    inp = ["foo", "bar", "baz", "exit"]
    res = JuliaSkriptumKontrolle.run_redirected(input=inp,output=out) do
        result()
    end
    # Mark as passed
    (out == ["foofoo", "barbar", "bazbaz"] &&
     res == 4) && JuliaSkriptumKontrolle.passed("test 002")
    # Only for testings
    out, res
end

@testset "Check" begin
    @testset "test 001" begin
        res = @Aufgabe "test 001" function square_if_positive(x)
            if x < 0
                return zero(x)
            else
                return x^2
            end
        end
        @test all(res)
        @test JuliaSkriptumKontrolle.check_function_passed["test 001"]
        res = @Aufgabe "test 001" function square_if_positive(x)
            if x < 0
                return 0
            else
                return x^2
            end
        end
        @test res == [true,false]
    end
    @testset "test 002" begin
        out,count = @Aufgabe "test 002" function double_input()
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
        @test out == ["foofoo", "barbar", "bazbaz"]
        @test count == 4
    end
    @test !JuliaSkriptumKontrolle.check_function_passed["test 001"]
    @test JuliaSkriptumKontrolle.check_function_passed["test 002"]
end
