-- some unknown functions, probably from the mudlet api

local reqOther = function()
  return "" -- dunno what this is
end

local send = function(str)
  print('SENDING: ', str) -- or this
end

return {
  reqOther = reqOther,
  send = send
}