# JuliaSkriptumKontrolle

[![Build Status](https://travis-ci.org/sebastianpech/JuliaSkriptumKontrolle.jl.svg?branch=master)](https://travis-ci.org/sebastianpech/JuliaSkriptumKontrolle.jl)

## Sandbox

Jeder Kontrolle wird in einer eigene Sandbox in einem temporären Verzeichnis ausgeführt.

## Setup

Mit dem `Dict` `setup_functions` kann eine Funktion definiert werden die vor dem Aufruf der Kontrollfunktion aufgerufen wird.
Die Funktion `setup(identifier)` soll auch vom User verwendet werden, falls extra Daten oder sonstige Aktion vor dem Start der Aufgabe notwendig sind.

Speziell zum kopieren von Daten gibt es den Ordern `exercise_data`. Findet die Funktion `setup` dort eine Order der wie der Aufgaben `identifer` lautet, wird der gesamte Order ins aktuelle Verzeichnis kopiert.

## Kontrollfunktionen
Die Kontrollfunktionen sollten im Paket definiert werden, damit der
User nur die eigenen Funktionen sieht und nicht durch die Funktionen
gestört wird.

### Kontrolle für Aufgabe 1.1

Die Kontrollfunktion muss zum `Dict` `JuliaSkriptumKontrolle.check_functions` hinzugefügt werden.
Jeder Kontrollfunktion wird ein Parameter übergeben der das Ergebnis der zu Bewertenden `Expr` beinhaltet.
Die folgende Funktion überprüft eine Funktion die eine Zahl > 0 quadrieren und für alle anderen Fälle 0 zurück geben soll.

Die Checkfunktion muss einen Fehler verursachen, damit ein korrekter globaler Eintrag gemacht wird ob die Aufgabe korrekt erfüllt wurde.

```julia
check_functions["1.1"] = function(result)
    @assert result(2) === 4
    @assert result(-2.) === 0.0
end
```

### Kontrolle für Aufgabe 1.2

Die Funktion kontrolliert eine Funktion die einen Text von `stdin` einliest und doppelt nach `stdout` ausgibt.
Wird `exit` eingelesen bricht die Funktion ab und gibt die Anzahl an Schleifenzyklen zurück.

```julia
check_functions["1.2"] = function(result)
    out = String[]
    inp = ["foo", "bar", "baz", "exit"]
    # An output und input können String Arrays übergeben werden.
    # Alle Werte in input werden an stdin geschickt und output
    # beinhaltet nach der Ausführung die an stdout gesendeten
    # Texte.
    res = run_redirected(input=inp,output=out) do
        result()
    end
    @assert out == ["foofoo", "barbar", "bazbaz"] 
    @assert count == 4
end
```

## Kontrolle für den Benutzer

Zur Kontrolle kann das Macro `@Aufgabe "Identifikation" Expr` verwendet werden.

### Aufgabe 1.1

```julia
@Aufgabe "1.1" function square_if_positive(x)
    return x^2
end
# --> Falsch!

@Aufgabe "1.1" function square_if_positive(x)
    if x < 0
        return zero(x)
    else
        return x^2
    end
end
# --> Richtig!
```

### Aufgabe 1.2

```julia
@Aufgabe "1.2" function double_input()
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

```
