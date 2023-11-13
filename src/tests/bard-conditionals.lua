local luut = require('src/luut/luut')
local describe = luut.describe
local it = luut.it
local expect = luut.expect
local suite = luut.suite

local function playerIsClassTest()
  local playerIsClass = require('src/bard/bard-conditionals').playerIsClass

  local mockContext = {
    gmcp = {
      Char = {
        Status = {
          class = 'Bard'
        }
      }
    }
  }

  describe('playerIsClass', function()
    it('should return true if the player is the Bard class', function()
      expect(playerIsClass('Bard')(mockContext)).toBeTruthy()
    end)

    it('should return false if the player is not the Bard class', function()
      expect(playerIsClass('Warrior')(mockContext)).toBeFalsy()
    end)

    it('should return false if passed a random value', function()
      expect(playerIsClass('not-a-class-that-exists')(mockContext)).toBeFalsy()
    end)
  end)
end

local function hasAfflictionTest()
  local hasAffliction = require('src/bard/bard-conditionals').hasAffliction

  local mockContext = {
    ak = {
      defs = {
        impatience = true
      }
    }
  }

  describe('hasAffliction', function()
    it('should return true if the player has the impatience affliction', function()
      expect(hasAffliction('impatience')(mockContext)).toBeTruthy()
    end)

    it('should return false if the player does not have the impatience affliction', function()
      expect(hasAffliction('asthma')(mockContext)).toBeFalsy()
    end)
  end)
end

local function shouldLungeTargetTest()
  local shouldLungeTarget = require('src/bard/bard-conditionals').shouldLungeTarget

  local mockContext = {
    Kai = {
      Bard = {
        autoLunge = true
      }
    },
    data = {
      tarleft = true
    }
  }

  describe('shouldLungeTarget', function()
    it('should return true if the player has autoLunge enabled and the target is left', function()
      expect(shouldLungeTarget()(mockContext)).toBeTruthy()
    end)

    it('should return false if the player does not have autoLunge enabled', function()
      mockContext.Kai.Bard.autoLunge = false
      expect(shouldLungeTarget()(mockContext)).toBeFalsy()
    end)

    it('should return false if the target has not left', function()
      mockContext.Kai.Bard.autoLunge = true
      mockContext.data.tarleft = false
      expect(shouldLungeTarget()(mockContext)).toBeFalsy()
    end)

    it('should return false if both autoLunge is disabled and the target has not left', function()
      mockContext.Kai.Bard.autoLunge = false
      mockContext.data.tarleft = false
      expect(shouldLungeTarget()(mockContext)).toBeFalsy()
    end)
  end)
end

return {
  test = function()
    suite('bard-conditionals', function()
      playerIsClassTest()
      hasAfflictionTest()
      shouldLungeTargetTest()
    end)
  end
}