local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

local parse_output = function(params, done)
    local diagnostics = {}
    if params.output then
        local lines = vim.split(params.output, "\n")
        for _, line in ipairs(lines) do
            local severity, code, filename, row, message

            -- Pattern matching for format where code comes before the filename
            local pattern = [[^**%s+(%w+):%s+%(vlog%-(%d+)%)%s+([%a%d%s%.-_/]+)%((%d+)%):%s+(.+)]]
            severity, code, filename, row, message = line:match(pattern)

            -- If no match, try pattern matching for format where filename comes before the code
            if not severity then
                pattern = [[^**%s+(%w+):%s+([%a%d%s%.-_/]+)%((%d+)%):%s+%(vlog%-(%d+)%)%s+(.+)]]
                severity, filename, row, code, message = line:match(pattern)
            end

            if severity and code and filename and row and message then
                table.insert(diagnostics, {
                    row = tonumber(row),
                    code = code,
                    message = message,
                    severity = (severity == "Error" and 1 or (severity == "Warning" and 2 or nil)),
                    source = "vlog",
                })
            end
        end
    end
    done(diagnostics)
end


return helpers.make_builtin({
    name = "vlog",
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "verilog", "systemverilog" },
    generator_opts = {
        command = "vlog",
        args = { "-quiet", "-lint", "-work", "/tmp/vlog_work", "$FILENAME" },
        to_stdin = false,
        to_temp_file = true,
        from_stderr = true,
        format = "raw",
        on_output = parse_output,
    },
    factory = helpers.generator_factory,
})
