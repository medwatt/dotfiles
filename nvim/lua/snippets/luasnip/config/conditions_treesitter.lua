local M = {}

local has_treesitter, ts = pcall(require, 'vim.treesitter')

local MATH_ENVIRONMENTS = {
    displaymath = true,
    equation = true,
    multline = true,
    eqnarray = true,
    align = true,
    array = true,
    split = true,
    alignat = true,
    gather = true,
    flalign = true
}

local MATH_NODES = {
    displayed_equation = true,
    inline_formula = true,
    math_environment = true,
}

local COMMENT = {
    ['comment'] = true,
    ['line_comment'] = true,
    ['block_comment'] = true,
    ['comment_environment'] = true,
}

local function get_node_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_range = { cursor[1] - 1, cursor[2] - 1 } -- note the new '-1' here
    local buf = vim.api.nvim_get_current_buf()
    local ok, parser = pcall(ts.get_parser, buf, "latex")
    if not ok or not parser then
        return
    end
    local root_tree = parser:parse()[1]
    local root = root_tree and root_tree:root()

    if not root then
        return
    end

    return root:named_descendant_for_range(cursor_range[1], cursor_range[2], cursor_range[1], cursor_range[2])
end

function M.in_comment()
    local node = get_node_at_cursor()
    while node do
        if COMMENT[node:type()] then
            return true
        end
        node = node:parent()
    end
    return false
end

function M.in_math()
    if has_treesitter then
        local buf = vim.api.nvim_get_current_buf()
        local node = get_node_at_cursor()
        while node do

            if node:type() == "text_mode" then
                return false
            end
            if MATH_NODES[node:type()] then
                return true
            end
            if node:type() == "generic_environment" then
                local begin = node:child(0)
                local names = begin and begin:field("name")

                if
                    names
                    and names[1]
                    and MATH_ENVIRONMENTS[ts.get_node_text(names[1], buf):gsub("{(%w+)%s*%*?}", "%1")]
                then
                    return true
                end
            end
            node = node:parent()
        end
        return false
    end
end

return M
