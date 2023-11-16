--[[
  file: bard-actions.lua
  desc: bard-specific action foundation helpers
  date: 2023-11-13
]]--

local pipeline = require('src/pipeline')
local api = require('src/unknown')
local util = require('src/util')

local endAction = pipeline.endAction
local reqOther, send = api.reqOther, api.send
local switchCase = util.switchCase

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



local setupVenomJab = endAction(function(ctx)
  local function applyVenom(venom)
    return function() ctx.data.v1 = ctx.Kai.venom[venom] end
  end
  local reqO = ctx.data.reqOther -- ? who knows what this is
  local function reqClumsiness()
    return reqO == "clumsiness" or reqO == "clumsy"
  end -- ? who knows what this is
  local function reqWeariness()
    return reqO == "weariness" or reqO == "weary"
  end -- ? who knows what this is
  local function shouldApplyDisloyaltyToClass()
    return ctx.data.enClass == "Occultist" or ctx.data.enClass == "Druid" or ctx.data.enClass == "Unnamable" or ctx.data.enClass == "Sentinal"
  end
  local hasHighAsthma = ctx.aff.asthma >= 66
  local hasAsthma = ctx.aff.asthma >= 60
  local notHasAsthma = ctx.aff.asthma < 100
  local impatienceValue = ctx.aff.impatience
  local slicknessValue = ctx.aff.slickness
  local anorexiaValue = ctx.aff.anorexia
  local hasStupidity = ctx.aff.stupidity >= 50
  local enprio = ctx.data.enprio -- ? who knows what this is
  local impatienceBeforeAsthma = table.index_of(enprio, "impatience") < table.index_of(enprio, "asthma")
  local asthmaBeforeImpatience = table.index_of(enprio, "asthma") < table.index_of(enprio, "impatience")
  local clumsyOrWeary = ctx.aff.clumsiness >= 33 or ctx.aff.weariness >= 50
  local hasTarget = ctx.data.reqOther ~= ""
  local targetAfflictionValue = ctx.aff[reqO]
  local hasTargetVenom = table.contains(ctx.Kai.venom, reqO)
  local clumsinessValue = ctx.aff.clumsiness
  local paralysisValue = ctx.aff.paralysis
  local disloyaltyValue = ctx.aff.disloyalty
  local wearinessValue = ctx.aff.weariness

  switchCase({
    { hasAsthma and impatienceValue > 60 and slicknessValue >= 50 and anorexiaValue < 50, applyVenom("anorexia") },
    { hasHighAsthma and slicknessValue < 50 and impatienceValue >= 66, applyVenom("slickness") },
    { anorexiaValue >= 60 and slicknessValue < 100 and slicknessValue ~= 50 and hasAsthma, applyVenom("slickness") },
    { slicknessValue >= 50 and anorexiaValue < 100 and hasAsthma and impatienceValue > 66, applyVenom("anorexia") },
    { impatienceValue >= 60 and not hasStupidity and impatienceBeforeAsthma, applyVenom("stupidity") },
    { clumsyOrWeary and notHasAsthma, applyVenom("asthma") },
    { asthmaBeforeImpatience and wearinessValue < 100, applyVenom("weariness") },
    { hasTarget and targetAfflictionValue < 50 and hasTargetVenom, applyVenom(reqO) },
    { reqClumsiness() and clumsinessValue < 66, applyVenom("clumsiness") },
    { paralysisValue <= 50 and impatienceValue < 100, applyVenom("paralysis") },
    { disloyaltyValue < 33 and shouldApplyDisloyaltyToClass(), applyVenom("disloyalty") },
    { reqWeariness() and wearinessValue < 66, applyVenom("weariness") },
    { notHasAsthma and (not reqWeariness() or wearinessValue >= 66), applyVenom("asthma") },
    { paralysisValue < 50, applyVenom("paralysis") }
  })
end)
local setupSongJab = function()
  print('setup song jab')
end

local lockRoute = endAction(
  function(ctx)
    local action = ctx.data.getNextAction(ctx.data.nextSong, ctx.data.nextJab)
    local function runVenomJab()
      setupVenomJab()(ctx)
    end
    local function runSongJob()
      setupSongJab()(ctx)
    end
    local function runBoth()
      runVenomJab()
      runSongJob()
    end
    switchCase({
      { action == 'jab', runVenomJab },
      { action == 'song', runSongJob },
      { action == 'both', runBoth },
      -- we don't need this below, but just in case
      { true, function() print('unknown action:', action) print('not implemented -> default') end }
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

return {
  setReqOther = setReqOther,
  initBard = initBard,
  selectTunesmith = selectTunesmith,
  lockRoute = lockRoute,
  lockedRoute = lockedRoute,
  queueingLogic = queueingLogic,
  chaseTarget = chaseTarget,
  lungeTarget = lungeTarget,
}