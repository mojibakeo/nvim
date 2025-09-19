local M = {}
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local utils = require('project-manager.utils')

function M.recent_projects()
  local project_manager = require('project-manager')
  local projects = utils.read_projects_file(project_manager.config.projects_file)

  if #projects == 0 then
    vim.notify('Recent projects not found', vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = 'Recent Projects',
    finder = finders.new_table({
      results = projects,
      entry_maker = function(entry)
        local display = string.format(
          '%s (%s) - %s',
          entry.name,
          entry.path,
          utils.format_time_ago(entry.last_accessed)
        )
        return {
          value = entry,
          display = display,
          ordinal = entry.name .. ' ' .. entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          project_manager.open_project(selection.value.path)
        end
      end)

      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          local projects_updated = {}
          for _, project in ipairs(projects) do
            if project.path ~= selection.value.path then
              table.insert(projects_updated, project)
            end
          end
          utils.write_projects_file(project_manager.config.projects_file, projects_updated)
          actions.close(prompt_bufnr)
          vim.notify('Project removed from recent list: ' .. selection.value.name, vim.log.levels.INFO)
          -- リストを再表示
          M.recent_projects()
        end
      end)

      return true
    end,
  }):find()
end

function M.workspaces()
  local project_manager = require('project-manager')
  local workspaces = utils.read_workspaces_file(project_manager.config.workspaces_file)

  pickers.new({}, {
    prompt_title = 'Workspaces',
    finder = finders.new_table({
      results = workspaces,
      entry_maker = function(entry)
        local display = string.format(
          '%s (%s) - %d buffers',
          entry.name,
          entry.cwd,
          #entry.buffers
        )
        return {
          value = entry,
          display = display,
          ordinal = entry.name .. ' ' .. entry.cwd,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          project_manager.load_workspace(selection.value)
        end
      end)

      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          local workspaces_updated = {}
          for _, workspace in ipairs(workspaces) do
            if workspace.name ~= selection.value.name then
              table.insert(workspaces_updated, workspace)
            end
          end
          utils.write_workspaces_file(project_manager.config.workspaces_file, workspaces_updated)
          actions.close(prompt_bufnr)
          vim.notify('Workspace deleted: ' .. selection.value.name, vim.log.levels.INFO)
          -- リストを再表示
          M.workspaces()
        end
      end)

      return true
    end,
  }):find()
end

return M