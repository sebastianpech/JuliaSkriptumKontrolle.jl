using Test
using JuliaSkriptumKontrolle
import JuliaSkriptumKontrolle: do!, dont!

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
        @Exercise "test 001" function square_if_positive(x)
            if x < 0
                return zero(x)
            else
                return x^2
            end
        end
        @test JuliaSkriptumKontrolle.get_state("test 001") == :passed
        @test_throws AssertionError @Exercise "test 001" function square_if_positive(x)
            if x < 0
                return 0
            else
                return x^2
            end
        end
        @test JuliaSkriptumKontrolle.get_state("test 001") == :failed
    end
    @testset "test 002" begin
        @Exercise "test 002" function double_input()
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
        @Exercise "test 004" begin
            using LinearAlgebra
            a = [1,2,3]
            b = [4,5,6]
            a ⋅ b
        end
        @test JuliaSkriptumKontrolle.get_state("test 004") == :passed

        @test_throws AssertionError @Exercise "test 004" begin
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

    @Exercise "test-003" function sometest()
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

# Define check function calculate abs without using abs
JuliaSkriptumKontrolle.check_functions["abstest"] = function(result)
    numbers = rand(100).-0.5
    @assert all(result.(numbers) .== abs.(numbers))
end
dont!("abstest",:abs)
do!("abstest",:sign)

# Define check function calculate abs without using abs
JuliaSkriptumKontrolle.check_functions["split"] = function(result)
    nothing
end
dont!("split",:split)

@testset "Do's and Dont's" begin
    @test_throws ErrorException (@Exercise "abstest" function f1(x)
                                 abs(x)
                                 end)
    @test JuliaSkriptumKontrolle.get_state("abstest") == :failed

    @Exercise "abstest" function f5(x)
        return sign(x)*x
    end
    @test JuliaSkriptumKontrolle.get_state("abstest" ) == :passed

    @test_throws ErrorException (@Exercise "abstest" function f2(x)
                                 x < 0 && return -x
                                 return x
                                 end)

    @test JuliaSkriptumKontrolle.get_state("abstest") == :failed

    @test_throws ErrorException (@Exercise "split" function f3(x)
        split("asdf", "1")
                                 end)
    @test_throws ErrorException (@Exercise "split" function f4(x)
        Base.split("asdf", "1")
                                 end)

end

JuliaSkriptumKontrolle.set_solution("test 001", [105, 120, 113, 102, 119, 108, 114, 113, 35, 117, 104, 118, 43, 123, 44, 13, 35, 35, 35, 35, 108, 105, 35, 123, 35, 63, 35, 51, 13, 35, 35, 35, 35, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35,
51, 49, 51, 13, 35, 35, 35, 35, 104, 111, 118, 104, 13, 35, 35, 35, 35, 35, 35, 35, 35, 123, 97, 53, 13, 35, 35, 35, 35, 104, 113, 103, 13, 104, 113, 103, 13])

@testset "Encryption" begin
    @test JuliaSkriptumKontrolle.decode(JuliaSkriptumKontrolle.encode("foo",shift=10), shift=10) == "foo"
    @test JuliaSkriptumKontrolle.decode_solution("test 001") == "function res(x)\n    if x < 0\n        return 0.0\n    else\n        x^2\n    end\nend\n"
end
