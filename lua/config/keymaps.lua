local map = vim.keymap.set

local silent = { silent = true }

local function telescope(builtin, opts)
  return function()
    local ok, builtin_module = pcall(require, 'telescope.builtin')
    if not ok then
      vim.notify('Telescope is unavailable', vim.log.levels.WARN)
      return
    end
    builtin_module[builtin](opts or {})
  end
end

local function toggle_neotree()
  local ok, command = pcall(require, 'neo-tree.command')
  if not ok then
    vim.notify('neo-tree is unavailable', vim.log.levels.WARN)
    return
  end
  command.execute({ toggle = true, position = 'float' })
end

map('n', '<Space>c', function()
  vim.wo.cursorline = not vim.wo.cursorline
end, { desc = 'カーソルラインの切り替え', silent = true })

map('n', '<Space><Space>', telescope('buffers', { sort_mru = true, ignore_current_buffer = true }), { desc = 'バッファ一覧', silent = true })
map('n', '<Space>a', telescope('live_grep'), { desc = 'ripgrep 検索', silent = true })
map('n', '<Space>o', telescope('find_files'), { desc = 'ファイル検索', silent = true })

map('i', '<C-h>', '<BS>', silent)
map('i', '<C-d>', '<Del>', silent)
map('i', 'jj', '<Esc>', silent)

map('n', 'j', 'gj', silent)
map('n', 'k', 'gk', silent)
map('o', 'j', 'gj', silent)
map('o', 'k', 'gk', silent)
map('x', 'j', 'gj', silent)
map('x', 'k', 'gk', silent)

map('t', '<Esc>', [[<C-\><C-n>]], silent)

map({ 'n', 'v' }, '<Space>n', '<cmd>nohlsearch<CR>', { desc = 'ハイライト解除', silent = true })
map('n', '<Space>h', '<C-w>h', silent)
map('n', '<Space>j', '<C-w>j', silent)
map('n', '<Space>k', '<C-w>k', silent)
map('n', '<Space>l', '<C-w>l', silent)

map('n', 'vs', '<cmd>vsplit<CR>', silent)
map('n', 'sp', '<cmd>split<CR>', silent)
map('n', '<C-j>', '<cmd>bnext<CR>', silent)
map('n', '<C-k>', '<cmd>bprevious<CR>', silent)

map('n', 'gs', '<cmd>Git<CR>', { desc = 'Git ステータス', silent = true })
map('n', 'gb', '<cmd>Git blame<CR>', { desc = 'Git blame', silent = true })
map('n', 'gm', '<cmd>GitMessenger<CR>', { desc = 'Git メッセンジャー', silent = true })

map('n', '<Space>/', function()
  local ok, comment = pcall(require, 'Comment.api')
  if not ok then
    vim.notify('Comment.nvim が見つからない', vim.log.levels.WARN)
    return
  end
  comment.toggle.linewise.current()
end, { desc = 'コメントトグル', silent = true })

map('v', '<Space>/', function()
  local ok, comment = pcall(require, 'Comment.api')
  if not ok then
    vim.notify('Comment.nvim が見つからない', vim.log.levels.WARN)
    return
  end
  comment.toggle.linewise(vim.fn.visualmode())
end, { desc = 'コメントトグル', silent = true })

map('n', '<Space>e', toggle_neotree, { desc = 'ファイルツリー切り替え', silent = true })

-- Project Manager キーマップ
map('n', '<Space>r', function()
  local ok, project_manager = pcall(require, 'project-manager')
  if not ok then
    vim.notify('Project Manager is unavailable', vim.log.levels.WARN)
    return
  end
  project_manager.show_recent_projects()
end, { desc = 'Recent Projects', silent = true })

map('n', '<Space>pw', function()
  local ok, project_manager = pcall(require, 'project-manager')
  if not ok then
    vim.notify('Project Manager is unavailable', vim.log.levels.WARN)
    return
  end
  project_manager.show_workspaces()
end, { desc = 'Show Workspaces', silent = true })

