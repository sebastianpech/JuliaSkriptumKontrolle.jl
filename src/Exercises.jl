# This file contains the check functions for the exercises.
# Every exercise must be defined by a check function
#
#    check_functions["excercise identifier"] = function(result)
#        @assert something ...
#        @assert something else ... 
#    end
#
# and has an optional score attached.
# 
#    set_score("excercise identifier",score)

using Random

# 3. Interaktion
# 3.5.1 Installiere alle Pakete für die LVA
check_functions["3.5.1"] = function(result)
    required_packages = [
        :CSV,
        :DataFrames,
        :Plots,
        :DelimitedFiles,
        :Unitful,
        :Measurements,
        :Debugger,
        :RDatasets,
    ]
    for package in required_packages
        try
            eval_sandboxed(:(using $package))
        catch e
            error("Paket $package nicht installiert!")
        end
    end
end

# 7. Funktionen
# 7.4.1 Dreimal printen
check_functions["7.4.1"] = function(result)
	out = String[]
	inp = ["foo","zack"]
	res = run_redirected(output=out) do
		result.(inp)
	end
	@assert out != ["foofoofoo","zackzackzack"] "Abstand vergessen"
	@assert out == ["foo foo foo","zack zack zack"]
end

# 7.4.2 Verketten
check_functions["7.4.2"] = function(result)
	f(x) = x+5
	g(x) = x^3
	@assert result(f,g,3) == 3^3+5
	@assert result(length,g,"foo") == 9
end

# 7.4.3 Kreisfläche

check_functions["7.4.3"] = function(result)
	@assert result(3) == 3^2*π
	@assert result(5) == 5^2*π
end

# 7.4.4 Kreisumfang

check_functions["7.4.4"] = function(result)
	@assert result(3) == 2*3*π
	@assert result(5) == 2*5*π
end

# 7.4.5 Kreis: Eigenschaften printen
check_functions["7.4.5"] = function(result)
	out = String[]
	inp = [rand(0:30) for _ in 1:10]
	res = run_redirected(output=out) do
		result.(inp)
	end
    @assert length(out) > 0 "Ausgabe fehlt"
    for (idx,i) in enumerate(1:3:length(out)-3)
        r = inp[idx]
        @assert out[i] == "r = $(round(r,digits=2))" "Fehler bei der Ausgabe."
        @assert out[i+1] == "A = $(round(r^2*π,digits=2))" "Fehler bei der Ausgabe oder Berechnung von A."
        @assert out[i+2] == "U = $(round(2*r*π,digits=2))" "Fehler bei der Ausgabe oder Berechnung von U."
    end
end

# 8. Arrays, Dicts, Tuples
# 8.4.1 Drei Arrays zusammenhängen
check_functions["8.5.1"] = function(result)
	n1 = [1,2]; n2 = [3,4]; n3 = [5,6]
	s1 = ["aa","bb"]
	c1 = ['a', 'b']
	@assert result(n1,n2,n3) == [1,2,3,4,5,6]
	# @assert result(n1,s1,c1) == [1,2,"aa","bb",'a','b']
end

# 8.4.2 Inneres eines Arrays
check_functions["8.5.2"] = function(result)
	a = [9,8,7,6,5]
	b = [8,7,6]
	c = [7]
	@assert result(a) == b
	@assert result(b) == c
	@assert result(c) == []
end

# 8.4.3 Ist das Array sortiert?
check_functions["8.5.3"] = function(result)
	@assert result(['s','p','a','m']) == false
	@assert result(['a','m','p','s']) == true
end

# 8.4.4 Anagram-Test
check_functions["8.5.4"] = function(result)
    chrs = [Char(i) for i in vcat(97:97+25)]
    random_word() = join(shuffle(chrs)[4:rand(5:div(length(chrs),2))])
    function random_different_word(word)
        _chrs = setdiff(Set(chrs),Set(word))
        join(shuffle(collect(_chrs))[4:rand(5:div(length(_chrs),2))])
    end
    for _ in 1:100
        w = random_word()
        wd = random_different_word(w)
        @assert result(w,join(shuffle(collect(w)))) "Falsche Ausgabe. Wort ist ein Anagram."
        @assert !result(w,wd) "Falsche Ausgabe. Worst ist kein Anagram."
    end
end

# 8.4.5 N-tes Element eines Dictionaries ausgeben
check_functions["8.5.5"] = function(result)
	d = Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19)
	@assert result(d,1) == 4
	@assert result(d,3) == 19
end

# 8.4.6 Tuples zusammenfügen
check_functions["8.5.6"] = function(result)
	@assert result(('a','b'),('c','d','e')) == ('a','b','c','d','e')
end

# 10. Lineare Algebra

using LinearAlgebra
# 10.3.1 Eindeutige Lösbarkeit von linearen Gleichungssystemen
check_functions["10.3.1"] = function(lösbar)
    @assert lösbar([1 -1
            2  3],[22, 11])
    @assert !lösbar([1 -1
            2  3
            9 -1],[22, 11, 3])
    @assert lösbar([1 3
            2  8
            3 11],[9, -3, 6])
    @assert !lösbar([1 1
                    2 2],[2, 3])
    @assert lösbar(rand(3,3),rand(3))
end

# 10.3.2 Löse das Gleichungsystem

check_functions["10.3.2"] = function(result)
    @assert all(result .≈ [-63.24999999999998, 45.833333333333314, 131.0833333333333])
end


# 10.3.3 Eigenwerte und Eigenvektoren

