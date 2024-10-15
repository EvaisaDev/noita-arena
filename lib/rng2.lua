local rnglib = {}

rnglib.new = function(seed)
  local self = {seed = seed or os.time()}

  -- Xorshift algorithm for generating pseudorandom numbers
  self.nextint = function()
    self.seed = bit.bxor(self.seed, bit.lshift(self.seed, 13))
    self.seed = bit.bxor(self.seed, bit.rshift(self.seed, 17))
    self.seed = bit.bxor(self.seed, bit.lshift(self.seed, 5))
    return self.seed
  end

  -- Generate a random float between 0 and 1
  self.nextfloat = function()
    return self.nextint() / 0xFFFFFFFF
  end

  self.random = self.nextfloat

  -- Generate a random integer within a range (inclusive)
  self.range = function(min, max)
    return min + (self.nextint() % (max - min + 1))
  end

  return self
end

return rnglib