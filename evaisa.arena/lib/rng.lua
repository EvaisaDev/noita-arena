-- random number generator with seperated states

local rng = {}

local round = function(x)
    return math.floor(x + 0.5)
end

function rng.new(seed)
    local self = {}
    self.seed = seed
    self.state = seed
    self.next = function()
        self.state = (self.state * 214013 + 2531011) % 4294967296
        return self.state
    end
    self.next_float = function()
        return self.next() / 4294967296
    end
    self.next_int = function(max)
        return round(self.next_float() * max)
    end
    self.next_range = function(min, max)
        return min + self.next_float() * (max - min + 1)
    end
    self.next_bool = function()
        return self.next() % 2 == 0
    end
    self.next_choice = function(choices)
        return choices[self.next_int(#choices) + 1]
    end
    self.next_shuffle = function(t)
        for i = #t, 2, -1 do
            local j = self.next_int(i) + 1
            t[i], t[j] = t[j], t[i]
        end
    end
    self.next_normal = function()
        local u1 = self.next_float()
        local u2 = self.next_float()
        local r = math.sqrt(-2 * math.log(u1))
        local theta = 2 * math.pi * u2
        return r * math.cos(theta)
    end
    self.next_normal_range = function(min, max)
        return min + (max - min) * (self.next_normal() + 3) / 6
    end
    self.next_normal_int = function(min, max)
        return math.floor(self.next_normal_range(min, max + 1))
    end
    self.range = function(min, max, debug)
        local out = self.next_range(min, max)
        return math.floor(out)
    end
    self.float_range = function(min, max)
        return self.next_range(min, max)
    end
    self.random = self.next_float
    return self
end

return rng