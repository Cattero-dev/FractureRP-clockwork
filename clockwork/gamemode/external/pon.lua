--[[
RECOMMENDED VERSION

VERSION 1.2.1
Copyright thelastpenguin™

  You may use this for any purpose as long as:
  -  You don't remove this copyright notice.
  -  You don't claim this to be your own.
  -  You properly credit the author, thelastpenguin™, if you publish your work based on (and/or using) this.

  If you modify the code for any purpose, the above still applies to the modified code.

  The author is not held responsible for any damages incured from the use of pON, you use it at your own risk.

DATA TYPES SUPPORTED:
 - tables  -     k, v - pointers
 - strings -     k, v - pointers
 - numbers -    k, v
 - booleans-     k, v
 - Vectors -     k, v
 - Angles  -    k, v
 - Entities-     k, v
 - Players -     k, v

CHANGE LOG
V 1.1.0
 - Added Vehicle, NPC, NextBot, Player, Weapon
V 1.2.0
 - Added custom handling for k, v tables without any array component.
V 1.2.1
 - fixed deserialization bug.
V 1.3.0
 - added custom handling of strings without any escaped characters.
V 1.4.0
 - added detection of numbers without requiring 'n' datatype. (10 datatypes one for each num it could start with)
V 1.4.1
 - Various fixes and optimizarions, as well as merging stuff from the pON repo.

THANKS TO...
 - VERCAS for the inspiration.
]]

local pon = {}
_G.pon = pon

local type, count = type, table.Count
local tonumber = tonumber
local format = string.format

do
  local encode = {}
  local try_cache
  local cache_size = 0
  local type, count = type, table.Count
  local tonumber = tonumber
  local format = string.format

  encode['table'] = function(self, tbl, output, cache)

    if (cache[tbl]) then
      table.insert(output, '('..cache[tbl]..')')
      return
    else
      cache_size = cache_size + 1
      cache[tbl] = cache_size
    end
    -- CALCULATE COMPONENT SIZES
    local nSize = #tbl
    local kvSize = count(tbl) - nSize

    if (nSize == 0 and kvSize > 0) then
      table.insert(output, '[')
    else
      table.insert(output, '{')

      if nSize > 0 then
        for i = 1, nSize do
          local v = tbl[i]

          if v == nil then
            table.insert(output, '!')
            continue
          end

          local tv = type(v)
          -- HANDLE POINTERS
          if (tv == 'string') then
            local pid = cache[v]
            if (pid) then
              table.insert(output, '('..pid..')')
            else
              cache_size = cache_size + 1
              cache[v] = cache_size

              self.string(self, v, output, cache)
            end
          else
            self[tv](self, v, output, cache)
          end
        end
      end
    end

    if (kvSize > 0) then
      if (nSize > 0) then
        table.insert(output, '~')
      end
      for k, v in next, tbl do
        local key_type = type(k)
        if key_type != 'number' or k < 1 or k > nSize then
          local tk, tv = key_type, type(v)

          -- THE KEY
          if (tk == 'string') then
            local pid = cache[k]
            if (pid) then
              table.insert(output, '('..pid..')')
            else
              cache_size = cache_size + 1
              cache[k] = cache_size

              self.string(self, k, output, cache)
            end
          else
            self[tk](self, k, output, cache)
          end

          -- THE VALUE
          if (tv == 'string') then
            local pid = cache[v]
            if (pid) then
              table.insert(output, '('..pid..')')
            else
              cache_size = cache_size + 1
              cache[v] = cache_size

              self.string(self, v, output, cache)
            end
          else
            self[tv](self, v, output, cache)
          end

        end
      end
    end
    table.insert(output, '}')
  end

  -- ENCODE STRING
  local gsub = string.gsub
  encode['string'] = function(self, str, output)
    --if try_cache(str, output) then return end
    local estr, count = gsub(str, ";", "\\;")
    if (count == 0) then
      table.insert(output, '\''..str..';')
    else
      table.insert(output, '"'..estr..'";')
    end
  end

  -- ENCODE NUMBER
  encode['number'] = function(self, num, output)
    table.insert(output, tonumber(num)..';')
  end

  -- ENCODE BOOLEAN
  encode['boolean'] = function(self, val, output)
    table.insert(output, val and 't' or 'f')
  end

  -- ENCODE VECTOR
  encode['Vector'] = function(self, val, output)
    table.insert(output, ('v'..val.x..','..val.y)..(','..val.z..';'))
  end

  -- ENCODE ANGLE
  encode['Angle'] = function(self, val, output)
    table.insert(output, ('a'..val.p..','..val.y)..(','..val.r..';'))
  end

  encode['Entity'] = function(self, val, output)
    table.insert(output, 'E'..(IsValid(val) and val:EntIndex()..';' or '#'))
  end

  encode['Player']  = encode['Entity']
  encode['Vehicle'] = encode['Entity']
  encode['Weapon']  = encode['Entity']
  encode['NPC']     = encode['Entity']
  encode['NextBot'] = encode['Entity']
  encode['PhysObj'] = encode['Entity']

  encode['nil'] = function()
    table.insert(output, '?')
  end

  encode.__index = function(key)
    ErrorNoHalt('Cannot encode '..tostring(key)..', encoded as nil.')
    return encode['nil']
  end

  do
    local empty, concat = table.Empty, table.concat
    function pon.encode(tbl)
      local output = {}
      cache_size = 0
      encode['table'](encode, tbl, output, {})
      local res = concat(output)

      return res
    end
  end
