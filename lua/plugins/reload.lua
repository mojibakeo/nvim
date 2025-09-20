return {
  'nvim-lua/plenary.nvim',
  {
    'famiu/nvim-reload',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'Reload', 'Restart' },
    keys = {
      { '<leader>rr', '<cmd>Reload<cr>', desc = 'Reload config' },
      { '<leader>rs', '<cmd>Restart<cr>', desc = 'Restart config' },
    },
    config = function()
      local reload = require('nvim-reload')
      reload.post_reload_hook = function()
        vim.notify('Config reloaded!', vim.log.levels.INFO)
      end
    end,
  }
}