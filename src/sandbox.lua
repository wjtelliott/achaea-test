local playerIsClass = require('src/bard/bard-conditionals').playerIsClass

local mockContext = {
  gmcp = {
    Char = {
      Status = {
        class = 'Bard'
      }
    }
  }
}

function expect(actual)
  return {
    toBe = function(expected)
      if actual ~= expected then
        error('Expected ' .. actual .. ' to be ' .. expected)
      end
    end,
    toBeTruthy = function()
      if not actual then
        error('Expected ' .. actual .. ' to be truthy')
      end
    end,
    toBeFalsy = function()
      if actual then
        error('Expected ' .. actual .. ' to be falsy')
      end
    end,
    toBeGreaterThan = function(expected)
      if actual <= expected then
        error('Expected ' .. actual .. ' to be greater than ' .. expected)
      end
    end,
    toBeLessThan = function(expected)
      if actual >= expected then
        error('Expected ' .. actual .. ' to be less than ' .. expected)
      end
    end,
    toBeCloseTo = function(expected, precision)
      if math.abs(actual - expected) > precision then
        error('Expected ' .. actual .. ' to be close to ' .. expected .. ' with precision ' .. precision)
      end
    end,
    toBeInstanceOf = function(expected)
      if not (type(actual) == 'table' and actual.__name == expected) then
        error('Expected ' .. actual .. ' to be an instance of ' .. expected)
      end
    end,
    toBeTypeOf = function(expected)
      if type(actual) ~= expected then
        error('Expected ' .. actual .. ' to be a type of ' .. expected)
      end
    end
  }
end

function describe(name, callback)
  print(name)
  callback()
end

function it(name, callback)
  print('  ' .. name)
  callback()
end

describe('bard-conditionals', function()
  it('should return true if the player is the class', function()
    expect(playerIsClass('Bard')(mockContext)).toBe(true)
  end)

  it('should return false if the player is not the class', function()
    expect(playerIsClass('Warrior')(mockContext)).toBe(false)
  end)
end)