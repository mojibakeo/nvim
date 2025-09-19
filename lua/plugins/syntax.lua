return {
  { 'pantharshit00/vim-prisma', ft = { 'prisma' } },
  { 'jparise/vim-graphql', ft = { 'graphql', 'typescriptreact', 'javascriptreact' } },
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
}
