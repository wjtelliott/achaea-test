--[[
  Are you tired of writing if-elseif-elseif-elseif into ad nauseam?
  Well, I am. So I wrote this function to make your life easier.

  usage:
  switchCase({
    { condition (false), function() return 'hello' end },
    { condition (true), function() return 'world' end }
    --usually you would have a default case too
    { true, function() return 'default' end }
  })

  returns the result of the function for the first condition that returns true, which in this example would be 'world'
]]--
local function switchCase(cases)
  for _,case in ipairs(cases) do
    local condition = case[1]
    local actions = case[2]
    if condition then return actions() end
  end
end

local function afflictionValueRanges()
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
  return {
    unlikelyChance = values(33),
    halfChance = values(50),
    likelyChance = values(60),
    veryLikelyChance = values(66),
    certainChance = values(100),
  }
end

return {
  switchCase = switchCase,
  afflictionValueRanges = afflictionValueRanges
}