check_functions["10.3.3"] = function(rekonstruiere)
    As = [rand(x,x) for x in [rand(3:10) for _ in 1:10]]
    λ = eigvals.(As)
    ϕ = eigvecs.(As)
    @assert all(rekonstruiere.(λ,ϕ) .≈ As) "Fehler beim Rekonstruieren der Matrix."
end

# 10.3.3 Schreibe eine funktion zum Berechne des Winkels zwischen zwei Vektoren v1 und v2

check_functions["10.3.4"] = function(result)
    function check(v1,v2)
        res = result(v1,v2)
        @assert isa(res,Number) "Die Funktion sollte einen Winkel zurück geben."
        eq = res ≈ acos(v1⋅v2/(norm(v1)*norm(v2)))
        @assert eq  "Winkel für Vektoren $v1 und $v2 falsch berechnet. Hinweis: Der Winkel muss in rad berechnet werden."
    end
    check([1,2,3],[4,5,6])
    check([3.,1.,9.],[4.,-1.0,-3.])
    check([1,0,0],[1,0,0])
end

# 12. Controlflow

check_functions["11.3.1"] = function(result)
    function testit(number,expected)
        out = String[]
        run_redirected(output=out) do
            result(number)
        end
        @assert length(out) == 1 "Mehr als eine Zeile ausgegeben!"
        @assert first(out) == expected "Erwartete Ausgabe für '$number' ist '$expected'."
    end
    numbers = [rand(2:2:100) for _ in 1:10]
    testit.(numbers,Ref("Gerade"))
    numbers = [rand(1:2:101) for _ in 1:10]
    testit.(numbers,Ref("Ungerade"))
end

check_functions["11.3.2"] = function(result)
    inp = ["3","1.1","ggg","9",""]
    out = String[]
    run_redirected(result,input=inp,output=out)
    expected = ["Radius eingeben: A = 28.27", "U = 18.85", "", "Radius eingeben: A = 3.8", "U = 6.91", "", "Radius eingeben: Falsche Eingabe", "", "Radius eingeben: A = 254.47", "U = 56.55", "", "Radius eingeben: "]
    for (i,l) in enumerate(expected)
        @assert i <= length(out) "Erwartete Zeilenlänge stimmt nicht überein."
        @assert out[i] == l "Erwarte: '$(expected[i])' erhalten: '$(out[i])'"
    end
end

check_functions["11.3.3"] = function(result)
    @assert count([floor(result(1000),digits=0) for _ in 1:100] .== 3.0) > 90 "Falsch berechnet"
    @assert count([floor(result(1_000_000),digits=1) for _ in 1:20] .== 3.1) > 15 "Falsch berechnet"
end

check_functions["11.3.4"] = function(result)
    function check(f,a,b,expected,fname)
        x = collect(a:0.0001:b)
        @assert isapprox(result(x,f.(x)),expected,atol=1e-4) "Falsches Ergebnis für die Funktion '$fname' von '$a' nach '$b'"
    end
    check(x->cos(x^3),-2,1,1.78718,"cos(x^3)")
    check(x->(x^2/(1+sin(x))),-1,3,6.84768,"(x^2/(1+sin(x))")
end

using Statistics    

check_functions["11.3.5.1"] = function(result)
    inrange(x) = 0.0045 <= x <= 0.0046
    @assert all(inrange.([floor(result(10000000),digits=4) for _ in 1:10])) "Fehler bei der Berechnung"
    calcs = [floor(result(10^n),digits=4) for n in 0:3]
    @assert std(calcs) != 0.0 "Keine Änderung bei Erhöhung der Iterationen."
end

check_functions["11.3.5.2"] = function(result)
    inrange(x) = 0.420 <= x <= 0.423
    @assert all(inrange.([floor(result(10000000),digits=4) for _ in 1:10])) "Fehler bei der Berechnung"
    calcs = [floor(result(10^n),digits=4) for n in 0:3]
    @assert std(calcs) != 0.0 "Keine Änderung bei Erhöhung der Iterationen."
end

check_functions["11.3.6"] = function(result)
    function generate_random_sentence(number_of_words)
        sep = rand(['!',' ','_','*','-'])
        chrs = [Char(i) for i in vcat(65:65+25,97:97+25)]
        words = [join([rand(chrs) for i in 3:rand(4:10)])
                 for _ in 1:number_of_words]
        (sentence=join(words,sep),sep=sep,split=words)
    end
    t = generate_random_sentence(1)
    @donts result(t.sentence,t.sep) :split
    for i in 1:10
        t = generate_random_sentence(rand(3:5))
        @assert result(t.sentence,t.sep) == t.split "Fehler bei Aufruf mit '$(t.sentence)' und '$(t.sep)'."
    end
    t = generate_random_sentence(1)
    @assert result(t.sentence,t.sep) == t.split "Fehler bei Aufruf mit '$(t.sentence)' und '$(t.sep)'."
    @assert result(t.sep*t.sentence*t.sep,t.sep) == t.split "Fehler bei Aufruf mit '$(t.sep*t.sentence*t.sep)' und '$(t.sep)'."
    @assert result(t.sep*t.sentence*t.sep*t.sep*t.sentence,t.sep) == [t.sentence, t.sentence] "Fehler bei Aufruf mit '$(t.sep*t.sentence*t.sep*t.sep*t.sentence)' und '$(t.sep)'."
    @assert result(t.sentence,'+') == t.split "Fehler bei Aufruf mit '$(t.sentence)' und '+'."
end

check_functions["11.3.7"] = function(bsqrt)
    @donts bsqrt(9) :sqrt
    for _ in 1:100
        n = rand(2.0:0.01:100000.)
        @assert isapprox(bsqrt(n),sqrt(n),atol=1e-5) "Fehler bei der Berechnung von '$n'."
    end
