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
opt.wildmode = "longest,list"
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
-- External runtime paths (only if present)
----------------------------------------------------------------------
for _, path in ipairs({
    "/opt/homebrew/opt/fzf",
    "/Users/daqing/.opam/4.14.2/share/ocp-indent/vim",
}) do
    if vim.fn.isdirectory(path) == 1 then
        opt.rtp:prepend(path)
    end
end

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
    "chriskempson/base16-vim",
    "tanvirtin/monokai.nvim",

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
})

require("lsp")

-- Colorscheme
opt.background = "dark"
local is_ok, _ = pcall(vim.cmd, "colorscheme monokai_pro")
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
map("n", "<F1>", ":wqall<CR>")
-- Deliberately not via map(): "silent" makes Neovim draw the ":" at the end of a
-- lingering message line instead of clearing it, so the first ";" looks dead
vim.keymap.set("n", ";", ":", { noremap = true })
map("n", "<leader>d", ":NERDTreeToggle<CR>")
map("n", "<C-l>", ":EraseBadWhitespace<CR>")
map("n", "<leader>t", ":GFiles<CR>")
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
