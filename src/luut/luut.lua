local function expect(actual)
  return {
    toBe = function(expected)
      if actual ~= expected then
        error('Expected ' .. actual .. ' to be ' .. expected)
      end
    end,
    toBeTruthy = function()
      if not actual then
        error('Expected ' .. actual .. ' to be truthy')
      end
    end,
    toBeFalsy = function()
      if actual then
        error('Expected ' .. actual .. ' to be falsy')
      end
    end,
    toBeGreaterThan = function(expected)
      if actual <= expected then
        error('Expected ' .. actual .. ' to be greater than ' .. expected)
      end
    end,
    toBeLessThan = function(expected)
      if actual >= expected then
        error('Expected ' .. actual .. ' to be less than ' .. expected)
      end
    end,
    toBeCloseTo = function(expected, precision)
      if math.abs(actual - expected) > precision then
        error('Expected ' .. actual .. ' to be close to ' .. expected .. ' with precision ' .. precision)
      end
    end,
    toBeInstanceOf = function(expected)
      if not (type(actual) == 'table' and actual.__name == expected) then
        error('Expected ' .. actual .. ' to be an instance of ' .. expected)
      end
    end,
    toBeTypeOf = function(expected)
      if type(actual) ~= expected then
        error('Expected ' .. actual .. ' to be a type of ' .. expected)
      end
    end
  }
end

local function suite(name, callback)
  print(name)
  callback()
end

local function describe(name, callback)
  print('**' .. name)
  callback()
end

local function it(name, callback)
  print('  ->' .. name)
  callback()
end

local function runTests()
  local function scanDir()
    local directory = 'src/tests'
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    local amt = 1
    for filename in pfile:lines() do
      i = i + 1
      if filename ~= '.' and filename ~= '..' then
        t[amt] = filename
        amt = amt + 1
      end
    end
    pfile:close()
    print('scanned:')
    print(table.concat(t, '\n'))
    return t
  end

  local tests = scanDir()
  print('*** running tests, keep arms and legs inside the compiler at all times ***')
  for _, test in ipairs(tests) do
    local testModule = require('src/tests/' .. test:gsub('.lua', ''))
    testModule.test()
  end
end

return {
  expect = expect,
  describe = describe,
  it = it,
  runTests = runTests,
  suite = suite
}