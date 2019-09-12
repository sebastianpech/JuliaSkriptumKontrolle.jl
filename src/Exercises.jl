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
set_score("3.5.1",1.0)

# 7. Funktionen
# 7.4.1 Dreimal printen
check_functions["7.4.1"] = function(result)
	out = String[]
	inp = ["foo","zack"]
	res = run_redirected(input=inp,output=out) do
		result()
	end
	@assert out != ["foofoofoo","zackzackzack"] "Abstand vergessen"
	@assert out == ["foo foo foo","zack zack zack"]
end
set_score("7.4.1",1.0)

# 7.4.2 Verketten
check_functions["7.4.2"] = function(result)
	f(x) = x+5
	g(x) = x^3
	@assert result(f,g,3) == 3^3+5
	@assert result(length,g,"foo") == 9
end
set_score("7.4.2",1.0)

# 7.4.3 Kreisfläche

check_functions["7.4.3"] = function(result)
	@assert result(3) == 3^2*π
	@assert result(5) == 5^2*π
end
set_score("7.4.3",1.0)

# 7.4.4 Kreisumfang

check_functions["7.4.4"] = function(result)
	@assert result(3) == 2*3*π
	@assert result(5) == 2*5*π
end
set_score("7.4.4",1.0)

# 7.4.5 Kreis: Eigenschaften printen
check_functions["7.4.5"] = function(result)
	
end
set_score("7.4.5",1.0)

# 8. Arrays, Dicts, Tuples
# 8.4.1 Drei Arrays zusammenhängen
check_functions["8.4.1"] = function(result)
	n1 = [1,2]; n2 = [3,4]; n3 = [5,6]
	s1 = ["aa","bb"]
	c1 = ['a', 'b']
	@assert result(n1,n2,n3) == [1,2,3,4,5,6]
	@assert result(n1,s1,c1) == [1,2,"aa","bb",'a','b']
end
set_score("8.4.1",1.0)

# 8.4.2 Inneres eines Arrays
check_functions["8.4.2"] = function(result)
	a = [9,8,7,6,5]
	b = [8,7,6]
	c = [7]
	@assert result(a) == b
	@assert result(b) == c
	@assert result(c) == []
end
set_score("8.4.2",1.0)

# 8.4.3 Ist das Array sortiert?
check_functions["8.4.3"] = function(result)
	@assert result(['s','p','a','m']) == false
	@assert result(['a','m','p','s']) == true
end
set_score("8.4.3",1.0)

# 8.4.4 Anagram-Test
check_functions["8.4.4"] = function(result)
	@assert result("spam","amps") == true
	@assert result("spam","eggs") == false
end
set_score("8.4.4",1.0)

# 8.4.5 N-tes Element eines Dictionaries ausgeben
check_functions["8.4.5"] = function(result)
	d = Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19)
	@assert result(d,1) == 4
	@assert result(d,3) == 19
end
set_score("8.4.5",1.0)

# 8.4.6 Tuples zusammenfügen
check_functions["8.4.6"] = function(result)
	@assert result(('a','b'),('c','d','e')) == ('a','b','c','d','e')
end
set_score("8.4.6",1.0)

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
set_score("10.3.1",1.0)

# 10.3.2 Löse das Gleichungsystem

check_functions["10.3.2"] = function(result)
    @assert all(result .≈ [-63.24999999999998, 45.833333333333314, 131.0833333333333])
end
set_score("10.3.2",1.0)


# 10.3.3 Eigenwerte und Eigenvektoren

check_functions["10.3.3"] = function(rekonstruiere)
    As = [rand(x,x) for x in [rand(3:10) for _ in 1:10]]
    λ = eigvals.(As)
    ϕ = eigvecs.(As)
    @assert all(rekonstruiere.(λ,ϕ) .≈ As) "Fehler beim Rekonstruieren der Matrix."
end
set_score("10.3.3",1.0)

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
set_score("10.3.4",1.0)

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
set_score("11.3.1",1.0)

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
set_score("11.3.2",1.0)

check_functions["11.3.3"] = function(result)
    @assert count([floor(result(1000),digits=0) for _ in 1:100] .== 3.0) > 90 "Falsch berechnet"
    @assert count([floor(result(1_000_000),digits=1) for _ in 1:20] .== 3.1) > 15 "Falsch berechnet"
end
set_score("11.3.3",1.0)

check_functions["11.3.4"] = function(result)
    function check(f,a,b,expected,fname)
        x = collect(a:0.0001:b)
        @assert isapprox(result(x,f.(x)),expected,atol=1e-4) "Falsches Ergebnis für die Funktion '$fname' von '$a' nach '$b'"
    end
    check(x->cos(x^3),-2,1,1.78718,"cos(x^3)")
    check(x->(x^2/(1+sin(x))),-1,3,6.84768,"(x^2/(1+sin(x))")
end
set_score("11.3.4",1.0)

using Statistics    

check_functions["11.3.5.1"] = function(result)
    inrange(x) = 0.0045 <= x <= 0.0046
    @assert all(inrange.([floor(result(10000000),digits=4) for _ in 1:10])) "Fehler bei der Berechnung"
    calcs = [floor(result(10^n),digits=4) for n in 0:3]
    @assert !any(inrange.(calcs)) "Zu hohe Genauigkeit bei geringer Anzahl an Iterationen."
    @assert std(calcs) != 0.0 "Keine Änderung bei Erhöhung der Iterationen."
end
set_score("11.3.5.1",0.5)

check_functions["11.3.5.2"] = function(result)
    inrange(x) = 0.420 <= x <= 0.423
    @assert all(inrange.([floor(result(10000000),digits=4) for _ in 1:10])) "Fehler bei der Berechnung"
    calcs = [floor(result(10^n),digits=4) for n in 0:3]
    @assert std(calcs) != 0.0 "Keine Änderung bei Erhöhung der Iterationen."
end
set_score("11.3.5.2",0.5)

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
    @assert result(t.sep*t.sentence*t.sep*t.sep*t.sentence,t.sep) == [t.sentence, t.sentence] "Fehler bei Aufruf mit '$(t.sep*t.sentence*t.sep)' und '$(t.sep)'."
    @assert result(t.sentence,'+') == t.split "Fehler bei Aufruf mit '$(t.sentence)' und '+'."
end
set_score("11.3.6",1.0)

check_functions["11.3.7"] = function(bsqrt)
    @donts bsqrt(9) :sqrt
    for _ in 1:100
        n = rand(2.0:0.01:100000.)
        @assert isapprox(bsqrt(n),sqrt(n),atol=1e-5) "Fehler bei der Berechnung von '$n'."
    end
end
set_score("11.3.7",1.0)

# 11.3.8 Dictionaries zusammenfügen
check_functions["11.3.8"] = function(result)
	d1 = Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19)
	d2 = Dict("hh"=>5,"gg"=>31)
	d3 = Dict("hh"=>5,"gg"=>31,"pp"=>10)
	@assert result(d1,d2) == Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19,"hh"=>5,"gg"=>31)
	@assert result(d1,d3) == Dict("aa"=>4,"pp"=>10,"dd"=>3,"kk"=>19,"hh"=>5,"gg"=>31)
end
set_score("11.3.8",1.0)

using Dates
 
# 14. Spezielle Datentypen
# 14.3.1 Zeiträtsel
check_functions["14.3.1"] = function(result)
    @dos result() :Date :Day :Week
    d = result()
    @assert Day(d) == Day(12)
    @assert Month(d) == Month(1)
end
set_score("14.3.1",1.0)
