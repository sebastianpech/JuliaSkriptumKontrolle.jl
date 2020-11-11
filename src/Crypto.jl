const max_char = 2097151

function safe_shift(c::Char; shift::Int)
    d = Int(c)
    if d + shift > max_char
        d = d + shift - max_char - 1
    elseif Int(d) + shift < 0
        d = max_char + 1 - d + shift
    else
        d = d + shift
    end
    return Char(d)
end

caesar(data_str::String; shift::Int) = join(safe_shift.(collect(data_str), shift=shift))
encode(data_str::String; shift::Int) = caesar(data_str; shift=shift)
decode(data_str::String; shift::Int) = caesar(data_str; shift=-shift)

