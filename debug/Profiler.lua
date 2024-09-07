-- SOURCED FROM https://github.com/2dengine/profile.lua
-- MODIFIED TO WORK WITH TIC-80

profiler = {}

profiler.clock = time

-- function labels
profiler._labeled = {}
-- function definitions
profiler._defined = {}
-- time of last call
profiler._tcalled = {}
-- total execution time
profiler._telapsed = {}
-- number of calls
profiler._ncalls = {}
-- list of internal profiler functions
profiler._internal = {}

--- This is an internal function.
-- @tparam string event Event type
-- @tparam number line Line number
-- @tparam[opt] table info Debug info table
function profiler.hooker(event, line, info)
  info = info or debug.getinfo(2, 'fnS')
  local f = info.func
  -- ignore the profiler itself
  if profiler._internal[f] or info.what ~= "Lua" then
    return
  end
  -- get the function name if available
  if info.name then
    profiler._labeled[f] = info.name
  end
  -- find the line definition
  if not profiler._defined[f] then
    profiler._defined[f] = info.short_src..":"..info.linedefined
    profiler._ncalls[f] = 0
    profiler._telapsed[f] = 0
  end
  if profiler._tcalled[f] then
    local dt = profiler.clock() - profiler._tcalled[f]
    profiler._telapsed[f] = profiler._telapsed[f] + dt
    profiler._tcalled[f] = nil
  end
  if event == "tail call" then
    local prev = debug.getinfo(3, 'fnS')
    profiler.hooker("return", line, prev)
    profiler.hooker("call", line, info)
  elseif event == 'call' then
    profiler._tcalled[f] = profiler.clock()
  else
    profiler._ncalls[f] = profiler._ncalls[f] + 1
  end
end

--- Sets a clock function to be used by the profiler.
-- @tparam function func Clock function that returns a number
function profiler.setclock(f)
  assert(type(f) == "function", "clock must be a function")
  clock = f
end

--- Starts collecting data.
function profiler.start()
  if rawget(_G, 'jit') then
    jit.off()
    jit.flush()
  end
  debug.sethook(profiler.hooker, "cr")
end

--- Stops collecting data.
function profiler.stop()
  debug.sethook()
  for f in pairs(profiler._tcalled) do
    local dt = profiler.clock() - profiler._tcalled[f]
    profiler._telapsed[f] = profiler._telapsed[f] + dt
    profiler._tcalled[f] = nil
  end
  -- merge closures
  local lookup = {}
  for f, d in pairs(profiler._defined) do
    local id = (profiler._labeled[f] or '?')..d
    local f2 = lookup[id]
    if f2 then
      profiler._ncalls[f2] = profiler._ncalls[f2] + (profiler._ncalls[f] or 0)
      profiler._telapsed[f2] = profiler._telapsed[f2] + (profiler._telapsed[f] or 0)
      profiler._defined[f], profiler._labeled[f] = nil, nil
      profiler._ncalls[f], profiler._telapsed[f] = nil, nil
    else
      lookup[id] = f
    end
  end
  collectgarbage('collect')
end

--- Resets all collected data.
function profiler.reset()
  for f in pairs(profiler._ncalls) do
    profiler._ncalls[f] = 0
  end
  for f in pairs(profiler._telapsed) do
    profiler._telapsed[f] = 0
  end
  for f in pairs(profiler._tcalled) do
    profiler._tcalled[f] = nil
  end
  collectgarbage('collect')
end

--- This is an internal function.
-- @tparam function a First function
-- @tparam function b Second function
-- @treturn boolean True if "a" should rank higher than "b"
function profiler.comp(a, b)
  local dt = profiler._telapsed[b] - profiler._telapsed[a]
  if dt == 0 then
    return profiler._ncalls[b] < profiler._ncalls[a]
  end
  return dt < 0
end

--- Generates a report of functions that have been called since the profile was started.
-- Returns the report as a numeric table of rows containing the rank, function label, number of calls, total execution time and source code line number.
-- @tparam[opt] number limit Maximum number of rows
-- @treturn table Table of rows
function profiler.query(limit)
  local t = {}
  for f, n in pairs(profiler._ncalls) do
    if n > 0 then
      t[#t + 1] = f
    end
  end
  table.sort(t, profiler.comp)
  if limit then
    while #t > limit do
      table.remove(t)
    end
  end
  for i, f in ipairs(t) do
    local dt = 0
    if profiler._tcalled[f] then
      dt = profiler.clock() - profiler._tcalled[f]
    end
    t[i] = { i, profiler._labeled[f] or '?', profiler._ncalls[f], (profiler._telapsed[f] + dt).." - "..(round( (profiler._telapsed[f] + dt)/profiler._ncalls[f],3)*1000).."mcs", profiler._defined[f] }
  end
  return t
end

profiler.cols = { 3, 29, 11, 24, 32 }

--- Generates a text report of functions that have been called since the profile was started.
-- Returns the report as a string that can be printed to the console.
-- @tparam[opt] number limit Maximum number of rows
-- @treturn string Text-based profiling report
function profiler.report(n)
  local out = {}
  local report = profiler.query(n)
  for i, row in ipairs(report) do
    for j = 1, 5 do
      local s = row[j]
      local l2 = profiler.cols[j]
      s = tostring(s)
      local l1 = s:len()
      if l1 < l2 then
        s = s..(' '):rep(l2-l1)
      elseif l1 > l2 then
        s = s:sub(l1 - l2 + 1, l1)
      end
      row[j] = s
    end
    out[i] = table.concat(row, ' | ')
  end

  local row = " +-----+-------------------------------+-------------+--------------------------+----------------------------------+ \n"
  local col = " | #   | Function                      | Calls       | Time                     | Code                             | \n"
  local sz = row..col..row
  if #out > 0 then
    sz = sz..' | '..table.concat(out, ' | \n | ')..' | \n'
  end
  return '\n'..sz..row
end

-- store all internal profiler functions
for _, v in pairs(profiler) do
  if type(v) == "function" then
    profiler._internal[v] = true
  end
end

