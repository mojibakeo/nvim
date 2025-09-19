local M = {}

function M.is_project_root(path)
  local indicators = {
    '.git',
    'package.json',
    'Cargo.toml',
    'pyproject.toml',
    'requirements.txt',
    'Makefile',
    '.nvmrc',
    'tsconfig.json',
    'go.mod',
    'pom.xml',
    'build.gradle',
  }

  for _, indicator in ipairs(indicators) do
    if vim.fn.isdirectory(path .. '/' .. indicator) == 1 or vim.fn.filereadable(path .. '/' .. indicator) == 1 then
      return true
    end
  end

  return false
end

function M.read_projects_file(filepath)
  if vim.fn.filereadable(filepath) == 0 then
    return {}
  end

  local ok, content = pcall(vim.fn.readfile, filepath)
  if not ok then
    return {}
  end

  local json_str = table.concat(content, '\n')
  if json_str == '' then
    return {}
  end

  local ok_decode, projects = pcall(vim.fn.json_decode, json_str)
  if not ok_decode or type(projects) ~= 'table' then
    return {}
  end

  return projects
end

function M.write_projects_file(filepath, projects)
  local dir = vim.fn.fnamemodify(filepath, ':h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end

  local json_str = vim.fn.json_encode(projects)
  vim.fn.writefile({json_str}, filepath)
end

function M.read_workspaces_file(filepath)
  if vim.fn.filereadable(filepath) == 0 then
    return {}
  end

  local ok, content = pcall(vim.fn.readfile, filepath)
  if not ok then
    return {}
  end

  local json_str = table.concat(content, '\n')
  if json_str == '' then
    return {}
  end

  local ok_decode, workspaces = pcall(vim.fn.json_decode, json_str)
  if not ok_decode or type(workspaces) ~= 'table' then
    return {}
  end

  return workspaces
end

function M.write_workspaces_file(filepath, workspaces)
  local dir = vim.fn.fnamemodify(filepath, ':h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end

  local json_str = vim.fn.json_encode(workspaces)
  vim.fn.writefile({json_str}, filepath)
end

function M.get_modified_buffers()
  local modified = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'modified') then
      local name = vim.api.nvim_buf_get_name(buf)
      if name and name ~= '' then
        table.insert(modified, vim.fn.fnamemodify(name, ':t'))
      else
        table.insert(modified, '[No Name]')
      end
    end
  end
  return modified
end

function M.format_time_ago(timestamp)
  local diff = os.time() - timestamp

  if diff < 60 then
    return diff .. '秒前'
  elseif diff < 3600 then
    return math.floor(diff / 60) .. '分前'
  elseif diff < 86400 then
    return math.floor(diff / 3600) .. '時間前'
  else
    return math.floor(diff / 86400) .. '日前'
  end
end

return M