local opt = vim.opt

opt.autoread = true
opt.completeopt = { 'menuone', 'noselect' }
opt.signcolumn = 'yes'
opt.updatetime = 200
opt.scrolloff = 5
opt.cursorline = false
opt.termguicolors = true
opt.clipboard = 'unnamedplus'

-- インデント設定
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

