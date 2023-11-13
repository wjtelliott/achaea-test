local endAction = function(callback)
  return function(...)
    local extraArgs = {...}
    return function(arg)
      callback(arg, table.unpack(extraArgs))
    end
  end
end

local endActionResult = function(callback)
  return function(...)
    local extraArgs = {...}
    return function(arg)
      return callback(arg, table.unpack(extraArgs))
    end
  end
end

local log = endAction(
  function(arg, str)
    if arg.fNoLogs then return end
    print(str)
  end
)

local pipe = function(...)
  local actions = {...}
  return function(arg)
    if arg.fVerbose ~= nil then log('Starting new pipe...')(arg) end
    for _, f in pairs(actions) do
      local actionResult = f(arg)
      if actionResult == pipeEnd then return actionResult end
      if actionResult == pipeNest then return end
      if type(actionResult) == 'table' then
        if pipe(table.unpack(actionResult))(arg) == pipeEnd then return pipeEnd end
      end
    end
  end
end

local compose = function(...)
  local actions = {...}
  return function(arg)
    if arg.fVerbose ~= nil then log('Starting new compose...')(arg) end
    -- loop reverse
    for i=#actions, 1, -1 do
      local actionResult = actions[i](arg)
      if type(actionResult) == 'table' then
        compose(table.unpack(actionResult))(arg)
      end
    end
  end
end

function checkConditional(callback)
  return function(condition)
    return function(...)
      local actions = {...}
      return function(arg)
        if type(table.unpack(actions)) == 'table' then
          if arg.fVerbose ~= nil then log('Checking conditional => expected array<f>, got table')(arg) end
          local unpacked = table.unpack(actions)
          local _actions = unpacked.actions
          local _elseActions = unpacked.elseActions
          return callback(condition, _actions, _elseActions, arg)
        end
        return callback(condition, actions, arg)
      end
    end
  end
end

local conditional = function(callback)
  return function(...)
    local extraArgs = {...}
    return function(arg)
      local condResult = callback(arg, table.unpack(extraArgs))
      if type(condResult) == 'boolean' then return condResult end
      if arg.fVerbose ~= nil then log('CONDITIONAL RETURNED NON-BOOL VALUE')(arg) end
      return false
    end
  end
end

local ifThe = checkConditional(
  function(condition, actions, arg)
    if condition(arg) then return actions end
  end
)

local ifNotThe = checkConditional(
  function(condition, actions, arg)
    if not condition(arg) then return actions end
  end
)

local ifTheElse = checkConditional(
  function(condition, actions, elseActions, arg)
    return condition(arg) and actions or elseActions
  end
)

local some = function(actions)
  return function(arg)
    for _, f in pairs(actions) do
      local funcResult = f(arg)
      if type(funcResult) == 'table' then
        if pipe(table.unpack(funcResult))(arg) == pipeEnd then return pipeEnd end
        return
      end
    end
  end
end

local loopWhile = function(condition)
  return function (...)
    local actions = {...}
    return function(arg)
      while condition(arg) do
        if pipe(table.unpack(actions))(arg) == pipeEnd then return pipeEnd end
      end
    end
  end
end

local switch = function(case)
  return function(caseTable)
    return function(arg)
      local caseResult = caseTable[case(arg)]
      if caseResult == nil then caseResult = caseTable.default(arg) end
      if type(caseResult) == 'table' then
        if pipe(table.unpack(caseResult))(arg) == pipeEnd then return pipeEnd end
      else
        if arg.fVerbose ~= nil then print('Switch case expected array<f>') end
      end
    end
  end
end

local sanityFalse = conditional(function() return false end)
local sanityTrue = conditional(function() return true end)
local sanity = conditional(function(_, b) return b end)

local randomConditional = conditional(
  function(arg)
    math.randomseed(os.time())
    local conditions = { true, false }
    local result = conditions[math.random(0, 2)]
    return result
  end
)

local wait = endAction(
  function(arg, time)
    if time == nil then time = 0.5 end
    local clock = os.clock
    local delta = clock()
    while clock() - delta <= time do end
  end
)

