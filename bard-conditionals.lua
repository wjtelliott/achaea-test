--[[
  file: bard-conditionals.lua
  desc: bard-specific conditional foundation helpers
  date: 2023-11-12
]]--

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

-- init with foundation safely to avoid overwriting existing functions with the same name
local safeCompile = {
  'playerIsClass hasAffliction reqOtherIsEmpty opponentIsLocked salveLock shouldChaseTarget shouldLungeTarget',
  playerIsClass,
  hasAffliction,
  reqOtherIsEmpty,
  opponentIsLocked,
  salveLock,
  shouldChaseTarget,
  shouldLungeTarget
}
foundationAdd(safeCompile)