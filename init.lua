-- Neovim entry point (init.lua takes precedence over init.vim)
-- Leader must be set before lazy.nvim
vim.g.mapleader = ","
vim.g.maplocalleader = ","

----------------------------------------------------------------------
-- Options
----------------------------------------------------------------------
local opt = vim.opt

-- General
opt.history = 256
opt.autowrite = true
opt.autoread = true
opt.clipboard = "unnamedplus"
opt.wildignore = "*.swp,*.back,node_modules/*,*.o,tmp/*"
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.fileencoding = "utf-8"
opt.modeline = true
opt.modelines = 5
opt.hidden = true

-- UI
opt.number = true
opt.showmatch = true
opt.matchtime = 5
opt.laststatus = 2
opt.ruler = true
opt.showcmd = true
opt.shortmess = "ltToOCFIa"
opt.showmode = true
opt.title = true
opt.termguicolors = true
opt.guifont = "Monaco:h22"
opt.colorcolumn = "80"
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"
opt.updatetime = 500

-- Search
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Editing
opt.wrap = false
opt.backspace = "indent,eol,start"
-- 第一次 Tab 补全最长公共前缀，之后每次 Tab 在候选间循环（绕一圈后回到原始输入）
opt.wildmode = "longest:full,full"
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smarttab = true
opt.autoindent = true
opt.smartindent = true
opt.copyindent = true
opt.cindent = true
opt.cinoptions = ":s,ps,ts,cs"
opt.cinwords = "if,else,while,do,for,switch,case"
opt.formatoptions:append("o")
opt.formatoptions:remove("r")
opt.formatoptions:append("t")
opt.formatoptions:remove("l")

-- Folding
opt.foldenable = true
opt.foldmethod = "indent"
opt.foldlevel = 4
opt.foldopen = "block,hor,mark,percent,quickfix,tag"

----------------------------------------------------------------------
-- Plugin globals
----------------------------------------------------------------------
vim.g.ackprg = "ag --nogroup --nocolor --column --ignore=db --ignore=log --ignore=tmp --ignore=test"
vim.g.SuperTabDefaultCompletionType = "<c-n>"

