--[[
  file: bard-context.lua
  desc: bard-specific context data when running the pipeline
  date: 2023-11-12
]]--

-- currently these are just placeholders to avoid referencing a null or undefined k/v pair

-- we can't local these, the GC will collect them if we do
-- (i dunno how this will play out in the long haul, but it works in testing for now)
_affstrack = {
  score = 'some score value?',
}
_aff = {
  prone = 100
}
_ak = {
  defs = {
    rebounding = true,
  },
}
_Kai = {
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
_gmcp = {
  Char = {
    Status = {
      class = 'Bard'
    }
  }
}
_locked = function() return false end
_mentals = function() return 0 end
_prepped = function() return false end

bardContext = {
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
    getNextAction = function()
      local nextSong = bardContext.data.nextSong
      local nextJab = bardContext.data.nextJab
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