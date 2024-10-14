module JuliaSkriptumKontrolle

using PrettyTables
using Cassette
using DataStructures
using Crayons.Box

include(joinpath(@__DIR__, "Crypto.jl"))

export @Exercise

const exercise_data_dir = joinpath(@__DIR__,"..","exercise_data")

# Variable is used for batch checking of files
global RETHROW_ERRORS = true

function rethrow_errors()
    global RETHROW_ERRORS
    RETHROW_ERRORS=true
end

function suppress_errors() 
    global RETHROW_ERRORS
    RETHROW_ERRORS=false
end

check_functions = OrderedDict{String,Function}()
exercise_score = Dict{String,Float64}()
check_function_state = Dict{String,Symbol}()
setup_functions = Dict{String,Function}()
solution_data = Dict{String, Vector{Int}}()

function set_score(identifier::AbstractString,score)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    exercise_score[identifier] = score
end

function get_score(identifier::AbstractString)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    @assert identifier in keys(exercise_score) "Exercise $identifier missing score."
    get_state(identifier) == :passed && return exercise_score[identifier]
    return 0.0
end

function set_solution(identifier::AbstractString,solution)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    solution_data[identifier] = solution
end

function get_solution(identifier::AbstractString)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    return get(solution_data,identifier,nothing)
end

function decode_solution(identifier::AbstractString)
    sol = get_solution(identifier)
    sol == nothing && return nothing
    return decode(join(Char.(sol)), shift=3)
end

function output_success(identifier::AbstractString)
    dec_sol = decode_solution(identifier)
    println((GREEN_BG*BLACK_FG)("Exercise $identifier solved"))
    if dec_sol != nothing
        println((BLACK_FG*LIGHT_GRAY_BG)("Exemplary solution:"))
        println(LIGHT_GRAY_BG(" "))
        foreach(split(dec_sol,"\n")) do l
            println(LIGHT_GRAY_BG(" "), " ", l)
        end
    end
end

function output_failure(identifier::AbstractString)
    println((RED_BG)("Exercise $identifier wrong."))
end

function setup(identifier::AbstractString;force::Bool=false)
    # Copy data dir if exists
    data_dir = joinpath(exercise_data_dir,identifier)
    isdir(data_dir) && cp(data_dir,joinpath(pwd(),identifier),force=force)
    # Call setup function
    identifier in keys(setup_functions) && setup_functions[identifier]()
end

macro Exercise(identifier::AbstractString, expr)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    check_function = check_functions[identifier]
    result = eval_sandboxed(expr)
    temp_run_dir = mktempdir()
    cwd = pwd()
    quote
        $(esc(expr))
        try
            JuliaSkriptumKontrolle.reset_passed($identifier)
            # Run this in the temporary directory
            cd($temp_run_dir)
            JuliaSkriptumKontrolle.setup($identifier,force=true)
            result = $check_function($result)
            cd($cwd)
            JuliaSkriptumKontrolle.passed($identifier)
            JuliaSkriptumKontrolle.output_success($identifier)
        catch e
            cd($cwd)
            JuliaSkriptumKontrolle.failed($identifier)
            if JuliaSkriptumKontrolle.RETHROW_ERRORS
                JuliaSkriptumKontrolle.output_failure($identifier)
                rethrow(e)
            else
                println(e)
            end
        end
        nothing
    end
end

macro Exercise(expr::Expr)
    error("Exercise identifier not provided. The required format is @Exercise \"x.y.z\" ...")
end

function get_state(identifier::AbstractString)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    identifier in keys(check_function_state) || return :notdone
    return check_function_state[identifier]
end

function get_state_string(identifier::AbstractString)
    get_state_string(Val(get_state(identifier)))
end

get_state_string(::Val{:notdone}) = "?"
get_state_string(::Val{:failed}) = "×"
get_state_string(::Val{:passed}) = "✓"


function reset_passed(identifier::AbstractString)
    check_function_state[identifier] = :notdone
    nothing
end

function passed(identifier::AbstractString)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    check_function_state[identifier] = :passed
    nothing
end

function failed(identifier::AbstractString)
    @assert identifier in keys(check_functions) "Exercise $identifier not found."
    check_function_state[identifier] = :failed
    nothing
end


function sandbox()
    sandbox_name = "SB_$(splitext(basename(tempname())) |> first)"
    Core.eval(Main, Meta.parse("module $(sandbox_name)\nend"))
end

