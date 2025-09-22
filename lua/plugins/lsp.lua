local function on_attach(_, bufnr)
  local telescope_builtin

  local function use_telescope(fn_name, opts)
    if not telescope_builtin then
      local ok, builtin = pcall(require, 'telescope.builtin')
      if ok then
        telescope_builtin = builtin
      end
    end
    if telescope_builtin and telescope_builtin[fn_name] then
      telescope_builtin[fn_name](opts or {})
      return true
    end
    return false
  end

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
  end
  map('n', 'gd', vim.lsp.buf.definition, '定義へジャンプ')
  map('n', 'gy', vim.lsp.buf.type_definition, '型定義へジャンプ')
  map('n', 'gi', function()
    if not use_telescope('lsp_implementations') then
      vim.lsp.buf.implementation()
    end
  end, '実装へジャンプ')
  map('n', 'gr', function()
    if not use_telescope('lsp_references', { show_line = false }) then
      vim.lsp.buf.references()
    end
  end, '参照を表示')
  map('n', 'K', vim.lsp.buf.hover, 'ドキュメント表示')
  map('n', 'qf', vim.lsp.buf.code_action, 'コードアクション')
  map('n', '<leader>2', vim.lsp.buf.rename, 'リネーム')

  local ok, lsp_signature = pcall(require, 'lsp_signature')
  if ok then
    lsp_signature.on_attach({
      bind = true,
      handler_opts = {
        border = 'rounded'
      }
    }, bufnr)
  end
end

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'hrsh7th/cmp-nvim-lsp',
      { 'j-hui/fidget.nvim', opts = {} },
      'ray-x/lsp_signature.nvim',
      'onsails/lspkind.nvim',
    },
    config = function()
      local mason = require('mason')
      mason.setup({})

      local mason_packages = {
        'rust-analyzer',
        'gopls',
        'typescript-language-server',
        'prisma-language-server',
        'tsp-server',
        'graphql-language-service-cli',
      }

      require('mason-tool-installer').setup({
        ensure_installed = mason_packages,
        auto_update = false,
        run_on_start = true,
      })

      local servers = {
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
              checkOnSave = {
                command = 'clippy',
              },
            },
          },
        },
        gopls = {},
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              preferences = {
                includeCompletionsForModuleExports = true,
                quotePreference = 'single',
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              preferences = {
                includeCompletionsForModuleExports = true,
                quotePreference = 'single',
              },
            },
          },
        },
        prismals = {},
        tsp_server = {},
        graphql = {
          filetypes = { 'graphql', 'typescriptreact', 'javascriptreact', 'typescript', 'javascript' },
        },
      }

      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local function configure(server_name, server_opts)
        local merged_opts = vim.tbl_deep_extend('force', {
          capabilities = capabilities,
          on_attach = on_attach,
        }, server_opts)

        local has_new_api = vim.lsp and vim.lsp.config and vim.lsp.enable
        if has_new_api then
          local ok = pcall(function()
            vim.lsp.config(server_name, merged_opts)
            vim.lsp.enable(server_name)
          end)
          if ok then
            return
          end
        end

        local ok, legacy = pcall(require, 'lspconfig')
        if not ok or not legacy[server_name] then
          vim.notify(('LSP サーバー %s の設定が見つからないのだ'):format(server_name), vim.log.levels.WARN)
          return
        end

        legacy[server_name].setup(merged_opts)
      end

      for server_name, server_opts in pairs(servers) do
        configure(server_name, server_opts)
      end

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 2,
          prefix = '●',
        },
        severity_sort = true,
      })
    end,
  },
}
