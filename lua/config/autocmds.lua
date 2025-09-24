local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local general = augroup('general_settings', { clear = true })

autocmd({ 'FocusGained', 'BufEnter' }, {
  group = general,
  command = 'checktime',
})

-- TypeScript/JavaScript ファイルのimport文を自動折りたたみ
autocmd({ 'BufReadPost', 'BufNewFile' }, {
  group = general,
  pattern = { '*.ts', '*.tsx', '*.js', '*.jsx', '*.mjs', '*.cjs' },
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local import_start = nil
    local import_end = nil

    for i, line in ipairs(lines) do
      -- import文の開始を検出
      if line:match('^import ') or line:match('^const .* = require') or line:match('^import%s*{') or line:match('^import%s*type') then
        if not import_start then
          import_start = i
        end
        import_end = i
      -- 空行または非import文が来たらブロック終了
      elseif import_start and not line:match('^%s*$') and not line:match('^%s*//') then
        break
      -- 空行も範囲に含める（import文のブロック内の場合）
      elseif import_start and line:match('^%s*$') then
        import_end = i
      end
    end

    -- import文が連続して3行以上ある場合のみ折りたたむ
    if import_start and import_end and (import_end - import_start) >= 2 then
      vim.cmd(string.format('%d,%dfold', import_start, import_end))
    end
  end,
})

