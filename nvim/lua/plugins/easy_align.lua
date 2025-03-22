vim.g.easy_align_bypass_fold = 1
vim.g.easy_align_ignore_groups = {}

vim.g.easy_align_delimiters = {
    [">"] = {
        ["pattern"] = [[>>\|=>\|>]]
    },
    ["<"] = {
        ["pattern"] = [[<<\|<=\|<]]
    },
    ["/"] = {
        ["pattern"] = [[/]],
        ["delimiter_align"] = [[l]],
    },
    ["["] = {
        ["pattern"] = [[\]],
        ["left_margin"] = 0,
        ["right_margin"] = 0,
        ["stick_to_left"] = 0
    },
    ["]"] = {
        ["pattern"] = [[\]],
        ["left_margin"] = 0,
        ["right_margin"] = 0,
        ["stick_to_left"] = 0
    },
    ["("] = {
        ["pattern"] = [[(]],
        ["left_margin"] = 0,
        ["right_margin"] = 0,
        ["stick_to_left"] = 0
    },
    [")"] = {
        ["pattern"] = [[)]],
        ["left_margin"] = 0,
        ["right_margin"] = 0,
        ["stick_to_left"] = 0
    }
}
