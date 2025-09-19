local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local general = augroup('general_settings', { clear = true })

autocmd({ 'FocusGained', 'BufEnter' }, {
  group = general,
  command = 'checktime',
})

