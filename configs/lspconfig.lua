local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspconfig = require("lspconfig")
local util = require "lspconfig/util"

lspconfig.gopls.setup {
  on_attach = on_attach,  
  capabilities = capabilities,
  cmd = {"gopls"},
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
}

local servers = {"ts_ls","pyright", "tailwindcss", "eslint", "html", "cssls", "jsonls"}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- lspconfig.emmet_ls.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue" },
--   init_options = {
--     html = {
--       options = {
--         -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
--         ["bem.enabled"] = true,
--       },
--     },
--   }
-- })

lspconfig.lua_ls.setup {
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}
