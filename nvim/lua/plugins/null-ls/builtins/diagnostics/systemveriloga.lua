local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

return helpers.make_builtin({
    name = "vlog",
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "systemverilog" },
    generator_opts = {
        command = "vlog",
        args = { "-quiet", "-lint", "-work", "/tmp/vlog_work", "$FILENAME" },
        to_stdin = false,
        to_temp_file = true,
        from_stderr = true,
        format = "line",
        on_output = helpers.diagnostics.from_pattern(
        [[^**%s+(%w+):%s+%(vlog%-(%d+)%)%s+([%a%d%s%.-_/]+)%((%d+)%):%s+(.+)]],
        { "severity", "code", "filename", "row", "message" },
        {
            severities = {
                E = helpers.diagnostics.severities["Error"],
                W = helpers.diagnostics.severities["Warning"],
            },
        }
        ),
    },
    factory = helpers.generator_factory,
})

