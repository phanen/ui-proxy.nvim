local sock, width, height, pid =
  _G.arg[1], tonumber(_G.arg[2]), tonumber(_G.arg[3]), tonumber(_G.arg[4])
width = width or 80
height = height or 24
local Session = require('ui-proxy.client.session')
local uv_stream = require('ui-proxy.client.uv_stream')
local sock_sess = Session.new(uv_stream.SocketStream.open(sock))
local options = { ext_linegrid = true, ext_termcolors = true }
if pid then
  sock_sess:request('nvim_set_client_info', 'child', vim.version(), 'remote', {}, {})
  sock_sess:request('nvim_ui_attach', width, height, options)
  local io_sess = Session.new(uv_stream.StdioStream.open())
  while vim.uv.os_getpriority(pid) do
    io_sess:notify('proxy', sock_sess:next_message())
  end
  return
end

local Screen = require('ui-proxy.screen')
local screen = Screen.new(width, height, options, sock_sess)
screen:expect({
  grid = [[ ]],
  attr_ids = {
    [123] = { background = tonumber('0x1f2335'), foreground = tonumber('0x3b4261') },
  },
})

-- print('stdin', data)
-- io.stdout:write(vim.mpack.encode(session:next_message(100)))
-- io.stdout:write(vim.mpack.encode(session:next_message(100)))
-- io.stdout:write(vim.mpack.encode(session:next_message(100)))
-- io.stdout:write(vim.mpack.encode(session:next_message(100)))
-- io.stdout:write(vim.mpack.encode({ session:next_message(100) }))
-- io.stdout:write(vim.mpack.encode({ session:next_message(100) }))
-- io.stdout:write(vim.mpack.encode({ session:next_message(100) }))
-- TODO: avoid twice encode...
-- while true do
--   -- io.stdout:write(vim.mpack.encode(session:next_message(100)))
--   io.stdout:write(vim.mpack.encode(session:next_message(100)))
--   -- io.stdout:write('aa')
--   -- vim.uv.sleep(1000)
-- end
