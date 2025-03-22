local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

local function esc(x)
    return (x:gsub('%%', '%%%%')
    :gsub('^%^', '%%^')
    :gsub('%$$', '%%$')
    :gsub('%(', '%%(')
    :gsub('%)', '%%)')
    :gsub('%.', '%%.')
    :gsub('%[', '%%[')
    :gsub('%]', '%%]')
    :gsub('%*', '%%*')
    :gsub('%+', '%%+')
    :gsub('%-', '%%-')
    :gsub('%?', '%%?'))
end

-- local parse_output = function(params, done)
--     local diagnostics = {}
--     if params.output then
--         -- output from spectre is a single raw string, with lines delimited by "\n"
--         local lines = vim.split(params.output, "\n")

--         -- errors are located at the end of the file
--         -- find the line where the errors begin
--         local begin_line = -1
--         for i = #lines, 1, -1 do
--             local found, _ = string.find(lines[i], "Error found by spectre during AHDL compile")
--             if found then
--                 begin_line = i + 1 -- errors begin in the following line
--                 break
--             end
--         end

--         if begin_line ~= -1 then
--             for i = begin_line, #lines do
--                 -- check if line is the beginning of an error block
--                 local _, _, severity, code = string.find(lines[i], [[^%s+(%w+)%s+%(%w+-(%d+)%):.+$]])

--                 if severity then
--                     -- we want to find where the block ends
--                     local end_line = #lines - 1 -- default value is end of the file

--                     -- find the location of the next error block
--                     for j = i + 1, #lines do
--                         local next_error_block, _ = string.find(lines[j], "ERROR")
--                         if next_error_block then
--                             end_line = j - 1
--                             break
--                         end
--                     end

--                     -- start building the diagnostic string
--                     local s = ""
--                     local sep = ""
--                     for k = i, end_line do
--                         s = s .. sep .. string.gsub(lines[k], "%s%s", "")
--                         sep = " "
--                     end

--                     -- remove file path from the string
--                     s = s:gsub([["]] .. esc(params.temp_path) .. [[", ]], "")

--                     -- get the line number in the source code where the error occured
--                     local _, _, row = string.find(s, [[line%s*(%d+):%s*]])

--                     -- remove line number from string
--                     s = s:gsub([[line%s*(%d+):%s*]], "")

--                     if row then
--                         -- return diagnostics information
--                         table.insert(diagnostics, {
--                             row = row,
--                             code = tonumber(code),
--                             message = s,
--                             severity = 1,
--                             source = "veriloga",
--                         })
--                     end

--                     i = end_line + 1 -- move to the next error
--                 end
--             end
--         end
--     end
--     done(diagnostics)
-- end


local parse_output = function(params, done)
    local diagnostics = {}

    if params.output then

        -- Split the input string into lines
        local lines = vim.split(params.output, "\n")
        -- vim.print(lines)

        -- Identify the indices of all lines containing "ERROR" or "WARNING"
        local diagnosticIndices = {}
        for index, line in ipairs(lines) do
            if line:find("ERROR") or line:find("WARNING") then
                table.insert(diagnosticIndices, index)
            end
        end

        -- Loop through the diagnostics, concatenating the lines of each diagnostic block
        for i, startIndex in ipairs(diagnosticIndices) do
            local endIndex = (i < #diagnosticIndices and diagnosticIndices[i + 1] - 1) or #lines
            local diagnosticBlock = table.concat(lines, "\n", startIndex, endIndex)

            -- Extract details using Lua patterns
            local severity = diagnosticBlock:find("ERROR") and 1 or 2
            local code = diagnosticBlock:match("%(VACOMP%-([^)]+)%)")
            local error_line = diagnosticBlock:match(':%s*"([^"]+)"')
            local row, message = diagnosticBlock:match("line (%d+):%s+(.+)")

            if message then
                message = message:gsub("%s+", " ")
            end

            if message then
                table.insert(diagnostics, {
                    row = tonumber(row),
                    code = code,
                    message = message,
                    severity = severity,
                    source = "veriloga",
                })
            end
        end
    end
    done(diagnostics)
end



return helpers.make_builtin({
    name = "veriloga",
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "verilogams" },
    generator_opts = {
        command = "docker",
        -- args = { "exec", "analog-eda-container", "/bin/bash", "-c", "source ~/.bashrc; spectre -ahdllint=static " .. "/mnt" .. "$FILENAME" },
        args = { "exec", "analog-eda-container", "/bin/bash", "-c", "source ~/.bashrc; spectre \\#dpl /dev/null \\#ahdlfile " .. "/mnt" .. "$FILENAME" },
        -- command = "spectre",
        -- args = { "-ahdllint=static", "$FILENAME" },
        to_stdin = false,
        to_temp_file = true,
        from_stderr = true,
        format = "raw",
        on_output = parse_output,

    },
    factory = helpers.generator_factory,
})