end

do
  local tonumber = tonumber
  local find, sub, gsub, Explode = string.find, string.sub, string.gsub, string.Explode
  local Vector, Angle, Entity = Vector, Angle, Entity

  local decode = {}
  decode['{'] = function(self, index, str, cache)

    local cur = {}
    table.insert(cache, cur)

    local k, v, tk, tv = 1, nil, nil, nil
    while (true) do
      tv = sub(str, index, index)
      if (!tv or tv == '~') then
        index = index + 1
        break
      end
      if (tv == '}') then
        return index + 1, cur
      end

      -- READ THE VALUE
      index = index + 1
      index, v = self[tv](self, index, str, cache)
      cur[k] = v

      k = k + 1
    end

    while (true) do
      tk = sub(str, index, index)
      if (!tk or tk == '}') then
        index = index + 1
        break
      end

      -- READ THE KEY

      index = index + 1
      index, k = self[tk](self, index, str, cache)

      -- READ THE VALUE
      tv = sub(str, index, index)
      index = index + 1
      index, v = self[tv](self, index, str, cache)

      cur[k] = v
    end

    return index, cur
  end
  decode['['] = function(self, index, str, cache)

    local cur = {}
    table.insert(cache, cur)

    local k, v, tk, tv = 1, nil, nil, nil
    while (true) do
      tk = sub(str, index, index)
      if (!tk or tk == '}') then
        index = index + 1
        break
      end

      -- READ THE KEY

      index = index + 1
      index, k = self[tk](self, index, str, cache)
      if !k then continue end

      -- READ THE VALUE
      tv = sub(str, index, index)
      index = index + 1
      if !self[tv] then
        print('did not find type: '..tv)
      end
      index, v = self[tv](self, index, str, cache)

      cur[k] = v
    end

    return index, cur
  end

  -- STRING
  decode['"'] = function(self, index, str, cache)
    local finish = find(str, '";', index, true)
    local res = gsub(sub(str, index, finish - 1), '\\;', ';')
    index = finish + 2

    table.insert(cache, res)
    return index, res
  end
  -- STRING NO ESCAPING NEEDED
  decode['\''] = function(self, index, str, cache)
    local finish = find(str, ';', index, true)
    local res = sub(str, index, finish - 1)
    index = finish + 1

    table.insert(cache, res)
    return index, res
  end

  decode['!'] = function(self, index, str, cache)
    return index, nil
  end

  -- NUMBER
  decode['n'] = function(self, index, str, cache)
    index = index - 1
    local finish = find(str, ';', index, true)
    local num = tonumber(sub(str, index, finish - 1))
    index = finish + 1
    return index, num
  end

  decode['0'] = decode['n']
  decode['1'] = decode['n']
  decode['2'] = decode['n']
  decode['3'] = decode['n']
  decode['4'] = decode['n']
  decode['5'] = decode['n']
  decode['6'] = decode['n']
  decode['7'] = decode['n']
  decode['8'] = decode['n']
  decode['9'] = decode['n']
  decode['-'] = decode['n']

  -- POINTER
  decode['('] = function(self, index, str, cache)
    local finish = find(str, ')', index, true)
    local num = tonumber(sub(str, index, finish - 1))
    index = finish + 1
    return index, cache[num]
  end

  -- BOOLEAN. ONE DATA TYPE FOR YES, ANOTHER FOR NO.
  decode['t'] = function(self, index)
    return index, true
  end

  decode['f'] = function(self, index)
    return index, false
  end

  -- VECTOR
  decode['v'] = function(self, index, str, cache)
    local finish =  find(str, ';', index, true)
    local vecStr = sub(str, index, finish - 1)
    index = finish + 1; -- update the index.
    local segs = Explode(',', vecStr, false)
    return index, Vector(tonumber(segs[1]), tonumber(segs[2]), tonumber(segs[3]))
  end

  -- ANGLE
  decode['a'] = function(self, index, str, cache)
    local finish =  find(str, ';', index, true)
    local angStr = sub(str, index, finish - 1)
    index = finish + 1; -- update the index.
    local segs = Explode(',', angStr, false)
    return index, Angle(tonumber(segs[1]), tonumber(segs[2]), tonumber(segs[3]))
  end

  -- ENTITY
  decode['E'] = function(self, index, str, cache)
    if (str[index] == '#') then
      index = index + 1
      return index, NULL
    else
      local finish = find(str, ';', index, true)
      local num = tonumber(sub(str, index, finish - 1))
      index = finish + 1
      return index, Entity(num)
    end
  end

  -- PLAYER
  decode['P'] = function(self, index, str, cache)
    local finish = find(str, ';', index, true)
    local num = tonumber(sub(str, index, finish - 1))
    index = finish + 1
    return index, Entity(num) or NULL
  end

  decode['?'] = function(self, index, str, cache)
    return index + 1, nil
  end

  function pon.decode(data)
    local _, res = decode[sub(data, 1, 1)](decode, 2, data, {})
    return res
  end
end
