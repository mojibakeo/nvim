local M = {}
local uv = vim.loop
local utils = require('project-manager.utils')

M.config = {
  projects_file = vim.fn.stdpath('data') .. '/projects.json',
  workspaces_file = vim.fn.stdpath('data') .. '/workspaces.json',
  max_recent_projects = 20,
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- プロジェクト変更時の自動記録
  vim.api.nvim_create_autocmd('DirChanged', {
    callback = function()
      local cwd = vim.fn.getcwd()
      if utils.is_project_root(cwd) then
        M.add_recent_project(cwd)
      end
    end,
  })

  -- 起動時の現在ディレクトリ記録
  vim.schedule(function()
    local cwd = vim.fn.getcwd()
    if utils.is_project_root(cwd) then
      M.add_recent_project(cwd)
    end
  end)

  -- コマンドを設定
  local commands = require('project-manager.commands')
  commands.setup()
end

function M.add_recent_project(path)
  local projects = utils.read_projects_file(M.config.projects_file)

  -- 既存のエントリを削除
  for i = #projects, 1, -1 do
    if projects[i].path == path then
      table.remove(projects, i)
    end
  end

  -- 新しいエントリを先頭に追加
  table.insert(projects, 1, {
    path = path,
    name = vim.fn.fnamemodify(path, ':t'),
    last_accessed = os.time(),
  })

  -- 最大数を超えた場合は古いものを削除
  while #projects > M.config.max_recent_projects do
    table.remove(projects)
  end

  utils.write_projects_file(M.config.projects_file, projects)
end

function M.show_recent_projects()
  local ok, fzf = pcall(require, 'project-manager.fzf')
  if ok then
    fzf.recent_projects()
  else
    local telescope = require('project-manager.telescope')
    telescope.recent_projects()
  end
end

function M.open_project(path)
  -- 未保存ファイルがあるかチェック
  local modified_buffers = utils.get_modified_buffers()

  if #modified_buffers > 0 then
    local choice = vim.fn.confirm(
      '未保存のファイルがあります: ' .. table.concat(modified_buffers, ', ') .. '\n処理を選択してください:',
      '&Save All\n&Discard\n&Cancel',
      1
    )

    if choice == 1 then
      -- 全て保存
      vim.cmd('wa')
    elseif choice == 2 then
      -- 破棄して続行
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_option(buf, 'modified') then
          vim.api.nvim_buf_set_option(buf, 'modified', false)
        end
      end
    else
      -- キャンセル
      return
    end
  end

  -- プロジェクトを開く
  vim.cmd('cd ' .. vim.fn.fnameescape(path))
  M.add_recent_project(path)

  -- 現在のバッファを閉じて新しいプロジェクトの準備
  vim.cmd('bufdo bdelete')
  vim.notify('Project opened: ' .. path, vim.log.levels.INFO)
end

function M.show_workspaces()
  local ok, fzf = pcall(require, 'project-manager.fzf')
  if ok then
    fzf.workspaces()
  else
    local telescope = require('project-manager.telescope')
    telescope.workspaces()
  end
end

function M.save_workspace(name)
  local workspace = {
    name = name,
    cwd = vim.fn.getcwd(),
    buffers = {},
    created_at = os.time(),
  }

  -- 現在開いているバッファの情報を保存
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= '' then
      local bufname = vim.api.nvim_buf_get_name(buf)
      table.insert(workspace.buffers, {
        path = bufname,
        line = vim.api.nvim_win_get_cursor(0)[1],
      })
    end
  end

  local workspaces = utils.read_workspaces_file(M.config.workspaces_file)

  -- 既存のワークスペースがあれば更新
  local found = false
  for i, ws in ipairs(workspaces) do
    if ws.name == name then
      workspaces[i] = workspace
      found = true
      break
    end
  end

  if not found then
    table.insert(workspaces, workspace)
  end

  utils.write_workspaces_file(M.config.workspaces_file, workspaces)
  vim.notify('Workspace saved: ' .. name, vim.log.levels.INFO)
end

function M.load_workspace(workspace)
  -- プロジェクトディレクトリに移動
  vim.cmd('cd ' .. vim.fn.fnameescape(workspace.cwd))

  -- 現在のバッファをクリア
  vim.cmd('bufdo bdelete')

  -- ワークスペースのバッファを復元
  for _, buf_info in ipairs(workspace.buffers) do
    if vim.fn.filereadable(buf_info.path) == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(buf_info.path))
      vim.api.nvim_win_set_cursor(0, {buf_info.line, 0})
    end
  end

  vim.notify('Workspace loaded: ' .. workspace.name, vim.log.levels.INFO)
end

return M