end

# 11.3.8 Dictionaries zusammenfügen
check_functions["11.3.8"] = function(result)
	d1 = Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19)
	d2 = Dict("hh"=>5,"gg"=>31)
	d3 = Dict("hh"=>5,"gg"=>31,"pp"=>10)
	@assert result(d1,d2) == Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19,"hh"=>5,"gg"=>31)
	@assert result(d1,d3) == Dict("aa"=>4,"pp"=>10,"dd"=>3,"kk"=>19,"hh"=>5,"gg"=>31)
end

# 12. Debugger
# 12.3.1 ggt
check_functions["12.3.1"] = function(ggt)
    @donts ggt(8,9) :gcd
    a = rand(1:1000,1000); b = rand(1:1000,1000);
    @assert ggt.(a,b) == gcd.(a,b) "Fehler bei der Berechnung"
    @assert ggt(10,0) == gcd(10,0)
    @assert ggt(0,10) == gcd(0,10)
    @assert ggt(-2304,288) == gcd(-2304,288)
end


# 13. Spezielle Datentypen
using Dates
# 13.3.1 Zeiträtsel
check_functions["13.3.1"] = function(result)
    @dos result() :Date :Day :Week
    d = result()
    @assert Day(d) == Day(12)
    @assert Month(d) == Month(1)
end

# 14. FileIO
# 14.3.1 Survival lager
const stuff = ["Taschenmesser",
             "Taschenlampe",
             "Batterie",
             "Wasserflasche",
             "Schlafsack",
             "Gummistiefel",
             "Fernglas",
             "Reis",
             "Salz",
             "Konserven",
             "Dosenöffner",
             "Kocher",
             "Medikamente",
			 "Bier",
             ]
function pick_random()
    no = rand(1:40)
    return (thing=rand(stuff),change=no)
end
function make_lager()
    initial = rand(4:length(stuff))
    stuff_here = [
        pick_random()
        for i in 1:initial
    ]
end
all_things_in_lager(lager) = Set([x.thing for x in lager])
all_things_actually_in_lager(lager) = filter(all_things_in_lager(lager)) do t
    total_of_thing(lager,t) > 0
end
total_of_thing(lager,thing) = sum([x.change for x in lager if x.thing == thing])
function remove_something(lager)
    things_avail = all_things_actually_in_lager(lager)
    length(things_avail) == 0 && return nothing
    thing = rand(things_avail)
    amount = total_of_thing(lager,thing)
    take_out = rand(1:amount)
    push!(lager,(thing=thing,change=-take_out))
end
function add_something(lager)
    push!(lager,pick_random())
end
function do_something(lager)
    if rand(Bool)
        return add_something(lager)
    else
        return remove_something(lager)
    end
end
function rand_lager_history()
    lager = make_lager()
    for i in 1:rand(10:30)
        do_something(lager)
    end
    return lager
end
function rand_lager_history_collect()
    [rand_lager_history() for i in 1:rand(10:20)]
end
function save_lager(lager,name)
    open("$name.csv","w") do f
        write(f,"Artikel,Bestand\n")
        for t in lager
            write(f,"$(t.thing),$(t.change)\n")
        end
    end
end
function generate_survival_camp()
    path = "14-3"
    if isdir(path)
        rm(path,recursive=true,force=true)
    end
    mkdir(path)
    lagers = rand_lager_history_collect()
    for (i,lager) in enumerate(lagers)
        save_lager(lager,joinpath(path,"Lager$i"))
    end
    return lagers
end

setup_functions["14.3"] = function()
    Random.seed!(1234)
    generate_survival_camp()
    nothing
end
setup_functions["14.3.1"] = function()
    Random.seed!(1234)
    generate_survival_camp()
    nothing
end
setup_functions["14.3.2"] = function()
    Random.seed!(1234)
    generate_survival_camp()
    nothing
end
setup_functions["14.3.3"] = function()
    Random.seed!(1234)
    generate_survival_camp()
    nothing
end

check_functions["14.3.1"] = function(read_lagers)
    Random.seed!(RandomDevice())
    generate_survival_camp()
    @dos read_lagers() :joinpath
    for _ in 1:50
        camp = generate_survival_camp()
        bestand = read_lagers()
        for (i,lager) in enumerate(camp)
            for thing in all_things_in_lager(lager)
                tot = total_of_thing(lager,thing)
                @assert thing in keys(bestand[i]) "Erwarte $tot Einheiten von $thing in Lager $i, kein Eintrag gefunden.\nBeispiel Dateien unter '$(pwd())'"
                @assert tot == bestand[i][thing] "Falsche Anzahl bei Lager $i für $thing. Erwarte $tot, erhalten $(bestand[i][thing]).\nBeispiel Dateien unter: '$(pwd())'"
            end
        end
    end
end

check_functions["14.3.2"] = function(lager_mit)
    Random.seed!(RandomDevice())
    function get_lager_ids_with(camp,artikel,anzahl)
        ids = []
        for (id,lager) in enumerate(camp)
            for thing in all_things_in_lager(lager)
                tot = total_of_thing(lager,thing)
                if thing == artikel
                    tot >= anzahl && push!(ids,id)
                    break
                end
            end
        end
        return ids
    end
    camp = generate_survival_camp()
    things = reduce(∪,all_things_in_lager.(camp))
    @dos lager_mit(first(things),10) :joinpath
    for _ in 1:50
        camp = generate_survival_camp()
        things = reduce(∪,all_things_in_lager.(camp))
        for i in 1:100
            t = rand(things)
            c = rand(0:100)
            idsA = sort(get_lager_ids_with(camp,t,c))
            idsB = sort(lager_mit(t,c))
            @assert idsA == idsB "Falsche Ids. Erwarte $idsA, erhalten $idsB."
        end
    end
