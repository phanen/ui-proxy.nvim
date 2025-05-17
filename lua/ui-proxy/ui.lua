local sock, width, height, pid =
  _G.arg[1], tonumber(_G.arg[2]), tonumber(_G.arg[3]), tonumber(_G.arg[4])
pid = assert(pid)
local Session = require('ui-proxy.client.session')
local uv_stream = require('ui-proxy.client.uv_stream')
local sock_sess = Session.new(uv_stream.SocketStream.open(sock))
sock_sess:request('nvim_set_client_info', 'child', vim.version(), 'remote', {}, {})
sock_sess:request('nvim_ui_attach', width, height, { ext_linegrid = true })
-- local exec_lua = function(code, ...) return session:request('nvim_exec_lua', code, { ... }) end
-- exec_lua([[vim.print(...)]], { (vim.api.nvim_list_chans()) })
-- exec_lua([[vim.print(vim.api.nvim_list_chans())]], { (vim.api.nvim_list_chans()) })
-- exec_lua([[vim.print(vim.api.nvim_list_uis())]], { (vim.api.nvim_list_chans()) })
-- io.stdout:write(vim.mpack.encode(session:next_message(100)))

local io_sess = Session.new(uv_stream.StdioStream.open())
while vim.uv.os_getpriority(pid) do
  io_sess:notify('proxy', sock_sess:next_message())
end

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
