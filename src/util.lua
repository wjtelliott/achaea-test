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

--[[
  This function is used to make it easier to write affliction checks.
  It returns a table with functions that return a table with functions that return booleans.
  This allows you to write code like this:
  local afflictionValues = afflictionValueRanges()
  if afflictionValues.certainChance(asthma).isLessThan() then
    -- asthma is less than 100
  end

  Increases readbility but probably might scrap this, depends on how much we use it in the long haul
]]--
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


-- since i can't believe that the lua standard library doesn't have map, filter, or reduce... here's my own implementations
-- i'm not sure if i'll use these, but i'm keeping them here for now

local function map(list, callback)
  local mappedList = {}
  for _,v in ipairs(list) do
    table.insert(mappedList, callback(v))
  end
  return mappedList
end

local function filter(list, callback)
  local filteredList = {}
  for _,v in ipairs(list) do
    if callback(v) then table.insert(filteredList, v) end
  end
  return filteredList
end

local function reduce(list, callback, initialValue)
  local accumulator = initialValue or 0
  for _,v in ipairs(list) do
    accumulator = callback(accumulator, v)
  end
  return accumulator
end

-- and heres some for tables:
local function mapTable(table, callback)
  local mappedTable = {}
  for k,v in pairs(table) do
    mappedTable[k] = callback(v)
  end
  return mappedTable
end

local function filterTable(table, callback)
  local filteredTable = {}
  for k,v in pairs(table) do
    if callback(v) then filteredTable[k] = v end
  end
  return filteredTable
end

local function reduceTable(table, callback, initialValue)
  local accumulator = initialValue or 0
  for _,v in pairs(table) do
    accumulator = callback(accumulator, v)
  end
  return accumulator
end

return {
  switchCase = switchCase,
  afflictionValueRanges = afflictionValueRanges,
  map = map,
  filter = filter,
  reduce = reduce,
  mapTable = mapTable,
  filterTable = filterTable,
  reduceTable = reduceTable
}