function eval_sandboxed(expr::Expr)
    sb = sandbox()
    # Eval part by part if is a block
    if expr.head == :block
        N = length(expr.args)
        for (i,part) in enumerate(expr.args)
            result = Core.eval(sb,part)
            i == N && return result
        end
    else
        return Core.eval(sb,expr)
    end
end

function run_redirected(f::Function;input::Vector{<:AbstractString}=String[],output::Vector{<:AbstractString}=String[])
    _stdin = stdin
    _stdout = stdout
    (in_rd,in_wr) = redirect_stdin()
    (out_rd,out_wr) = redirect_stdout()
    try
        # Write input into stdin buffer
        println.(Ref(in_wr),input)
        res = f()
        redirect_stdin(_stdin)
        redirect_stdout(_stdout)
        close(out_wr)
        # Push to output
        push!.(Ref(output),readlines(out_rd))
        close(out_rd)
        close(in_rd)
        close(in_wr)
        return res
    catch e
        redirect_stdin(_stdin)
        redirect_stdout(_stdout)
        close(out_wr)
        close(out_rd)
        close(in_rd)
        close(in_wr)
        rethrow(e)
    end
end

function status()
    exercises = keys(check_functions)|>collect
    h1 = Highlighter(
        (data,i,j)-> (data[i,2] == "✓"),
        bold=false,foreground=:green)

    h2 = Highlighter(
        (data,i,j)-> (data[i,2] == "×"),
        bold=false,foreground=:red)

    h3 = Highlighter(
        (data,i,j)-> (i == size(data,1)),
        bold=true)

    scores = get_score.(exercises)
    points = [exercise_score[i] for i in exercises]

    format_score(x,y) = "$x / $y"
    
    table = hcat(exercises,
                 get_state_string.(exercises),
                 points)
    table = vcat(table,
                 ["" "∑" format_score(sum(scores),sum(points))])

    pretty_table(table,
        header=["Exercise","Status","Score"],
        highlighters = (h1,h2,h3),
        hlines = [0,1,size(table,1),size(table,1)+1],display_size = (-1,-1), crop = :none)
end

Cassette.@context CounterCtx

isrelated(t::Type,name) = isrelated(string(t.name.name),name)
isrelated(t::DataType,name) = isrelated(string(t.name.name),name)
isrelated(t::UnionAll,name) = false
isrelated(f::Function,name) = isrelated(string(typeof(f).name.name),name)
function isrelated(f::T,name) where T
    if typeof(T) <: DataType
        return isrelated(string(T.name.name),name)
    end
    return false
end

function isrelated(fname::AbstractString,name)
    if fname == "#$name" || fname == string(name)
        return true
    end
    if startswith(fname,"#kw##$name")
        return true
    end
    if startswith(fname,"##$name#")
        return true
    end
    return false
end

function check_count_function(ctx::CounterCtx,f)
    for fname in keys(ctx.metadata)
        if isrelated(f,fname)
            ctx.metadata[fname] += 1
        end
    end
end

init_ctx(::Type{CounterCtx},syms::Symbol...) =  CounterCtx(metadata=Dict([d=>0 for d in syms]))

Cassette.posthook(ctx::CounterCtx, ::Any, f, args...) = check_count_function(ctx,f)

join_comma_and(a) = "$a"
join_comma_and(a,b) = "$a and $b"
join_comma_and(c...) = join(c[1:end-1],", ")*" and $(c[end])"

function assert_donts(calls)
    invalid = ["'"*string(x.first)*"'" for x in calls if x.second > 0]
    @assert length(invalid) == 0 "Usage of $(join_comma_and(invalid...)) not allowed."
    nothing
end

function assert_dos(calls)
    invalid = ["'"*string(x.first)*"'" for x in calls if x.second == 0]
    @assert length(invalid) == 0 "Usage of $(join_comma_and(invalid...)) required."
    nothing
end

macro dos(fcall,ex...)
    esc(quote
        cnt = JuliaSkriptumKontrolle.init_ctx(JuliaSkriptumKontrolle.CounterCtx,$(ex...))
        JuliaSkriptumKontrolle.Cassette.@overdub cnt $fcall
        JuliaSkriptumKontrolle.assert_dos(cnt.metadata)
        end)
end

macro donts(fcall,ex...)
    esc(quote
        cnt = JuliaSkriptumKontrolle.init_ctx(JuliaSkriptumKontrolle.CounterCtx,$(ex...))
        JuliaSkriptumKontrolle.Cassette.@overdub cnt $fcall
        JuliaSkriptumKontrolle.assert_donts(cnt.metadata)
        end)
end

include("./Exercises.jl")

end # module
