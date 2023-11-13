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

return {
  switchCase = switchCase
}