end

check_functions["14.3.3"] = function(gesamt_bestand)
    Random.seed!(RandomDevice())
    generate_survival_camp()
    @dos gesamt_bestand() :joinpath
    for _ in 1:50
        camp = generate_survival_camp()
        total = Dict{String,Int}()
        for (i,lager) in enumerate(camp)
            for thing in all_things_in_lager(lager)
                tot = total_of_thing(lager,thing)
                thing in keys(total) || (total[thing] = 0)
                total[thing] += tot
            end
        end
        beB = gesamt_bestand()
        @assert beB == total "Falscher Bestand erhoben. Erwarte $total, erhalten $beB"
    end
end

# Scores

set_score("3.5.1"   ,1.0)
set_score("7.4.1"   ,1.0)
set_score("7.4.2"   ,1.0)
set_score("7.4.3"   ,1.0)
set_score("7.4.4"   ,1.0)
set_score("7.4.5"   ,1.0)
set_score("8.5.1"   ,1.0)
set_score("8.5.2"   ,1.0)
set_score("8.5.3"   ,1.0)
set_score("8.5.4"   ,1.0)
set_score("8.5.5"   ,1.0)
set_score("8.5.6"   ,1.0)
set_score("10.3.1"  ,2.0)
set_score("10.3.2"  ,1.0)
set_score("10.3.3"  ,1.0)
set_score("10.3.4"  ,1.0)
set_score("11.3.1"  ,1.0)
set_score("11.3.2"  ,3.0)
set_score("11.3.3"  ,3.0)
set_score("11.3.4"  ,3.0)
set_score("11.3.5.1",1.5)
set_score("11.3.5.2",1.5)
set_score("11.3.6"  ,4.0)
set_score("11.3.7"  ,2.0)
set_score("11.3.8"  ,1.0)
set_score("12.3.1"  ,1.0)
set_score("13.3.1"  ,2.0)
set_score("14.3.1"  ,4.0)
set_score("14.3.2"  ,3.0)
set_score("14.3.3"  ,3.0)

# Solutions

