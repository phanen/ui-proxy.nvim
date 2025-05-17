## ui-proxy.nvim

Make nvim server also a ui client for itself.
* `vim.ui_attach` has very limited support (e.g. no `ext_linegrid` ...).
* We have to spawn a new process to achieve this (or use ffi).
