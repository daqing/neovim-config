-- Tree-sitter indentation for MoonBit.
--
-- Neovim ships a tree-sitter fold expression but no consumer for indents.scm,
-- and the C-oriented 'cindent' misfires on MoonBit: statements have no
-- terminator, so every line after the first in a block reads as a continuation
-- and gains an extra shiftwidth.
--
-- Derive the indent from the parse tree instead. A line is indented one
-- shiftwidth past the line that opened the innermost construct enclosing it;
-- a line starting with a closing delimiter, or with 'else', aligns with that
-- opening line instead.

local M = {}

-- Content is significant in these, so leave the author's own indentation alone
local verbatim = {
    multiline_string_literal = true,
    multiline_string_content = true,
    multiline_string_fragment = true,
    comment = true,
}

---@param buf integer
---@param lnum integer 1-based
---@return integer
local function indent_of(buf, lnum)
    local text = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ''
    return #(text:match('^%s*') or '')
end

function M.indentexpr()
    local buf = vim.api.nvim_get_current_buf()
    local sw = vim.bo[buf].shiftwidth
    if sw == 0 then
        sw = vim.bo[buf].tabstop
    end

    local lnum = vim.fn.line('.')
    local text = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ''
    local col = #(text:match('^%s*') or '')
    if text:sub(col + 1) == '' then
        return -1
    end

    local ok, parser = pcall(vim.treesitter.get_parser, buf, 'moonbit')
    if not ok or not parser then
        return -1
    end
    local tree = parser:parse()[1]
    if not tree then
        return -1
    end

    local row = lnum - 1
    local root = tree:root()
    local node = root:descendant_for_range(row, col, row, col)
    if not node then
        return -1
    end

    local n = node
    while n do
        if verbatim[n:type()] and select(1, n:range()) < row then
            return -1
        end
        n = n:parent()
    end

    -- Stop at the root: it encloses everything but is not a nesting level
    local anchor = node
    while anchor and anchor:parent() and anchor:start() >= row do
        anchor = anchor:parent()
    end
    if not anchor or anchor == root then
        return 0
    end

    local base = indent_of(buf, anchor:start() + 1)
    local first = text:sub(col + 1, col + 1)
    if first == '}' or first == ')' or first == ']' then
        return base
    end
    if text:sub(col + 1, col + 4) == 'else' then
        return base
    end
    return base + sw
end

return M