local forLoop = function(initial, safelyEndAt)
  return function (condition)
    return function (iteration)
      return function (...)
        local actions = {...}
        return function(arg)
          local failsafe = 0
          if safelyEndAt == nil then safelyEndAt = 200 end
          initial(arg)
          while condition(arg) do
            local actionCounter = 1
            while actionCounter <= #actions do
              local f_result = actions[actionCounter](arg)
              if type(f_result) == 'table' then
                -- if we return a table, lets not worry about breaking until the table ends
                if pipe(table.unpack(f_result))(arg) == pipeEnd then return pipeEnd end
              end
              actionCounter = actionCounter + 1
              if arg.loopData.finished then break end
            end
            failsafe = failsafe + 1
            if failsafe > safelyEndAt then
              print('loop iterated too many times, failsafe break')
              break
            end
            iteration(arg)
          end
          arg.loopData = nil
        end
      end
    end
  end
end

local startLoopAt = endAction(
  function(arg, index)
    arg.loopData = {
      finished = false,
      counter = 0
    }

    if type(index) ~= 'function' then
      arg.loopData.counter = index
      return
    end

    index(arg)
  end
)

local stopLoopAt = conditional(
  function(arg, callback)
    if arg.loopData == nil then return false end
    if arg.loopData.finished == true then return false end
    if callback == nil then return arg.loopData.finished end
    if type(callback) == 'function' then
      return callback(arg)
    end
    return arg.loopData.counter < callback
  end
)

local iterateCounter = endAction(
  function(arg, cOrIndex)
    if arg.loopData == nil then
      arg.loopData = { finished = true }
      return
    end
    -- callback endAction method
    if type(cOrIndex) == 'function' then
      cOrIndex(arg)
      return
    end
    -- index method
    arg.loopData.counter = arg.loopData.counter + cOrIndex
  end
)

local breakLoop = endAction(
  function(arg)
    if arg.loopData == nil then
      arg.loopData = { finished = true }
      return
    end
    arg.loopData.finished = true
  end
)

local breakPipe = function()
  return function(arg)
    return pipeEnd
  end
end

local breakNest = function()
  return function(arg)
    return pipeNest
  end
end

-- i hate the way this looks but it works
local compiled = {
  -- index
  'pipe conditional endAction ifThe ifNotThe ifTheElse some switch loopWhile compose log sanity randomConditional sanityTrue sanityFalse wait forLoop stopLoopAt startLoopAt iterateCounter breakLoop breakPipe breakNest endActionResult',
  -- core
  pipe,
  conditional,
  endAction,
  ifThe,
  ifNotThe,
  ifTheElse,
  some,
  switch,
  loopWhile,
  compose,
  -- debug stuff
  log,
  sanity,
  randomConditional,
  sanityTrue,
  sanityFalse,
  wait,
  -- loop stuff
  forLoop,
  stopLoopAt,
  startLoopAt,
  iterateCounter,
  -- breaks
  breakLoop,
  breakPipe,
  breakNest,
  -- misc
  endActionResult
}

-- set up const protection
_consts = {}
function const(key, value)
  if _G[key] then
    _consts[key] = _G[key]
    _G[key] = nil
  else
    _consts[key] = value
  end
end

meta = {
  __index = _consts,
  __newindex = function(tbl, key, value)
    if _consts[key] then
      error('error: attempted to overwrite foundation function: ' .. tostring(key) .. ' to new value: ' .. tostring(value))
    end
    rawset(tbl, key, value)
  end
}
setmetatable(_G, meta)

-- create vars
_G['foundationAdd'] = function(newFunctionsTable)
  if fLogNewFoundation == true then
    log('Creating new foundation functions: ' .. newFunctionsTable[1])({})
  end
  local fNames = newFunctionsTable[1]
  local counter = 2
  for func in fNames:gmatch('%w+') do
    if _G[func] ~= nil then error('error: attempted to overwrite pre-existing global as foundation func: ' .. tostring(func)) end
    _G[func] = newFunctionsTable[counter]
    const(func)
    counter = counter + 1
  end
end
foundationAdd(compiled)
const('foundationAdd')
const('pipeEnd', '$PIPE_END')
const('pipeNest', '$PIPE_NEST')

-- test message and display version
local displayVersion = endAction(
  function(arg)
    print('=========================')
    print('=== Foundation Loaded ===')
    print('Running version: ' .. tostring(arg.version))
  end
)
local displayDebugModes = endAction(
  function(arg)
    print(' => Create global variable fLogNewFoundation for new function logging')
    print(' => Add fVerbose to args for verbose logging')
    print(' => Add fNoLogs to args to disable logging')
    print('=========================\n\n')
  end
)

pipe(
  displayVersion(),
  displayDebugModes()
)({ version = 'v1.0' })