-- this is the same pipeline file, but with very verbose note-taking

-- create a package that we will return when we import this file, so that we can use it in other files
-- if we intend to make these functions global, then we can just omit this and use the functions directly
local package = {}

-- these are just values that are used to break out of a pipe or nest. they're not special in any way just string consts
package.pipeEnd = '$PIPE_END'
package.pipeNest = '$PIPE_NEST'

--[[
  Curry function used to denote a pipeline action. Pass in a callback with the signature:
  function(ctx, ...)
  where ctx is the current context and ... are any extra arguments you want to pass in

  Use these functions to create actions that you can use in a pipeline. The callback will be called with the current context innately
  usage:
  local log = package.endAction(function(ctx, str) print(str) end)

  then in the pipe:
  pipe(
    log('hello world')
  )({}) -- pass in an empty context

  to call any pipe functions outside of a pipe, you can do this:
  log('hello world')({}) -- pass in an empty context
]]--
function package.endAction(callback)
  return function(...)
    local extraArgs = {...}
    return function(arg)
      callback(arg, table.unpack(extraArgs))
    end
  end
end

-- same as above, but returns the result of the callback to the parent function that called it
--[[
  This can be used like a conditional, but remember that the endActionResult can give back information like tables
  and etc. Use it the same way as a normal endAction, but remember that the callback will return a function if you need it to

  usage:
  local returnStringFive = package.endActionResult(function(ctx) return '5' end)

  then in the pipe:
  pipe(
    log(returnStringFive()({}))
  )({}) -- pass in an empty context

  This will print out '5' to the console

  to call any pipe functions outside of a pipe, you can do this:
  local myFiveString = returnStringFive()({}) -- pass in an empty context
]]--
function package.endActionResult(callback)
  return function(...)
    local extraArgs = {...}
    return function(arg)
      return callback(arg, table.unpack(extraArgs))
    end
  end
end

-- log function that prints to the console in a pipeline
--[[
  Keep in mind that the log function will be basically completely ignored if you have fNoLogs set to true in your context
  If that value is `nil`, then it will function as normal
]]--
package.log = package.endAction(
  function(arg, str)
    if arg.fNoLogs then return end
    print(str)
  end
)

