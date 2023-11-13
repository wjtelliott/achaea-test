function switchCase(cases)
  for i,case in ipairs(cases) do
    local condition = case[1]
    local actions = case[2]
    if condition then return actions() end
  end
end
