using Test
using JuliaSkriptumKontrolle
import JuliaSkriptumKontrolle: @dos, @donts

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
JuliaSkriptumKontrolle.set_score("test 001",1)


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
JuliaSkriptumKontrolle.set_score("test 002",2.5)

# Define check function for test 004
JuliaSkriptumKontrolle.check_functions["test 004"] = function(result)
    @assert result == 32
end
JuliaSkriptumKontrolle.set_score("test 004",0.5)

@testset "Check" begin
    @test all(JuliaSkriptumKontrolle.get_state.(["test 001", "test 002", "test 004"]) .== :notdone)
    @testset "test 001" begin
        @Aufgabe "test 001" function square_if_positive(x)
            if x < 0
                return zero(x)
            else
                return x^2
            end
        end
        @test JuliaSkriptumKontrolle.get_state("test 001") == :passed
        @test_throws AssertionError @Aufgabe "test 001" function square_if_positive(x)
            if x < 0
                return 0
            else
                return x^2
            end
        end
        @test JuliaSkriptumKontrolle.get_state("test 001") == :failed
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
        @test JuliaSkriptumKontrolle.get_state("test 002") == :passed
    end
    @testset "Block Expressions" begin
        @Aufgabe "test 004" begin
            using LinearAlgebra
            a = [1,2,3]
            b = [4,5,6]
            a ⋅ b
        end
        @test JuliaSkriptumKontrolle.get_state("test 004") == :passed

        @test_throws AssertionError @Aufgabe "test 004" begin
            using LinearAlgebra
            a = [1,2,3]
            b = [7,5,6]
            a ⋅ b
        end
        @test JuliaSkriptumKontrolle.get_state("test 004") == :failed
    end
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

# Define check function for test 001
working_dir = ""
JuliaSkriptumKontrolle.check_functions["test-003"] = function(result)
    global working_dir
    result()
    working_dir = pwd()
end
JuliaSkriptumKontrolle.set_score("test-003",5.0)

@testset "Temporary WD" begin
    identifier = "test-003"
    cwd = pwd()

    dirpath = joinpath(JuliaSkriptumKontrolle.exercise_data_dir,identifier)
    mkdir(dirpath)

    @Aufgabe "test-003" function sometest()
        touch(joinpath("test-003","file"))
    end

    @test pwd() == cwd
    @test working_dir != cwd
    @test isdir(joinpath(working_dir,identifier))
    @test isfile(joinpath(working_dir,identifier,"file"))
    rm(dirpath,recursive=true)
    rm(working_dir,recursive=true)
end

@testset "Scores" begin
    exercises = sort(keys(JuliaSkriptumKontrolle.check_functions)|>collect)
    @test sum(JuliaSkriptumKontrolle.get_score.(exercises)) == 7.5
end

const hiding_this = abs

# Define check function calculate abs without using abs
JuliaSkriptumKontrolle.check_functions["abstest"] = function(result)
    @donts result(10) :abs
    @dos result(10) :sign
    numbers = rand(100).-0.5
    @assert all(result.(numbers) .== abs.(numbers))
end


@testset "Do's and Dont's" begin
    function my_test_function(x,y)
        abs(x)
        abs(y)
        sqrt(x)
        max(x,y)
    end

    @test (@dos my_test_function(10,1) :abs) == nothing
    @test (@dos my_test_function(10,1) :abs :sqrt) == nothing
    @test_throws AssertionError (@dos my_test_function(10,1) :abs :min)
    @test_throws AssertionError (@dos my_test_function(10,1) :min)

    @test (@donts my_test_function(10,1) :sum) == nothing
    @test (@donts my_test_function(10,1) :sum :mul!) == nothing
    @test_throws AssertionError (@donts my_test_function(10,1) :abs :min)
    @test_throws AssertionError (@donts my_test_function(10,1) :abs)

    function sneaky_test_function(x,y)
        hiding_this(x)
        hiding_this(y)
        sqrt(x)
        max(x,y)
    end

    @test_throws AssertionError (@donts sneaky_test_function(10,1) :abs)

    cnt = JuliaSkriptumKontrolle.init_ctx(JuliaSkriptumKontrolle.CounterCtx,:abs)
    JuliaSkriptumKontrolle.Cassette.@overdub cnt sneaky_test_function(10,1)
    @test cnt.metadata[:abs] == 2

    @test_throws AssertionError (@Aufgabe "abstest" function my_abs(x)
                                 abs(x)
                                 end)
    @test JuliaSkriptumKontrolle.get_state("abstest") == :failed

    @test_throws AssertionError (@Aufgabe "abstest" begin
                                 const hiding_this = abs
                                 function my_abs(x)
                                 hiding_this(x)
                                 end
                                 end)

    @test JuliaSkriptumKontrolle.get_state("abstest") == :failed
    @Aufgabe "abstest" function my_abs(x)
        return sign(x)*x
    end
    @test JuliaSkriptumKontrolle.get_state("abstest" ) == :passed

    @test_throws AssertionError (@Aufgabe "abstest" function my_abs(x)
                                 x < 0 && return -x
                                 return x
                                 end)

    @test JuliaSkriptumKontrolle.get_state("abstest") == :failed

end