----------------------------------------------------------------------
-- Plugins (lazy.nvim)
----------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Color schemes
    { "phanviet/vim-monokai-pro", priority = 1000 },
    "w0ng/vim-hybrid",
    "drewtempelmeyer/palenight.vim",
    -- "chriskempson/base16-vim",
    "tanvirtin/monokai.nvim",
    {
      "folke/tokyonight.nvim",
      priority = 1000,   -- 让主题最先加载，避免闪烁
      config = function() vim.cmd.colorscheme("tokyonight-night") end,
    },

    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function() vim.cmd.colorscheme("catppuccin-mocha") end
    },

    {
      "sainnhe/gruvbox-material",
      priority = 1000,
      config = function() vim.cmd.colorscheme("gruvbox-material") end
    },

    {
      "sainnhe/everforest",
      priority = 1000,
      config = function() vim.cmd.colorscheme("everforest") end
    },

    {
      "rebelot/kanagawa.nvim",
      priority = 1000,
      config = function() vim.cmd.colorscheme("kanagawa") end
    },

    {
      "shaunsingh/nord.nvim",
      priority = 1000,
      config = function() vim.cmd.colorscheme("nord") end
    },

    {
      "EdenEast/nightfox.nvim",
      priority = 1000,
      config = function() vim.cmd.colorscheme("duskfox") end
    },


    -- Search & navigation
    "junegunn/fzf",
    "junegunn/fzf.vim",
    "rking/ag.vim",

    -- Editing
    "scrooloose/nerdtree",
    "bitc/vim-bad-whitespace",
    "daqing/supertab",
    "tomtom/tcomment_vim",
    "zivyangll/git-blame.vim",

    -- LSP
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",

    -- MoonBit
    {
        "moonbit-community/moonbit.nvim",
        ft = { "moonbit" },
        -- ftdetect covers .mbt/.mbti/moon.mod/moon.pkg/moon.work, but the plugin
        -- also attaches to these and they resolve to json/markdown
        event = {
            "BufReadPre moon.mod.json",
            "BufNewFile moon.mod.json",
            "BufReadPre moon.pkg.json",
            "BufNewFile moon.pkg.json",
            "BufReadPre *.mbt.md",
            "BufNewFile *.mbt.md",
        },
        -- moonbit.mooncakes loads plenary.curl unconditionally
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            mooncakes = {
                virtual_text = true,
                use_local = true,
            },
            -- nvim-treesitter is not installed; the parser is built by hand
            -- from the checkout in ~/.local/share/nvim/moonbit-parser into
            -- ~/.local/share/nvim/site/{parser,queries}. To rebuild after
            -- updating the grammar:
            --   cd ~/.local/share/nvim/moonbit-parser && git pull
            --   cc -O2 -std=c11 -fPIC -shared -I src \
            --     -o ~/.local/share/nvim/site/parser/moonbit.so src/parser.c src/scanner.c
            --   cp queries/*.scm ~/.local/share/nvim/site/queries/moonbit/
            treesitter = { auto_install = false },
        },
    },

    {
        dir = '/Users/daqing/mzevo/open-source/emo-lang/emo/editors/neovim',
        main = 'emo',   -- the directory is named `neovim`, the module is not
        opts = {},
    },
})

require("tokyonight").setup({ transparent = true })

----------------------------------------------------------------------
-- External runtime paths (only if present)
----------------------------------------------------------------------
-- lazy.nvim resets 'runtimepath' during setup(), so external paths have to be
-- prepended after it. ocp-indent must precede $VIMRUNTIME to shadow the
-- built-in indent/ocaml.vim.
local ocp_indent = "/Users/daqing/.opam/5.5.1/share/ocp-indent/vim"
if vim.fn.isdirectory(ocp_indent) == 1 then
    opt.rtp:prepend(ocp_indent)
end

require("lsp")

-- Colorscheme
opt.background = "dark"
local is_ok, _ = pcall(vim.cmd, "colorscheme gruvbox-material")
if not is_ok then
    vim.notify("colorscheme monokai_pro not found!")
end

----------------------------------------------------------------------
-- Keymaps
----------------------------------------------------------------------
local map = function(modes, lhs, rhs, desc)
    vim.keymap.set(modes, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map("n", "<C-a>", ":!git add %<CR>")
map("n", "<C-x>", ":cclose<CR>")
map("n", "<leader>/", ":nohlsearch<CR>")
-- Deliberately not via map(): "silent" makes Neovim draw the ":" at the end of a
-- lingering message line instead of clearing it, so the first ";" looks dead
vim.keymap.set("n", ";", ":", { noremap = true })
map("n", "<leader>d", ":NERDTreeToggle<CR>")
map("n", "<leader>q", ":cclose<CR>")
map("n", "<C-l>", ":EraseBadWhitespace<CR>")
map("n", "<leader>t", ":Files<CR>")
vim.keymap.set('n', '<leader>fs', vim.lsp.buf.workspace_symbol)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
map("n", "<C-n>", ":cnext<CR>")
map("n", "tp", ":tabprev<CR>")
map("n", "tn", ":tabnext<CR>")
map("n", "tq", ":tabclose<CR>")
map("n", "pa", ":% s/^[+-]//<CR>")
map("n", "<C-b>", ":<C-u>call gitblame#echo()<CR>")

----------------------------------------------------------------------
-- Commands & autocommands
----------------------------------------------------------------------
vim.api.nvim_create_user_command("W", function()
    vim.cmd("w !sudo tee % > /dev/null")
    vim.cmd("e!")
end, {})

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = { "Gemfile", "Rakefile", "Capfile", "*.rake", "config.ru" },
    command = "set filetype=ruby",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = { "*.md", "*.mkd", "*.markdown" },
    command = "set filetype=markdown",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = "COMMIT_EDITMSG",
    command = "set filetype=gitcommit",
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    command = "EraseBadWhitespace",
})

-- Vim's :terminal drops you straight into job mode, Neovim's leaves you in
-- terminal-normal where keys are taken as normal-mode commands
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        vim.cmd("startinsert")
    end,
})

-- vim-bad-whitespace's window-local :match is cloned into split windows after
-- its own WinEnter cleanup has run, so terminal buffers keep highlighting
-- trailing whitespace (guibg=red) forever; clear it whenever one is shown
local function clear_terminal_bad_whitespace(buf)
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        vim.api.nvim_win_call(win, function()
            for _, m in ipairs(vim.fn.getmatches()) do
                if m.group == "BadWhitespace" then
                    vim.fn.matchdelete(m.id)
                end
            end
        end)
    end
end

vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter", "WinEnter" }, {
    group = augroup,
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= "terminal" then
            return
        end
        clear_terminal_bad_whitespace(ev.buf)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
                clear_terminal_bad_whitespace(ev.buf)
            end
        end)
    end,
})

-- MoonBit: 'cindent' mis-indents it (no statement terminators) and Neovim has
-- no built-in consumer for indents.scm, so both folds and indent come from the
-- parse tree. See lua/moonbit_indent.lua.
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "moonbit",
    callback = function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt_local.indentexpr = "v:lua.require'moonbit_indent'.indentexpr()"
    end,
})

