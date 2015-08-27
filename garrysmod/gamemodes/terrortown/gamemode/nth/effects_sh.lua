
local e = {}

local names = {"Quad", "Cubic", "Quart", "Quint", "Expo"}

for i=1,#names do
    e[names[i]] = (function(p)
        return math.pow(p, i + 2)
    end)
end

e.Sine = function(p)
    return 1 - math.cos(p * math.pi / 2)
end

e.Circ = function(p)
    return 1 - math.sqrt(1 - p * p)
end

e.Elastic = function(p)
    if p == 0 or p == 1 then
        return p
    end
    
    return -math.pow(2, 8 * (p - 1)) * math.sin(( (p - 1) * 80 - 7.5) * math.pi / 15);
end

e.Back = function(p)
    return p * p * (3 * p - 2);
end

e.Bounce = function (p)
    local pow2
    local bounce = 4

    while true do
        bounce = bounce - 1
        pow2 = math.pow(2, bounce)
        if p < (pow2 - 1) / 11 then
            break
        end
    end
    return 1 / math.pow( 4, 3 - bounce ) - 7.5625 * math.pow( ( pow2 * 3 - 2 ) / 22 - p, 2 )
end

NTH.Effects = {}

for name,func in pairs(e) do
    local EaseIn = function(p)
        return func(math.min(math.max(p,0), 1))
    end
    NTH.Effects["EaseIn" .. name] = EaseIn
    NTH.Effects["EaseOut" .. name] = function(p)
        return 1 - EaseIn(1 - p)
    end
    NTH.Effects["EaseInOut" .. name] = function(p)
        if p < 0.5 then
            return EaseIn(p * 2) / 2
        else
            return 1 - EaseIn(p * -2 + 2) / 2
        end
    end
end
