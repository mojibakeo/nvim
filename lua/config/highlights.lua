local M = {}

function M.setup()
  local colors = {
    red = '#ff7b72',         -- タグ名、import/export
    coral = '#ffa198',       -- React コンポーネント
    orange = '#ffa657',      -- 属性名、数値
    yellow = '#f0e68c',      -- 変数、識別子
    green = '#7ee787',       -- 文字列
    blue = '#79c0ff',        -- キーワード、型
    purple = '#d2a8ff',      -- プロパティ、メソッド
    cyan = '#56d4dd',        -- 演算子、区切り文字
    gray = '#8b949e',        -- コメント、区切り
    white = '#f0f6fc',       -- 通常テキスト
    light_blue = '#a5d6ff',  -- HTMLタグ
  }

  -- import/export キーワード
  vim.api.nvim_set_hl(0, '@keyword.import.tsx', { fg = colors.red })
  vim.api.nvim_set_hl(0, '@keyword.export.tsx', { fg = colors.red })
  vim.api.nvim_set_hl(0, '@keyword.import.typescriptreact', { fg = colors.red })
  vim.api.nvim_set_hl(0, '@keyword.export.typescriptreact', { fg = colors.red })

  -- 型注釈
  vim.api.nvim_set_hl(0, '@type.tsx', { fg = colors.blue })
  vim.api.nvim_set_hl(0, '@type.typescriptreact', { fg = colors.blue })
  vim.api.nvim_set_hl(0, '@type.builtin.tsx', { fg = colors.blue })
  vim.api.nvim_set_hl(0, '@type.builtin.typescriptreact', { fg = colors.blue })

  -- JSXタグ名（HTMLタグとReactコンポーネントを区別）
  vim.api.nvim_set_hl(0, '@tag.tsx', { fg = colors.light_blue })
  vim.api.nvim_set_hl(0, '@tag.typescriptreact', { fg = colors.light_blue })
  vim.api.nvim_set_hl(0, '@constructor.tsx', { fg = colors.coral })
  vim.api.nvim_set_hl(0, '@constructor.typescriptreact', { fg = colors.coral })

  -- JSX属性名
  vim.api.nvim_set_hl(0, '@tag.attribute.tsx', { fg = colors.orange })
  vim.api.nvim_set_hl(0, '@tag.attribute.typescriptreact', { fg = colors.orange })

  -- JSX区切り文字 (<, >, /, =)
  vim.api.nvim_set_hl(0, '@tag.delimiter.tsx', { fg = colors.gray })
  vim.api.nvim_set_hl(0, '@tag.delimiter.typescriptreact', { fg = colors.gray })
  vim.api.nvim_set_hl(0, '@operator.tsx', { fg = colors.gray })
  vim.api.nvim_set_hl(0, '@operator.typescriptreact', { fg = colors.gray })

  -- 文字列
  vim.api.nvim_set_hl(0, '@string.tsx', { fg = colors.green })
  vim.api.nvim_set_hl(0, '@string.typescriptreact', { fg = colors.green })

  -- 変数・識別子
  vim.api.nvim_set_hl(0, '@variable.tsx', { fg = colors.white })
  vim.api.nvim_set_hl(0, '@variable.typescriptreact', { fg = colors.white })

  -- プロパティアクセス
  vim.api.nvim_set_hl(0, '@property.tsx', { fg = colors.white })
  vim.api.nvim_set_hl(0, '@property.typescriptreact', { fg = colors.white })
  vim.api.nvim_set_hl(0, '@variable.member.tsx', { fg = colors.white })
  vim.api.nvim_set_hl(0, '@variable.member.typescriptreact', { fg = colors.white })

  -- JSX式の括弧 ({})
  vim.api.nvim_set_hl(0, '@punctuation.bracket.tsx', { fg = colors.cyan })
  vim.api.nvim_set_hl(0, '@punctuation.bracket.typescriptreact', { fg = colors.cyan })

  -- 関数名
  vim.api.nvim_set_hl(0, '@function.tsx', { fg = colors.purple })
  vim.api.nvim_set_hl(0, '@function.typescriptreact', { fg = colors.purple })

  -- キーワード
  vim.api.nvim_set_hl(0, '@keyword.tsx', { fg = colors.red })
  vim.api.nvim_set_hl(0, '@keyword.typescriptreact', { fg = colors.red })

  -- 数値
  vim.api.nvim_set_hl(0, '@number.tsx', { fg = colors.orange })
  vim.api.nvim_set_hl(0, '@number.typescriptreact', { fg = colors.orange })

  -- boolean
  vim.api.nvim_set_hl(0, '@boolean.tsx', { fg = colors.blue })
  vim.api.nvim_set_hl(0, '@boolean.typescriptreact', { fg = colors.blue })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'tsx', 'typescriptreact' },
    callback = function()
      vim.fn.matchadd('htmlTag', '<\\s*\\zs[a-z]\\+')
      vim.fn.matchadd('htmlTag', '</\\s*\\zs[a-z]\\+')
      vim.api.nvim_set_hl(0, 'htmlTag', { fg = colors.light_blue })

      vim.fn.matchadd('reactComponent', '<\\s*\\zs[A-Z]\\w*')
      vim.fn.matchadd('reactComponent', '</\\s*\\zs[A-Z]\\w*')
      vim.api.nvim_set_hl(0, 'reactComponent', { fg = colors.coral })
    end,
  })
end

return M
