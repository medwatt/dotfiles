local M = {}

M.project_root = nil
M.projects = {}

local projects_file = vim.fn.stdpath("data") .. "/projects.json"
local markers = { ".git", "package.json", ".hg", ".svn" }

-- Project Management Functions
function M.load_projects()
    local file = io.open(projects_file, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local ok, data = pcall(vim.fn.json_decode, content)
        if ok and type(data) == "table" then
            M.projects = data
        else
            M.projects = {}
        end
    else
        M.projects = {}
    end
end

function M.save_projects()
    local file = io.open(projects_file, "w")
    if file then
        file:write(vim.fn.json_encode(M.projects))
        file:close()
    else
        print("Failed to write projects file")
    end
end

function M.add_project()
    local root = M.detect_project()
    if not vim.tbl_contains(M.projects, root) then
        table.insert(M.projects, root)
        M.save_projects()
        print("Added project: " .. root)
    else
        print("Project already added: " .. root)
    end
end

function M.switch_project()
    if #M.projects == 0 then
        print("No projects saved")
        return
    end
    local proj = ""
    require("fzf-lua").fzf_exec(M.projects, {
        prompt = 'Select a project: ',
        actions = {
            ['default'] = function(selected)
                if selected and #selected > 0 then
                    proj = tostring(selected[1])
                    M.project_root = proj
                    M.project_files()
                end
            end
        }
    })
end

function M.edit_projects_list()
    vim.cmd("edit " .. projects_file)
end

-- Project Root Detection Functions
function M.find_project_root(start)
    local dir = vim.fn.fnamemodify(start, ":p")
    while dir and dir ~= "/" do
        for _, marker in ipairs(markers) do
            if vim.loop.fs_stat(dir .. "/" .. marker) ~= nil then
                return dir
            end
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then break end
        dir = parent
    end
    return nil
end

function M.detect_project()
    local buf_path = vim.fn.expand("%:p:h")
    local root = M.find_project_root(buf_path)
    M.project_root = root or buf_path
    return M.project_root
end

function M.set_project_to_cwd()
    local buf_path = vim.fn.expand("%:p:h")
    M.project_root = buf_path
    print("Project root set to " .. M.project_root)
end

-- Project File Management Functions
function M.project_files()
    local path = M.project_root or M.detect_project()
    require("fzf-lua").files { cwd = path }
end

function M.project_live_grep()
    local path = M.project_root or M.detect_project()
    require("fzf-lua").live_grep { cwd = path }
end

function M.project_grep(search_query)
    local path = M.project_root or M.detect_project()
    require("fzf-lua").grep { cwd = path, search = search_query }
end

function M.project_search_and_replace()
    local path = M.project_root or M.detect_project()
    require("spectre").open { cwd = path }
end

function M.close_non_project_buffers()
    local project_root = M.project_root or M.detect_project()
    if not project_root then
        print("No project root detected")
        return
    end

    local buffers = vim.api.nvim_list_bufs()
    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if not vim.startswith(buf_name, project_root) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end
    print("Closed non-project buffers")
end

M.load_projects()

return M
