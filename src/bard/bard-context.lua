--[[
  file: bard-context.lua
  desc: bard-specific context data when running the pipeline
  date: 2023-11-13
]]--

-- currently these are just placeholders to avoid referencing a null or undefined k/v pair
local _affstrack = {
  score = 'some score value?',
}
local _aff = {
  prone = 100
}
local _ak = {
  defs = {
    rebounding = true,
  },
}
local _Kai = {
  Bard = {
    song = 'some song value?',
    bardLDMG = 'some ldmg value',
    tarLimb = 'some tarlimb value',
    tunesmith = 'some tunesmith value',
    autoLunge = true,

  },
  v1 = {
    dunnowhatthisis = 'some value?',
  },
}
local _gmcp = {
  Char = {
    Status = {
      class = 'Bard'
    }
  }
}
local _locked = function() return false end
local _mentals = function() return 0 end
local _prepped = function() return false end

return {
  affstrack = _affstrack,
  aff = _aff,
  ak = _ak,
  Kai = _Kai,
  gmcp = _gmcp,
  locked = _locked,
  mentals = _mentals,
  prepped = _prepped,
  data = {
    -- some context data that seems to be local in the original script
    tarleft = true,
    leavedir = 'leave dir value, whatever that is supposed to be',
    nextSong = nil,
    nextJab = nil,

    -- both, song, jab
    getNextAction = function(nextSong, nextJab)
      if nextSong == nil or nextJab == nil then
        return 'both'
      end
      local subt = math.floor(nextSong - nextJab)
      local diff = math.abs(subt)
      if diff < 1 then return 'both' end
      if subt < 0 then return 'song' end
      return 'jab'
    end
  }
}