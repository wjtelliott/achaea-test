--[[
  file: bard-conditionals.lua
  desc: bard-specific conditional foundation helpers
  date: 2023-11-13
]]--

local pipeline = require('src/pipeline')
local api = require('src/unknown')
local conditional = pipeline.conditional
local reqOther = api.reqOther

local playerIsClass = conditional(function(ctx, class) return ctx.gmcp.Char.Status.class == class end)
local hasAffliction = conditional(
  function (ctx, afflictionName)
    local afflicationExists = ctx.ak.defs[afflictionName]
    return afflicationExists ~= nil and afflicationExists == true
  end
)
local reqOtherIsEmpty = conditional(function() return reqOther() == '' end)
local opponentIsLocked = conditional(function(ctx) return ctx.locked() end)
local salveLock = conditional(function(ctx) return false end)
local shouldChaseTarget = conditional(function(ctx) return false end)
local shouldLungeTarget = conditional(
  function(ctx)
     return ctx.Kai.Bard.autoLunge == true and ctx.data.tarleft == true
  end
)

return {
  playerIsClass = playerIsClass,
  hasAffliction = hasAffliction,
  reqOtherIsEmpty = reqOtherIsEmpty,
  opponentIsLocked = opponentIsLocked,
  salveLock = salveLock,
  shouldChaseTarget = shouldChaseTarget,
  shouldLungeTarget = shouldLungeTarget
}