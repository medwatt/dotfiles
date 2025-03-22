local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS_ON_SAVE = methods.internal.DIAGNOSTICS_ON_SAVE

return helpers.make_builtin({
    name = "ghdl",
    method = DIAGNOSTICS_ON_SAVE,
    filetypes = { "vhdl" },
    generator_opts = {
        command = "ghdl",
        to_stdin = false,
        to_temp_file = true,
        from_stderr = true,
        -- args = main(),
        args = { "-s", "--std=08", "sfsafa.vhd", "$FILENAME" }, -- i placed the random name in between to prevent errors from looking for files that don't exist
        format = "line",
        on_output = helpers.diagnostics.from_pattern(
        [[([^:]+):(%d+):(%d+):(.+)]],
        { 'filename', 'row', 'col', 'message' },
        {
            severities = {
                E = helpers.diagnostics.severities["error"],
            },
        }
        ),
    },
    factory = helpers.generator_factory,
})
