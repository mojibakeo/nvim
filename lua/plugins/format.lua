local decode_json = function(text)
  if vim.json and vim.json.decode then
    return vim.json.decode(text, { luanil = { object = true, array = true } })
  end
  return vim.fn.json_decode(text)
end

local function read_package_json(path)
  local ok_lines, lines = pcall(vim.fn.readfile, path)
  if not ok_lines then
    return nil
  end
  local text = table.concat(lines, '\n')
  local ok_json, decoded = pcall(decode_json, text)
  if not ok_json or type(decoded) ~= 'table' then
    return nil
  end
  return decoded
end

local function get_filename(ctx)
  local filename = ctx and ctx.filename
  if type(filename) == 'string' and filename ~= '' then
    return filename
  end
  return nil
end

local function get_dirname(ctx)
  local dirname = ctx and ctx.dirname
  if type(dirname) == 'string' and dirname ~= '' then
    return dirname
  end
  local filename = get_filename(ctx)
  if filename then
    return vim.fs.dirname(filename)
  end
  return nil
end

local function has_dependency(ctx, package_names)
  local dirname = get_dirname(ctx)
  if not dirname then
    return false
  end
  local package_json_path = vim.fs.find('package.json', { path = dirname, upward = true })[1]
  if not package_json_path then
    return false
  end
  local data = read_package_json(package_json_path)
  if not data then
    return false
  end
  local fields = {
    data.dependencies,
    data.devDependencies,
    data.peerDependencies,
    data.optionalDependencies,
  }
  for _, field in ipairs(fields) do
    if type(field) == 'table' then
      for _, name in ipairs(package_names) do
        if field[name] ~= nil then
          return true
        end
      end
    end
  end
  return false
end

local function has_project_file(ctx, filenames)
  local dirname = get_dirname(ctx)
  if not dirname then
    return false
  end
  local found = vim.fs.find(filenames, { path = dirname, upward = true })
  return #found > 0
end

local function has_executable(ctx, bin)
  local dirname = get_dirname(ctx)
  if dirname then
    local local_bins = vim.fs.find('node_modules/.bin/' .. bin, { path = dirname, upward = true })
    for _, candidate in ipairs(local_bins) do
      if vim.loop.fs_access(candidate, 'X') then
        return true
      end
    end
  end
  return vim.fn.executable(bin) == 1
end

local function parent_dir(path)
  if not path then
    return nil
  end
  return vim.fs.dirname(path)
end

return {
  {
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo' },
    event = { 'BufWritePre', 'BufNewFile' },
    opts = function()
      local biome_condition = function(ctx)
        return has_executable(ctx, 'biome')
      end


      local prettier_condition = function(ctx)
        if not has_executable(ctx, 'prettier') then
          return false
        end
        if has_project_file(ctx, {
          '.prettierrc',
          '.prettierrc.js',
          '.prettierrc.cjs',
          '.prettierrc.mjs',
          '.prettierrc.json',
          '.prettierrc.yaml',
          '.prettierrc.yml',
          '.prettierrc.toml',
          'prettier.config.js',
          'prettier.config.cjs',
          'prettier.config.mjs',
          'prettier.config.ts',
        }) then
          return true
        end
        return has_dependency(ctx, { 'prettier' })
      end

      local prisma_condition = function(ctx)
        return has_executable(ctx, 'prisma')
      end

      local typespec_condition = function(ctx)
        return has_executable(ctx, 'tsp')
      end

      local function cwd_from_ctx(ctx)
        return parent_dir(get_filename(ctx)) or get_dirname(ctx) or vim.loop.cwd()
      end

      return {
        notify_on_error = false,
        format_on_save = function()
          return { timeout_ms = 5000, lsp_fallback = true }
        end,
        stop_after_first = true,
        formatters_by_ft = {
          javascript = { 'biome', 'prettier' },
          javascriptreact = { 'biome', 'prettier' },
          typescript = { 'biome', 'prettier' },
          typescriptreact = { 'biome', 'prettier' },
          vue = { 'biome', 'prettier' },
          json = { 'biome', 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
          lua = {},
          rust = {},
          go = {},
          prisma = { 'prisma_format' },
          typespec = { 'tsp_format' },
        },
        formatters = {
          biome = {
            condition = biome_condition,
            command = 'biome',
            args = { 'check', '--write', '--stdin-file-path', '$FILENAME' },
            stdin = true,
            prefer_local = 'node_modules/.bin',
          },
          prettier = {
            condition = prettier_condition,
            inherit = true,
            prefer_local = 'node_modules/.bin',
          },
          prisma_format = {
            condition = prisma_condition,
            command = 'prisma',
            args = { 'format', '--schema', '$FILENAME' },
            stdin = false,
            cwd = cwd_from_ctx,
            prefer_local = 'node_modules/.bin',
          },
          tsp_format = {
            condition = typespec_condition,
            command = 'tsp',
            args = { 'format', '--check', '$FILENAME' },
            stdin = false,
            cwd = cwd_from_ctx,
            prefer_local = 'node_modules/.bin',
          },
        },
      }
    end,
  },
}