solutions = Dict(
     "8.5.1" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 102, 114, 113, 113, 104, 102, 119, 98, 119, 107, 117, 104, 104, 43, 100, 47, 101, 47, 102, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 100, 115, 115, 104, 113, 103, 36, 43, 100, 115, 115, 104, 113, 103, 36, 43, 100, 47, 101, 44, 47, 102, 44, 13, 104, 113, 103],
     "8.5.5" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 103, 108, 102, 119, 98, 108, 113, 103, 104, 123, 43, 103, 47, 35, 113, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 103, 94, 118, 114, 117, 119, 43, 102, 114, 111, 111, 104, 102, 119, 43, 110, 104, 124, 118, 43, 103, 44, 44, 44, 94, 113, 96, 96, 13, 104, 113, 103],
     "10.3.1" => [120, 118, 108, 113, 106, 35, 79, 108, 113, 104, 100, 117, 68, 111, 106, 104, 101, 117, 100, 13, 35, 35, 35, 35, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 111, 249, 118, 101, 100, 117, 43, 68, 47, 101, 44, 13, 35, 35, 35, 35, 117, 100, 113, 110, 43, 68, 44, 35, 64, 64, 35, 117, 100, 113, 110, 43, 107, 102, 100, 119, 43, 68, 47, 101, 44, 44, 13, 104, 113, 103],
     "11.3.4" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 8750, 43, 123, 47, 124, 44, 13, 35, 35, 35, 35, 121, 100, 111, 35, 64, 35, 51, 49, 51, 13, 35, 35, 35, 35, 105, 114, 117, 35, 108, 35, 108, 113, 35, 52, 61, 112, 108, 113, 43, 111, 104, 113, 106, 119, 107, 43, 123, 44, 47, 111, 104, 113, 106, 119, 107, 43, 124, 44, 44, 48, 52, 13, 35, 35, 35, 35, 35, 35, 35, 35, 121, 100, 111, 35, 46, 64, 35, 43, 123, 94, 108, 46, 52, 96, 48, 123, 94, 108, 96, 44, 45, 43, 124, 94, 108, 96, 46, 124, 94, 108, 46, 52, 96, 44, 50, 53, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 121, 100, 111, 13, 104, 113, 103],
     "11.3.5.1" => [119, 107, 117, 114, 122, 43, 44, 35, 64, 35, 117, 100, 113, 103, 43, 52, 61, 57, 44, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 83, 98, 104, 118, 119, 98, 52, 43, 113, 44, 13, 35, 35, 35, 35, 118, 120, 112, 43, 94, 100, 111, 111, 43, 108, 48, 65, 108, 64, 64, 55, 47, 43, 119, 107, 117, 114, 122, 43, 44, 35, 105, 114, 117, 35, 98, 35, 108, 113, 35, 52, 61, 54, 44, 44, 35, 105, 114, 117, 35, 98, 98, 35, 108, 113, 35, 52, 61, 113, 96, 44, 50, 113, 13, 104, 113, 103],
     "7.4.2" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 121, 104, 117, 110, 104, 119, 119, 104, 43, 105, 47, 35, 106, 47, 35, 123, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 105, 43, 106, 43, 123, 44, 44, 13, 104, 113, 103],
     "11.3.8" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 103, 108, 102, 119, 98, 112, 104, 117, 106, 104, 43, 103, 52, 47, 35, 103, 53, 44, 13, 35, 35, 35, 35, 103, 35, 64, 35, 102, 114, 115, 124, 43, 103, 52, 44, 13, 35, 35, 35, 35, 105, 114, 117, 35, 110, 35, 108, 113, 35, 110, 104, 124, 118, 43, 103, 53, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 103, 94, 110, 96, 35, 64, 35, 103, 53, 94, 110, 96, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 103, 13, 104, 113, 103],
     "8.5.3" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 108, 118, 118, 114, 117, 119, 43, 100, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 100, 35, 64, 64, 35, 118, 114, 117, 119, 43, 100, 44, 13, 104, 113, 103],
     "10.3.4" => [120, 118, 108, 113, 106, 35, 79, 108, 113, 104, 100, 117, 68, 111, 106, 104, 101, 117, 100, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 122, 108, 113, 110, 104, 111, 43, 121, 52, 47, 121, 53, 44, 13, 35, 35, 35, 35, 100, 102, 114, 118, 43, 121, 52, 8904, 121, 53, 50, 43, 113, 114, 117, 112, 43, 121, 52, 44, 45, 113, 114, 117, 112, 43, 121, 53, 44, 44, 44, 13, 104, 113, 103],
     "11.3.3" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 963, 98, 112, 102, 43, 113, 61, 61, 76, 113, 119, 44, 13, 35, 35, 35, 35, 108, 113, 118, 108, 103, 104, 35, 64, 35, 51, 13, 35, 35, 35, 35, 105, 114, 117, 35, 98, 35, 108, 113, 35, 52, 61, 113, 13, 35, 35, 35, 35, 35, 35, 35, 35, 108, 113, 118, 108, 103, 104, 35, 46, 64, 35, 117, 100, 113, 103, 43, 44, 97, 53, 46, 117, 100, 113, 103, 43, 44, 97, 53, 35, 63, 64, 35, 52, 49, 51, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 55, 45, 108, 113, 118, 108, 103, 104, 50, 113, 13, 104, 113, 103],
     "14.3.2" => [120, 118, 108, 113, 106, 35, 70, 86, 89, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 117, 104, 100, 103, 98, 111, 100, 106, 104, 117, 118, 43, 44, 13, 35, 35, 35, 35, 38, 35, 49, 49, 49, 13, 104, 113, 103, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 111, 100, 106, 104, 117, 98, 112, 108, 119, 43, 100, 117, 119, 108, 110, 104, 111, 47, 100, 113, 125, 100, 107, 111, 44, 13, 35, 35, 35, 35, 111, 100, 106, 104, 117, 118, 35, 64, 35, 117, 104, 100, 103, 98, 111, 100, 106, 104, 117, 118, 43, 44, 13, 35, 35, 35, 35, 111, 98, 108, 103, 118, 35, 64, 35, 76, 113, 119, 94, 96, 13, 35, 35, 35, 35, 105, 114, 117, 35, 108, 35, 108, 113, 35, 110, 104, 124, 118, 43, 111, 100, 106, 104, 117, 118, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 111, 35, 64, 35, 111, 100, 106, 104, 117, 118, 94, 108, 96, 13, 35, 35, 35, 35, 35, 35, 35, 35, 108, 105, 35, 100, 117, 119, 108, 110, 104, 111, 35, 108, 113, 35, 110, 104, 124, 118, 43, 111, 44, 35, 41, 41, 35, 111, 94, 100, 117, 119, 108, 110, 104, 111, 96, 35, 65, 64, 35, 100, 113, 125, 100, 107, 111, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 115, 120, 118, 107, 36, 43, 111, 98, 108, 103, 118, 47, 108, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 111, 98, 108, 103, 118, 13, 104, 113, 103],
     "7.4.1" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 115, 117, 108, 113, 119, 98, 119, 107, 117, 104, 104, 43, 100, 44, 13, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 118, 119, 117, 108, 113, 106, 43, 100, 47, 37, 35, 37, 47, 100, 47, 37, 35, 37, 47, 100, 44, 44, 13, 104, 113, 103],
     "14.3.1" => [120, 118, 108, 113, 106, 35, 70, 86, 89, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 117, 104, 100, 103, 98, 111, 100, 106, 104, 117, 118, 43, 44, 13, 35, 35, 35, 35, 115, 100, 119, 107, 35, 64, 35, 37, 52, 55, 48, 54, 37, 13, 35, 35, 35, 35, 105, 108, 111, 104, 118, 35, 64, 35, 117, 104, 100, 103, 103, 108, 117, 43, 115, 100, 119, 107, 44, 13, 35, 35, 35, 35, 114, 120, 119, 115, 120, 119, 35, 64, 35, 71, 108, 102, 119, 126, 76, 113, 119, 47, 71, 108, 102, 119, 126, 86, 119, 117, 108, 113, 106, 47, 35, 76, 113, 119, 128, 128, 43, 44, 13, 35, 35, 35, 35, 105, 114, 117, 35, 105, 35, 108, 113, 35, 105, 108, 111, 104, 118, 13, 35, 35, 35, 35, 35, 35, 35, 35, 101, 104, 118, 119, 100, 113, 103, 35, 64, 35, 71, 108, 102, 119, 126, 86, 119, 117, 108, 113, 106, 47, 76, 113, 119, 128, 43, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 103, 100, 119, 100, 35, 64, 35, 70, 86, 89, 49, 73, 108, 111, 104, 43, 109, 114, 108, 113, 115, 100, 119, 107, 43, 115, 100, 119, 107, 47, 105, 44, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 105, 114, 117, 35, 117, 114, 122, 35, 108, 113, 35, 103, 100, 119, 100, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 108, 105, 35, 36, 43, 117, 114, 122, 49, 68, 117, 119, 108, 110, 104, 111, 35, 108, 113, 35, 110, 104, 124, 118, 43, 101, 104, 118, 119, 100, 113, 103, 44, 44, 35, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 101, 104, 118, 119, 100, 113, 103, 94, 117, 114, 122, 49, 68, 117, 119, 108, 110, 104, 111, 96, 35, 64, 35, 51, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 101, 104, 118, 119, 100, 113, 103, 94, 117, 114, 122, 49, 68, 117, 119, 108, 110, 104, 111, 96, 35, 46, 64, 35, 117, 114, 122, 49, 69, 104, 118, 119, 100, 113, 103, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 35, 35, 35, 35, 114, 120, 119, 115, 120, 119, 94, 115, 100, 117, 118, 104, 43, 76, 113, 119, 47, 105, 94, 57, 61, 104, 113, 103, 48, 55, 96, 44, 96, 35, 64, 35, 101, 104, 118, 119, 100, 113, 103, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 114, 120, 119, 115, 120, 119, 13, 104, 113, 103],
     "14.3.3" => [120, 118, 108, 113, 106, 35, 70, 86, 89, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 117, 104, 100, 103, 98, 111, 100, 106, 104, 117, 118, 43, 44, 13, 35, 35, 35, 35, 38, 35, 49, 49, 49, 13, 104, 113, 103, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 106, 104, 118, 100, 112, 119, 98, 101, 104, 118, 119, 100, 113, 103, 43, 44, 13, 35, 35, 35, 35, 111, 100, 106, 104, 117, 118, 35, 64, 35, 117, 104, 100, 103, 98, 111, 100, 106, 104, 117, 118, 43, 44, 13, 35, 35, 35, 35, 101, 104, 118, 119, 100, 113, 103, 35, 64, 35, 71, 108, 102, 119, 126, 86, 119, 117, 108, 113, 106, 47, 76, 113, 119, 128, 43, 44, 13, 35, 35, 35, 35, 105, 114, 117, 35, 108, 35, 108, 113, 35, 110, 104, 124, 118, 43, 111, 100, 106, 104, 117, 118, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 111, 35, 64, 35, 111, 100, 106, 104, 117, 118, 94, 108, 96, 13, 35, 35, 35, 35, 35, 35, 35, 35, 105, 114, 117, 35, 110, 35, 108, 113, 35, 110, 104, 124, 118, 43, 111, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 43, 110, 35, 108, 113, 35, 110, 104, 124, 118, 43, 101, 104, 118, 119, 100, 113, 103, 44, 44, 35, 127, 127, 35, 43, 101, 104, 118, 119, 100, 113, 103, 94, 110, 96, 35, 64, 35, 51, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 101, 104, 118, 119, 100, 113, 103, 94, 110, 96, 35, 46, 64, 35, 111, 94, 110, 96, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 101, 104, 118, 119, 100, 113, 103, 13, 35, 35, 35, 35, 104, 113, 103],
     "7.4.5" => [110, 117, 104, 108, 118, 98, 105, 111, 100, 104, 102, 107, 104, 43, 117, 44, 35, 64, 35, 117, 97, 53, 45, 963, 13, 110, 117, 104, 108, 118, 98, 120, 112, 105, 100, 113, 106, 43, 117, 44, 35, 64, 35, 53, 45, 117, 45, 963, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 110, 117, 104, 108, 118, 43, 117, 44, 13, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 117, 35, 64, 35, 39, 43, 117, 114, 120, 113, 103, 43, 117, 47, 103, 108, 106, 108, 119, 118, 64, 53, 44, 44, 37, 44, 13, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 68, 35, 64, 35, 39, 43, 117, 114, 120, 113, 103, 43, 110, 117, 104, 108, 118, 98, 105, 111, 100, 104, 102, 107, 104, 43, 117, 44, 47, 103, 108, 106, 108, 119, 118, 64, 53, 44, 44, 37, 44, 13, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 88, 35, 64, 35, 39, 43, 117, 114, 120, 113, 103, 43, 110, 117, 104, 108, 118, 98, 120, 112, 105, 100, 113, 106, 43, 117, 44, 47, 103, 108, 106, 108, 119, 118, 64, 53, 44, 44, 37, 44, 13, 104, 113, 103],
     "11.3.2" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 117, 104, 100, 103, 98, 117, 100, 103, 108, 120, 118, 43, 44, 13, 35, 35, 35, 35, 115, 117, 108, 113, 119, 43, 37, 85, 100, 103, 108, 120, 118, 35, 104, 108, 113, 106, 104, 101, 104, 113, 61, 35, 37, 44, 13, 35, 35, 35, 35, 117, 104, 100, 103, 111, 108, 113, 104, 43, 44, 13, 104, 113, 103, 13, 35, 35, 35, 35, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 68, 120, 113, 103, 88, 43, 117, 44, 13, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 68, 35, 64, 35, 39, 43, 117, 114, 120, 113, 103, 43, 117, 97, 53, 45, 963, 47, 103, 108, 106, 108, 119, 118, 64, 53, 44, 44, 37, 44, 13, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 88, 35, 64, 35, 39, 43, 117, 114, 120, 113, 103, 43, 53, 117, 45, 963, 47, 103, 108, 106, 108, 119, 118, 64, 53, 44, 44, 37, 44, 13, 104, 113, 103, 13, 35, 35, 35, 35, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 117, 120, 113, 43, 44, 13, 35, 35, 35, 35, 122, 107, 108, 111, 104, 35, 43, 108, 113, 115, 35, 64, 35, 117, 104, 100, 103, 98, 117, 100, 103, 108, 120, 118, 43, 44, 44, 35, 36, 64, 35, 37, 37, 13, 35, 35, 35, 35, 35, 35, 35, 35, 108, 105, 35, 43, 113, 120, 112, 101, 104, 117, 35, 64, 35, 119, 117, 124, 115, 100, 117, 118, 104, 43, 73, 111, 114, 100, 119, 57, 55, 47, 108, 113, 115, 44, 44, 35, 36, 64, 35, 113, 114, 119, 107, 108, 113, 106, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 68, 120, 113, 103, 88, 43, 113, 120, 112, 101, 104, 117, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 111, 118, 104, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 73, 100, 111, 118, 102, 107, 104, 35, 72, 108, 113, 106, 100, 101, 104, 37, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 44, 13, 35, 35, 35, 35, 104, 113, 103, 13, 104, 113, 103],
     "7.4.3" => [110, 117, 104, 108, 118, 98, 105, 111, 100, 104, 102, 107, 104, 43, 117, 44, 35, 64, 35, 117, 97, 53, 45, 963],
     "11.3.6" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 112, 124, 98, 118, 115, 111, 108, 119, 43, 118, 119, 117, 47, 102, 61, 61, 70, 107, 100, 117, 44, 13, 35, 35, 35, 35, 115, 120, 118, 107, 98, 113, 114, 98, 104, 112, 115, 119, 124, 36, 43, 100, 47, 101, 44, 35, 64, 35, 101, 35, 36, 64, 35, 37, 37, 35, 41, 41, 35, 115, 120, 118, 107, 36, 43, 100, 47, 101, 44, 13, 35, 35, 35, 35, 100, 117, 117, 35, 64, 35, 86, 119, 117, 108, 113, 106, 94, 96, 13, 35, 35, 35, 35, 111, 100, 118, 119, 98, 108, 103, 123, 35, 64, 35, 52, 13, 35, 35, 35, 35, 105, 114, 117, 35, 108, 35, 108, 113, 35, 52, 61, 111, 104, 113, 106, 119, 107, 43, 118, 119, 117, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 108, 105, 35, 118, 119, 117, 94, 108, 96, 35, 64, 64, 35, 102, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 115, 120, 118, 107, 98, 113, 114, 98, 104, 112, 115, 119, 124, 36, 43, 100, 117, 117, 47, 118, 119, 117, 94, 111, 100, 118, 119, 98, 108, 103, 123, 61, 108, 48, 52, 96, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 111, 100, 118, 119, 98, 108, 103, 123, 35, 64, 35, 108, 46, 52, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 115, 120, 118, 107, 98, 113, 114, 98, 104, 112, 115, 119, 124, 36, 43, 100, 117, 117, 47, 118, 119, 117, 94, 111, 100, 118, 119, 98, 108, 103, 123, 61, 104, 113, 103, 96, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 100, 117, 117, 13, 104, 113, 103],
     "8.5.6" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 119, 120, 115, 111, 104, 98, 100, 115, 115, 104, 113, 103, 43, 119, 52, 47, 35, 119, 53, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 87, 120, 115, 111, 104, 43, 100, 115, 115, 104, 113, 103, 36, 43, 102, 114, 111, 111, 104, 102, 119, 43, 119, 52, 44, 47, 102, 114, 111, 111, 104, 102, 119, 43, 119, 53, 44, 44, 44, 13, 104, 113, 103],
     "12.3.1" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 106, 106, 119, 43, 100, 61, 61, 76, 113, 119, 47, 101, 61, 61, 76, 113, 119, 44, 13, 35, 35, 35, 35, 101, 35, 64, 64, 35, 51, 35, 41, 41, 35, 117, 104, 119, 120, 117, 113, 35, 100, 13, 35, 35, 35, 35, 100, 35, 64, 64, 35, 51, 35, 41, 41, 35, 117, 104, 119, 120, 117, 113, 35, 101, 13, 35, 35, 35, 35, 105, 114, 117, 35, 119, 104, 108, 111, 104, 117, 35, 108, 113, 35, 112, 108, 113, 43, 100, 101, 118, 43, 100, 44, 47, 100, 101, 118, 43, 101, 44, 44, 61, 48, 52, 61, 51, 13, 35, 35, 35, 35, 35, 35, 35, 35, 108, 105, 35, 100, 40, 119, 104, 108, 111, 104, 117, 35, 64, 64, 35, 51, 35, 41, 41, 35, 101, 40, 119, 104, 108, 111, 104, 117, 35, 64, 64, 35, 51, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 119, 104, 108, 111, 104, 117, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 52, 13, 104, 113, 103],
     "10.3.2" => [120, 118, 108, 113, 106, 35, 79, 108, 113, 104, 100, 117, 68, 111, 106, 104, 101, 117, 100, 13, 68, 35, 64, 35, 94, 52, 35, 48, 52, 35, 52, 13, 35, 35, 35, 35, 53, 35, 54, 35, 51, 13, 35, 35, 35, 35, 52, 51, 35, 48, 51, 49, 56, 35, 56, 13, 35, 35, 35, 35, 96, 13, 101, 35, 64, 35, 94, 53, 53, 47, 52, 52, 47, 35, 51, 96, 13, 68, 95, 101],
     "11.3.1" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 106, 104, 117, 100, 103, 104, 98, 120, 113, 106, 104, 117, 100, 103, 104, 43, 123, 61, 61, 76, 113, 119, 44, 13, 35, 35, 35, 35, 108, 105, 35, 123, 35, 40, 35, 53, 35, 64, 64, 35, 51, 13, 35, 35, 35, 35, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 74, 104, 117, 100, 103, 104, 37, 44, 13, 35, 35, 35, 35, 104, 111, 118, 104, 13, 35, 35, 35, 35, 35, 35, 35, 35, 115, 117, 108, 113, 119, 111, 113, 43, 37, 88, 113, 106, 104, 117, 100, 103, 104, 37, 44, 13, 35, 35, 35, 35, 104, 113, 103, 13, 104, 113, 103],
     "10.3.3" => [120, 118, 108, 113, 106, 35, 79, 108, 113, 104, 100, 117, 68, 111, 106, 104, 101, 117, 100, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 117, 104, 110, 114, 113, 118, 119, 117, 120, 108, 104, 117, 104, 43, 958, 47, 984, 44, 13, 35, 35, 35, 35, 984, 45, 71, 108, 100, 106, 114, 113, 100, 111, 43, 958, 44, 45, 108, 113, 121, 43, 984, 44, 13, 104, 113, 103],
     "13.3.1" => [120, 118, 108, 113, 106, 35, 71, 100, 119, 104, 118, 13, 108, 118, 103, 100, 119, 104, 43, 123, 47, 124, 44, 35, 64, 35, 71, 100, 119, 104, 118, 49, 121, 100, 111, 120, 104, 43, 71, 100, 124, 43, 123, 44, 44, 35, 64, 64, 35, 71, 100, 119, 104, 118, 49, 121, 100, 111, 120, 104, 43, 80, 114, 113, 119, 107, 43, 124, 44, 44, 35, 41, 41, 35, 71, 100, 119, 104, 118, 49, 121, 100, 111, 120, 104, 43, 71, 100, 124, 43, 124, 44, 44, 35, 64, 64, 35, 71, 100, 119, 104, 118, 49, 121, 100, 111, 120, 104, 43, 80, 114, 113, 119, 107, 43, 123, 44, 44, 13, 35, 35, 35, 35, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 106, 104, 119, 98, 103, 100, 119, 104, 43, 44, 13, 35, 35, 35, 35, 105, 114, 117, 35, 103, 35, 108, 113, 35, 117, 100, 113, 106, 104, 43, 71, 100, 119, 104, 43, 53, 51, 52, 58, 47, 52, 47, 52, 44, 47, 71, 100, 119, 104, 43, 53, 51, 52, 58, 47, 52, 53, 47, 54, 52, 44, 47, 118, 119, 104, 115, 64, 71, 100, 124, 43, 52, 44, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 108, 105, 35, 108, 118, 103, 100, 119, 104, 43, 103, 47, 103, 46, 90, 104, 104, 110, 43, 57, 44, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 103, 46, 90, 104, 104, 110, 43, 57, 44, 13, 35, 35, 35, 35, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 104, 113, 103, 13, 104, 113, 103],
     "8.5.2" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 108, 113, 119, 104, 117, 108, 114, 117, 43, 100, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 100, 94, 53, 61, 104, 113, 103, 48, 52, 96, 13, 104, 113, 103],
     "11.3.5.2" => [119, 107, 117, 114, 122, 43, 44, 35, 64, 35, 117, 100, 113, 103, 43, 52, 61, 57, 44, 13, 105, 120, 113, 102, 119, 108, 114, 113, 35, 83, 98, 104, 118, 119, 98, 53, 43, 113, 44, 13, 35, 35, 35, 35, 118, 120, 112, 43, 94, 100, 113, 124, 43, 108, 48, 65, 108, 64, 64, 55, 47, 43, 119, 107, 117, 114, 122, 43, 44, 35, 105, 114, 117, 35, 98, 35, 108, 113, 35, 52, 61, 54, 44, 44, 35, 105, 114, 117, 35, 98, 98, 35, 108, 113, 35, 52, 61, 113, 96, 44, 50, 113, 13, 104, 113, 103],
     "11.3.7" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 101, 118, 116, 117, 119, 43, 100, 44, 13, 35, 35, 35, 35, 123, 35, 64, 35, 100, 50, 53, 13, 35, 35, 35, 35, 122, 107, 108, 111, 104, 35, 100, 101, 118, 43, 123, 45, 123, 48, 100, 44, 35, 65, 64, 35, 52, 104, 48, 56, 13, 35, 35, 35, 35, 35, 35, 35, 35, 123, 35, 64, 35, 43, 123, 46, 100, 50, 123, 44, 50, 53, 13, 35, 35, 35, 35, 104, 113, 103, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 123, 13, 104, 113, 103],
     "7.4.4" => [110, 117, 104, 108, 118, 98, 120, 112, 105, 100, 113, 106, 43, 117, 44, 35, 64, 35, 53, 45, 117, 45, 963],
     "8.5.4" => [105, 120, 113, 102, 119, 108, 114, 113, 35, 108, 118, 100, 113, 100, 106, 117, 100, 112, 43, 118, 52, 47, 35, 118, 53, 44, 13, 35, 35, 35, 35, 117, 104, 119, 120, 117, 113, 35, 118, 114, 117, 119, 43, 102, 114, 111, 111, 104, 102, 119, 43, 111, 114, 122, 104, 117, 102, 100, 118, 104, 43, 118, 52, 44, 44, 44, 35, 64, 64, 35, 118, 114, 117, 119, 43, 102, 114, 111, 111, 104, 102, 119, 43, 111, 114, 122, 104, 117, 102, 100, 118, 104, 43, 118, 53, 44, 44, 44, 13, 104, 113, 103],
    )
for k in keys(solutions)
    set_solution(k, solutions[k])
end


