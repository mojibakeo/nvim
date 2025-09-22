return {
  { 'pantharshit00/vim-prisma', ft = { 'prisma' } },
  {
    'jparise/vim-graphql',
    ft = { 'graphql', 'typescriptreact', 'javascriptreact' },
    config = function()
      vim.g.graphql_javascript_tags = { 'gql', 'graphql', 'Relay.QL' }
    end,
  },
  { 'styled-components/vim-styled-components', branch = 'main', ft = { 'typescriptreact', 'javascriptreact' } },
  { 'rust-lang/rust.vim', ft = { 'rust' } },
  {
    'HiPhish/rainbow-delimiters.nvim',
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
          tsx = 'rainbow-parens',
          jsx = 'rainbow-parens',
          javascript = 'rainbow-parens',
          typescript = 'rainbow-parens',
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }
    end,
  },
  {
    'ixru/nvim-markdown',
    ft = { 'markdown' },
    init = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_toml_frontmatter = 1
      vim.g.vim_markdown_json_frontmatter = 1
    end,
  },
  {
    'OXY2DEV/markview.nvim',
    ft = { 'markdown', 'quarto', 'rmd' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {},
  },
}
