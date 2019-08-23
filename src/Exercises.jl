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

# 11. Lineare Algebra

# 11.3.1 Löse das Gleichungsystem

check_functions["11.3.1"] = function(result)
    @assert all(result .≈ [-63.24999999999998, 45.833333333333314, 131.0833333333333])
end
set_score("11.3.1",1.0)


# 11.3.2 Verwende die Funktionen eigvals und eigvecs
# Result must be a named dict with
# (λ=eigenval, Φ=eigenvec, A_neu=reconstructed)

check_functions["11.3.2"] = function(result)
    @assert sort(collect(keys(results))) == sort((:λ, :Φ, :A_neu))
    @assert results.λ ≈ [-0.33159580731341975 2.7486771373723475 6.58291866994107]
    @assert results.Φ ≈ [ -0.443127   0.0985892  -0.160077
                          0.266015  -0.784562   -0.0893556
                          0.856081  -0.612162   -0.983052]
end
set_score("11.3.2",1.0)

# 11.3.3 Berechne den Winkel zwischen den Vektoren v1 und v2

check_functions["11.3.3"] = function(result)
    @assert result ≈ 0.20749622643520305
end
set_score("11.3.3",1.0)
