-- local bardScript = require('src.bard')
-- local context = bardScript.context
-- bardScript.run(context)

local function values(valueToCheck)
  return function(actual)
    return {
      isLessThan = function() return actual < valueToCheck end,
      isGreaterThan = function() return actual > valueToCheck end,
      isEqualTo = function() return actual == valueToCheck end,
      isEqualOrGreater = function() return actual >= valueToCheck end,
      isEqualOrLess = function() return actual <= valueToCheck end,
    }
  end
end

local unlikelyChance = values(33)
local halfChance = values(50)
local likelyChance = values(60)
local veryLikelyChance = values(66)
local certainChance = values(100)

-- values that could occur during runtime
local asthmaValue = 32
local impatienceValue = 73
local slicknessValue = 50

-- test our chances against less than 33, expect all these to print 'true'
print('asthmaValue is less than 33:', unlikelyChance(asthmaValue).isLessThan())
print('impatienceValue is greater than 66:', veryLikelyChance(impatienceValue).isGreaterThan())
print('slicknessValue is equal to 50:', halfChance(slicknessValue).isEqualTo())