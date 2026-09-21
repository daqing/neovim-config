-- Per-server settings, registered before mason-lspconfig enables the servers
-- Docs: https://github.com/neovim/nvim-lspconfig

-- Go
vim.lsp.config('gopls', {
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

-- Rust
vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = {
                command = 'clippy',
            },
        },
    },
})

-- Ruby
vim.lsp.config('ruby_lsp', {})

-- Python
vim.lsp.config('pylsp', {})

-- TypeScript / JavaScript
vim.lsp.config('ts_ls', {})

-- OCaml
-- ocamllsp is linked against the compiler-libs of the OCaml version it was built
-- with, so the binary has to come from the same switch as the project. The root
-- dir is only known once the client starts, hence the function form of `cmd`.
local function ocamllsp_cmd(dispatchers, config)
    local candidates = {}
    if config.root_dir then
        -- Local switch created by `opam switch create .`
        candidates[#candidates + 1] = config.root_dir .. '/_opam/bin/ocamllsp'
    end
    if vim.env.OPAM_SWITCH_PREFIX then
        candidates[#candidates + 1] = vim.env.OPAM_SWITCH_PREFIX .. '/bin/ocamllsp'
    end
    candidates[#candidates + 1] = 'ocamllsp'

    for _, exe in ipairs(candidates) do
        if vim.fn.executable(exe) == 1 then
            return vim.lsp.rpc.start({ exe }, dispatchers, {
                cwd = config.cmd_cwd,
                env = config.cmd_env,
                detached = config.detached,
            })
        end
    end

    error('ocamllsp not found: run `opam install ocaml-lsp-server` in the project switch')
end

vim.lsp.config('ocamllsp', {
    cmd = ocamllsp_cmd,
    settings = {
        extendedHover = { enable = true },
        syntaxDocumentation = { enable = true },
    },
})

-- Installed through opam, not mason, so mason-lspconfig's automatic_enable skips it
vim.lsp.enable('ocamllsp')

require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require('mason-lspconfig').setup({
    -- A list of servers to automatically install if they're not already installed
    ensure_installed = {
        'lua_ls',
        'gopls',
        'rust_analyzer',
        'ruby_lsp',
        'pylsp',
        'ts_ls',
    },
})

-- Diagnostics
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Buffer-local keymaps, set when a language server attaches
-- See `:help vim.lsp.*` for documentation on any of the below functions
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
    callback = function(ev)
        local bufopts = { noremap = true, silent = true, buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format()
        end, bufopts)
    end,
})
