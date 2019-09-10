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

# 8.4.6 Dictionaries zusammenfügen
check_functions["8.4.6"] = function(result)
	d1 = Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19)
	d2 = Dict("hh"=>5,"gg"=>31)
	@assert result(d1,d2) == Dict("aa"=>4,"pp"=>1,"dd"=>3,"kk"=>19,"hh"=>5,"gg"=>31)
end
set_score("8.4.6",1.0)

# 8.4.7 Tuples zusammenfügen
check_functions["8.4.7"] = function(result)
	@assert result(('a','b'),('c','d','e')) == ('a','b','c','d','e')
end
set_score("8.4.7",1.0)

# 10. Lineare Algebra

# 10.3.1 Löse das Gleichungsystem

check_functions["10.3.1"] = function(result)
    @assert all(result .≈ [-63.24999999999998, 45.833333333333314, 131.0833333333333])
end
set_score("10.3.1",1.0)


# 10.3.2 Verwende die Funktionen eigvals und eigvecs
# Result must be a named dict with
# (eigenwerte=eigenval, eigenvektoren=eigenvec, rekonstruiert=reconstructed)

check_functions["10.3.2"] = function(result)
    @assert sort(collect(keys(result))) == sort([ :eigenwerte, :eigenvektoren, :rekonstruiert ]) "Die letzte Zeile muss (eigenwerte=..., eigenvektoren=..., rekonstruiert=...) lauten, wobei eigenwerte der Vector aller Eigenwerte, eigenvektoren eine Matrix aller Eigenvektoren und rekonstruiert die rekonstruierte Matrix sein muss."
    @assert all(isapprox.(result.eigenwerte, [-0.33159580731341975, 2.7486771373723475, 6.58291866994107],atol=1e-4)) "Eigenwerte falsch berechnet."
    @assert all(isapprox.(result.eigenvektoren, [ -0.443127   0.0985892  -0.160077
                                                  0.266015  -0.784562   -0.0893556
                                                  0.856081  -0.612162   -0.983052], atol=1e-4)) "Eigenvektoren falsch berechnet."
    @assert all(isapprox.(result.rekonstruiert,[1 -1 1
                                                    2  3 0
                                                    10 -0.5 5],atol=1e-4)) "Fehler beim Rekonstruieren der Matrix."
end
set_score("10.3.2",1.0)

# 10.3.3 Schreibe eine funktion zum Berechne des Winkels zwischen zwei Vektoren v1 und v2
using LinearAlgebra

check_functions["10.3.3"] = function(result)
    function check(v1,v2)
        eq = result(v1,v2) ≈ rad2deg(acos(v1⋅v2/(norm(v1)*norm(v2))))
        @assert eq  "Winkel für Vektoren $v1 und $v2 falsch berechnet. Hinweis: Der Winkel muss in rad berechnet werden."
    end
    check([1,2,3],[4,5,6])
    check([3.,1.,9.],[4.,-1.0,-3.])
    check([1,0,0],[1,0,0])
end
set_score("10.3.3",1.0)
