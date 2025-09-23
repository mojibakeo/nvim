local M = {}
local utils = require('project-manager.utils')

function M.recent_projects()
  local ok, fzf_lua = pcall(require, 'fzf-lua')
  if not ok then
    vim.notify('fzf-lua is unavailable', vim.log.levels.WARN)
    return
  end

  local project_manager = require('project-manager')
  local projects = utils.read_projects_file(project_manager.config.projects_file)

  if #projects == 0 then
    vim.notify('Recent projects not found', vim.log.levels.WARN)
    return
  end

  local items = {}
  for _, entry in ipairs(projects) do
    local display = string.format(
      '%s (%s) - %s',
      entry.name,
      entry.path,
      utils.format_time_ago(entry.last_accessed)
    )
    table.insert(items, {
      display = display,
      path = entry.path,
      name = entry.name
    })
  end

  fzf_lua.fzf_exec(
    function(cb)
      for _, item in ipairs(items) do
        cb(item.display)
      end
      cb(nil)
    end,
    {
      prompt = 'Recent Projects❯ ',
      actions = {
        ['default'] = function(selected)
          if selected and #selected > 0 then
            local selection = selected[1]
            for _, item in ipairs(items) do
              if item.display == selection then
                project_manager.open_project(item.path)
                break
              end
            end
          end
        end,
        ['ctrl-d'] = function(selected)
          if selected and #selected > 0 then
            local selection = selected[1]
            for _, item in ipairs(items) do
              if item.display == selection then
                local projects_updated = {}
                for _, project in ipairs(projects) do
                  if project.path ~= item.path then
                    table.insert(projects_updated, project)
                  end
                end
                utils.write_projects_file(project_manager.config.projects_file, projects_updated)
                vim.notify('Project removed from recent list: ' .. item.name, vim.log.levels.INFO)
                M.recent_projects()
                break
              end
            end
          end
        end,
      },
    }
  )
end

function M.workspaces()
  local ok, fzf_lua = pcall(require, 'fzf-lua')
  if not ok then
    vim.notify('fzf-lua is unavailable', vim.log.levels.WARN)
    return
  end

  local project_manager = require('project-manager')
  local workspaces = utils.read_workspaces_file(project_manager.config.workspaces_file)

  local items = {}
  for _, entry in ipairs(workspaces) do
    local display = string.format(
      '%s (%s) - %d buffers',
      entry.name,
      entry.cwd,
      #entry.buffers
    )
    table.insert(items, {
      display = display,
      workspace = entry
    })
  end

  fzf_lua.fzf_exec(
    function(cb)
      for _, item in ipairs(items) do
        cb(item.display)
      end
      cb(nil)
    end,
    {
      prompt = 'Workspaces❯ ',
      actions = {
        ['default'] = function(selected)
          if selected and #selected > 0 then
            local selection = selected[1]
            for _, item in ipairs(items) do
              if item.display == selection then
                project_manager.load_workspace(item.workspace)
                break
              end
            end
          end
        end,
        ['ctrl-d'] = function(selected)
          if selected and #selected > 0 then
            local selection = selected[1]
            for _, item in ipairs(items) do
              if item.display == selection then
                local workspaces_updated = {}
                for _, workspace in ipairs(workspaces) do
                  if workspace.name ~= item.workspace.name then
                    table.insert(workspaces_updated, workspace)
                  end
                end
                utils.write_workspaces_file(project_manager.config.workspaces_file, workspaces_updated)
                vim.notify('Workspace deleted: ' .. item.workspace.name, vim.log.levels.INFO)
                M.workspaces()
                break
              end
            end
          end
        end,
      },
    }
  )
end

return M