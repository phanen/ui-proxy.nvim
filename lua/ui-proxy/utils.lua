local M = {}

local Session = require('ui-proxy.client.session')
local loop_running --- @type boolean?
local last_error --- @type string?
local method_error --- @type string?

local function call_and_stop_on_error(lsession, ...)
  local status, result = Session.safe_pcall(...) -- luacheck: ignore
  if not status then
    lsession:stop()
    last_error = result
    return ''
  end
  return result
end

--- Runs the event loop of the given session.
---
--- @param lsession test.Session
--- @param request_cb function?
--- @param notification_cb function?
--- @param setup_cb function?
--- @param timeout integer
--- @return [integer, string]
function M.run_session(lsession, request_cb, notification_cb, setup_cb, timeout)
  local on_request --- @type function?
  local on_notification --- @type function?
  local on_setup --- @type function?

  if request_cb then
    function on_request(method, args)
      method_error = nil
      local result = call_and_stop_on_error(lsession, request_cb, method, args)
      if method_error ~= nil then
        return method_error, true
      end
      return result
    end
  end

  if notification_cb then
    function on_notification(method, args)
      call_and_stop_on_error(lsession, notification_cb, method, args)
    end
  end

  if setup_cb then
    function on_setup()
      call_and_stop_on_error(lsession, setup_cb)
    end
  end

  loop_running = true
  ---@diagnostic disable-next-line: param-type-mismatch
  lsession:run(on_request, on_notification, on_setup, timeout)
  loop_running = false
  if last_error then
    local err = last_error
    last_error = nil
    error(err)
  end

  return lsession.eof_err
end

---@param func function
---@return table<string,function>
function M.create_callindex(func)
  return setmetatable({}, {
    --- @param tbl table<any,function>
    --- @param arg1 string
    --- @return function
    __index = function(tbl, arg1)
      local ret = function(...)
        return func(arg1, ...)
      end
      tbl[arg1] = ret
      return ret
    end,
  })
end

--- @param str string
--- @param leave_indent? integer
--- @return string
function M.dedent(str, leave_indent)
  -- Last blank line often has non-matching indent, so remove it.
  str = str:gsub('\n[ ]+$', '\n')
  return (vim.text.indent(leave_indent or 0, str))
end

-- Concat list-like tables.
function M.concat_tables(...)
  local ret = {} --- @type table<any,any>
  for i = 1, select('#', ...) do
    --- @type table<any,any>
    local tbl = select(i, ...)
    if tbl then
      for _, v in ipairs(tbl) do
        ret[#ret + 1] = v
      end
    end
  end
  return ret
end

--- @generic T
--- @param orig T
--- @return T
function M.shallowcopy(orig)
  if type(orig) ~= 'table' then
    return orig
  end
  --- @cast orig table<any,any>
  local copy = {} --- @type table<any,any>
  for orig_key, orig_value in pairs(orig) do
    copy[orig_key] = orig_value
  end
  return copy
end

function M.eq(expected, actual, context)
  return require('luaassert').are.same(expected, actual, context)
end

return M
