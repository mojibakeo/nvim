vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('config.options')
require('config.autocmds')
require('config.keymaps')
require('config.highlights').setup()

require('lazy').setup('plugins', {
  defaults = { lazy = false },
  install = { colorscheme = { 'github_dark' } },
  checker = { enabled = true, notify = false },
  ui = { border = 'rounded' },
})
