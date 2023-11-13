--[[
  file: bard-actions.lua
  desc: bard-specific action foundation helpers
  date: 2023-11-12
]]--

local setReqOther = endAction(function(ctx) ctx.data.reqOther = reqOther() end)
local initBard = endAction(
  function(ctx)
    -- only do this once
    if ctx.data.initBard == true then return end
    if ctx.Kai.Bard.bardLDMG == nil or ctx.Kai.Bard.bardLDMG == "" then
      ctx.Kai.Bard.bardLDMG = 0
    end
    if ctx.Kai.Bard.tarLimb == nil then
      ctx.Kai.Bard.tarLimb = "left leg"
    end
    if ctx.data.tune == nil then
      ctx.data.tune = "tunesmith 386437 "
    end

    --append some tunesmith func/data util
    ctx.data.tunesmithUtil = {
      tune = '',
      append = function(ctx, tune)
        return function() ctx.data.tunesmithUtil.tune = ctx.data.tunesmithUtil.tune .. tune end
      end,
    }

    ctx.data.initBard = true
  end
)
local selectTunesmith = endAction(
  function(ctx)
    -- local this for shorthand
    local appendTune = ctx.data.tunesmithUtil.append

    local isLocked = ctx.locked()
    local mentalValue = ctx.mentals()
    local isProne = ctx.aff.prone == 100
    local isRebounding = ctx.ak.defs.rebounding == true
    local isPrepped = ctx.prepped()
    local hasTargetedLimb = ctx.Kai.Bard.tarLimb ~= nil and ctx.Kai.Bard.tarLimb ~= "" and ctx.Kai.Bard.tarLimb ~= "nothing"
    local isDeaf = ctx.aff.deaf == 100
    local hasAsthma = ctx.aff.asthma == 100
    local hasImpatience = ctx.aff.impatience == 100
    switchCase({
      { isLocked and mentalValue >= 3 and isProne and not isRebounding, appendTune(ctx, 'accentato') },
      { isLocked and isProne and not isRebounding, appendTune(ctx, 'martellato') },
      { isProne and isRebounding, appendTune(ctx, 'martellato') },
      { isPrepped and hasTargetedLimb, appendTune(ctx, 'todo') }, --todo nested
      { isDeaf, appendTune('pesante') },
      { mentalValue >= 3 and not isDeaf, appendTune('accentato') },
      { hasAsthma and hasImpatience and not isDeaf, appendTune(ctx, 'acciaccatura') },
      { true, appendTune(ctx, 'pesante') }
    })
    print('tune:', ctx.data.tunesmithUtil.tune)
  end
)

setupVenomJab = function()
  print('setup venom jab')
end
setupSongJab = function()
  print('setup song jab')
end
setupDefault = function()
  print('setup default')
end

local lockRoute = endAction(
  function(ctx)
    local action = ctx.data.getNextAction()
    switchCase({
      { action == 'jab', setupVenomJab },
      { action == 'song', setupSongJab },
      { action == 'both', function() setupVenomJab() setupSongJab() end },
      { true, function() print('unknown action:', action) setupDefault() end }
    })
  end
)
local lockedRoute = endAction(
  function(ctx)
    -- todo
  end
)
local queueingLogic = endAction(
  function(ctx)
    -- todo
  end
)
local chaseTarget = endAction(
  function(ctx)
    send(ctx.data.leavedir)
  end
)
local lungeTarget = endAction(function(ctx) send('queue add free lunge') end)

-- init with foundation safely to avoid overwriting existing functions with the same name
local safeCompile = {
  'setReqOther initBard selectTunesmith lockRoute lockedRoute queueingLogic chaseTarget lungeTarget',
  setReqOther,
  initBard,
  selectTunesmith,
  lockRoute,
  lockedRoute,
  queueingLogic,
  chaseTarget,
  lungeTarget
}
foundationAdd(safeCompile)