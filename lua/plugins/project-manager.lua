return {
  {
    'bko/nvim-project-manager',
    dir = vim.fn.stdpath('config') .. '/lua/project-manager',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('project-manager').setup({
        projects_file = vim.fn.stdpath('data') .. '/projects.json',
        workspaces_file = vim.fn.stdpath('data') .. '/workspaces.json',
        max_recent_projects = 20,
      })
    end,
  },
}