local M = {}

function M.setup()
  local project_manager = require('project-manager')

  -- Recent Projects を表示
  vim.api.nvim_create_user_command('ProjectRecent', function()
    project_manager.show_recent_projects()
  end, {
    desc = 'Show recent projects',
  })

  -- Workspace を表示
  vim.api.nvim_create_user_command('WorkspaceList', function()
    project_manager.show_workspaces()
  end, {
    desc = 'Show workspaces',
  })

  -- Workspace を保存
  vim.api.nvim_create_user_command('WorkspaceSave', function(opts)
    local name = opts.args
    if name == '' then
      name = vim.fn.input('Workspace name: ')
      if name == '' then
        vim.notify('Workspace name is required', vim.log.levels.WARN)
        return
      end
    end
    project_manager.save_workspace(name)
  end, {
    desc = 'Save current workspace',
    nargs = '?',
  })

  -- 現在のディレクトリをプロジェクトとして追加
  vim.api.nvim_create_user_command('ProjectAdd', function()
    local cwd = vim.fn.getcwd()
    project_manager.add_recent_project(cwd)
    vim.notify('Added current directory to recent projects: ' .. cwd, vim.log.levels.INFO)
  end, {
    desc = 'Add current directory to recent projects',
  })

  -- プロジェクトリストをクリア
  vim.api.nvim_create_user_command('ProjectClear', function()
    local choice = vim.fn.confirm('Clear all recent projects?', '&Yes\n&No', 2)
    if choice == 1 then
      local utils = require('project-manager.utils')
      utils.write_projects_file(project_manager.config.projects_file, {})
      vim.notify('Recent projects cleared', vim.log.levels.INFO)
    end
  end, {
    desc = 'Clear all recent projects',
  })

  -- ワークスペースリストをクリア
  vim.api.nvim_create_user_command('WorkspaceClear', function()
    local choice = vim.fn.confirm('Clear all workspaces?', '&Yes\n&No', 2)
    if choice == 1 then
      local utils = require('project-manager.utils')
      utils.write_workspaces_file(project_manager.config.workspaces_file, {})
      vim.notify('Workspaces cleared', vim.log.levels.INFO)
    end
  end, {
    desc = 'Clear all workspaces',
  })
end

return M