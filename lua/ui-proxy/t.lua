local fn, api, uv = vim.fn, vim.api, vim.uv
local uv_stream = require('ui-proxy.client.uv_stream')
local rpc_stream = require('ui-proxy.client.rpc_stream')
local proc = uv_stream.ProcStream.spawn(
  {
    vim.v.progpath,
    '-u',
    'NONE',
    '--cmd',
    'set runtimepath^=' .. uv.cwd(),
    '-l',
    debug.getinfo(2, 'S') and debug.getinfo(2, 'S').source:sub(2)
      or fs.abspath('lua/ui-proxy/ui.lua'),
    vim.v.servername,
    api.nvim_list_uis()[1].width,
    api.nvim_list_uis()[1].height,
    tostring(fn.getpid()),
  },
  (function()
    local envs = {}
    for _, k in ipairs({ 'HOME', 'PATH', 'XDG_DATA_DIRS', 'TMPDIR', 'VIMRUNTIME', 'DISPLAY' }) do
      local v = os.getenv(k)
      if v then
        envs[k] = v
        envs[#envs + 1] = k .. '=' .. v
      end
    end
    return envs
  end)()
)

local rpc = rpc_stream.new(proc)
rpc:read_start(function(...)
  assert(false, 'unreachable: ' .. vim.inspect(...))
end, function(method_or_error, args_or_result)
  assert(method_or_error == 'proxy')
  local r = args_or_result[1]
  assert(r[1] == 'notification')
  assert(r[2] == 'redraw')
  r = r[3][1]
  -- local grid_line, hl, flush = unpack(r)
  -- assert(r[1] == 'grid_line')
  i = (i or 0) + 1
  vim.print(r)
  if i == 10 then
    rpc:read_stop()
  end
end, function()
  rpc:read_stop()
end)