--[[
  Uh oh here's a doozy. This is the main function that you'll be using to create pipelines.
  It takes in a list of functions and returns a function that takes in a context and then runs

  The context is a table that you can pass around to each function in the pipeline. It's a way to share state between functions.
  You can add whatever you want to it, but there are a few reserved keys that you should be aware of (if these are nil, they're ignored):
  - fVerbose: if this is set to true, then the pipeline will print out extra data if it encounters something worth noting
  - fNoLogs: if this is set to true, then the pipeline will not print out any logs, even if you call package.log

  This is a crude implementation of a pipe, but it works by passing the context to each function in the pipe and recursively
  calling new pipes if the function returns a pipe. If the function returns the special value package.pipeEnd, then the pipe
  will stop running and kill the parent pipes. If the function returns package.pipeNest, then the pipe will stop running and return,
  but the parent pipe(s) will continue running.
]]--
function package.pipe(...)
  -- this is the list of functions that we're going to run
  local actions = {...}

  -- this is the function that we're going to return and then run with the context, arg = ctx
  return function(arg)

    -- in verbose mode, we'll print out a message to the console that we're starting a new pipe
    if arg.fVerbose ~= nil then package.log('Starting new pipe...')(arg) end

    -- loop through each function in the pipe
    for _, f in pairs(actions) do

      -- call the function with the context, save the result
      local actionResult = f(arg)

      -- if the function returns the special value package.pipeEnd, then we'll return that value to the parent pipe
      if actionResult == package.pipeEnd then return actionResult end'

      -- if the function returns the special value package.pipeNest, then we'll return and let the parent pipe continue running
      if actionResult == package.pipeNest then return end

      -- if the function returns a table, then we'll assume that it's a pipe and run it recursively
      if type(actionResult) == 'table' then
        -- if the pipe returns package.pipeEnd, then we'll return that value to the parent pipe
        if package.pipe(table.unpack(actionResult))(arg) == package.pipeEnd then return package.pipeEnd end
      end
    end
  end
end

--[[
  This looks scary but really you won't ever use it. It's just a curry function for our other curry functions
  (the ones that take in a condition and then return a function that takes in a list of actions).
  God help us if there are any bugs in this
]]--
function package.checkConditional(callback)
  return function(condition)
    return function(...)
      local actions = {...}
      return function(arg)
        if type(table.unpack(actions)) == 'table' then
          -- log that we're checking a conditional that is potentially an ifTheElse, if we have verbose mode on
          if arg.fVerbose ~= nil then package.log('Checking conditional => expected array<f>, got table')(arg) end
          local unpacked = table.unpack(actions)
          local _actions = unpacked.actions
          local _elseActions = unpacked.elseActions
          -- edge case for ifTheElse
          return callback(condition, _actions, _elseActions, arg)
        end
        -- edge case for ifThe/ifNotThe
        return callback(condition, actions, arg)
      end
    end
  end
end

-- same as endAction, but returns a boolean value. if the callback returns a non-boolean value, then it will return false
function package.conditional(callback)
  return function(...)
    local extraArgs = {...}
    return function(arg)
      local condResult = callback(arg, table.unpack(extraArgs))
      if type(condResult) == 'boolean' then return condResult end
      if arg.fVerbose ~= nil then package.log('CONDITIONAL RETURNED NON-BOOL VALUE')(arg) end
      return false
    end
  end
end

--[[
  If the condition returns true, then run the actions. If the condition returns false, then do nothing.
  usage (omit context if running in a pipe):
  ifThe(condition)(actions)({context})
  __remember that the above example, pipe gives context inherintly, so you don't need to pass it in__

  calling this inside a pipe looks like:
  pipe(
    ifThe(condition)(actions)
  )({context})

  if you're a madman that wants to call this outside a pipe, go ahead with (why not just use a regular if? shorthand maybe?)
  ifThe(condition)(actions)({context})
]]--
package.ifThe = package.checkConditional(
  function(condition, actions, arg)
    if condition(arg) then return actions end
  end
)

-- same as above, but runs the actions if the condition returns false
package.ifNotThe = package.checkConditional(
  function(condition, actions, arg)
    -- the secret sauce is the 'not' here
    if not condition(arg) then return actions end
  end
)

--[[
  If the condition returns true, then run the actions. If the condition returns false, then run the elseActions.
  usage (omit context if running in a pipe):
  ifTheElse(condition)({ actions = {actions}, elseActions = {elseActions} })(context)
]]--
package.ifTheElse = package.checkConditional(
  function(condition, actions, elseActions, arg)
    -- we dont have to do an if here because we will either do the actions or the elseActions
    return condition(arg) and actions or elseActions
  end
)

--[[
  Can't remember how this is implemented currently, but off the top of my head its a lil ditty like this:
  - loop through each conditional function
  - if the conditional function returns a table, then run the actions in the table as a pipe
    - if the pipe returns package.pipeEnd, then return package.pipeEnd for consistency
    - exit the loop ( run the actions for the first true conditional and ignore the rest )
]]--
function package.some(actions)
  -- this essentially acts like the switchCase util, but in a pipe
  return function(arg)
    for _, f in pairs(actions) do
      local funcResult = f(arg)
      if type(funcResult) == 'table' then
        if package.pipe(table.unpack(funcResult))(arg) == package.pipeEnd then return package.pipeEnd end
        return
      end
    end
  end
end

-- need to test my work? use this
package.sanityFalse = package.conditional(function() return false end)
package.sanityTrue = package.conditional(function() return true end)

-- use this to break out of a pipe within a pipe as an action
function package.breakPipe()
  return function(_)
    return package.pipeEnd
  end
end

-- use this to break out of a pipe nest within a pipe as an action
function package.breakNest()
  return function(_)
    return package.pipeNest
  end
end


-- i hate this, lua just let me unpack my dict OK?
-- if you use this, you gotta make sure you're unpacking the right things in the right order >:(
-- as an alternative, you can just use the functions directly from the package table or localize the ones you need:
--[[
  this unpack:
  local pipe, log = package.unpack()

  directly:
  local pipe, log = package.pipe, package.log
]]--
function package.unpack()
  return table.unpack({
    package.pipe,
    package.log,
    package.ifThe,
    package.ifNotThe,
    package.ifTheElse,
    package.some,
    package.compose,
    package.breakPipe,
    package.breakNest,
    package.sanityFalse,
    package.sanityTrue
  })
end

--print('pipeline loaded')

return package