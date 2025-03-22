local M = {}

local default_config = {
    ui = {
        transparent_background = false,
        terminal_colors = true,
        diagnostics_text_color = true,
        italic_comments = false,
        enable_treesitter = true,
    },
    plugins = {
        indent_blankline = true,
        neorg = true,
        vim_illuminate = true,
        barbar = true,
        telescope = true,
        neogit = true,
        dashboard = true,
        startify = true,
        whichkey = true,
        nvim_tree = true,
        lspsaga = true,
    },
}

M.setup = function(user_config)

    local config = vim.tbl_deep_extend("force", default_config, user_config or {})
    M.config = config

    local palette = {
        fg      = "#c5c5c5",
        bg      = "#27272a",
        bg_alt  = "#212123",
        grey1   = "#666666",
        grey2   = "#383844",
        grey3   = "#343440",
        black1  = "#1a1a1a",
        black2  = "#000000",
        red1    = "#f2777a",
        red2    = "#bb6666",
        red3    = "#ab3737",
        red4    = "#221111",
        green1  = "#6db56d",
        green2  = "#559955",
        green3  = "#112211",
        aqua1   = "#55a9a9",
        aqua2   = "#1e8f8f",
        purple1 = "#a782a7",
        purple2 = "#a782a7",
        yellow1 = "#f0c674",
        yellow2 = "#ddba1a",
        orange1 = "#c98459",
        orange2 = "#b87348",
        brown1  = "#ccb18b",
        brown2  = "#9f8b6f",
        blue1   = "#5a90c6",
        blue2   = "#5a90c6",
        blue3   = "#5a90c6",
        base0   = "#2d2d31",
        base1   = "#25252a",
        base2   = "#1a1a1a",
        base3   = "#000000",
        base4   = "#666666",
        base5   = "#383844",
        base6   = "#343440",
        base7   = "#bbbbbb",
        base8   = "#ffffff",
        fg_alt  = "#bbbbbb",
    }

    local function set_hl(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- GENERAL UI
    set_hl("Normal", { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.fg })
    set_hl("NormalFloat", { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.fg })
    set_hl("NormalBorder", { bg = palette.bg, fg = palette.fg })
    set_hl("NormalPopup", { bg = palette.bg_alt, fg = palette.fg })
    set_hl("NormalPopover", { bg = palette.bg_alt, fg = palette.fg })
    set_hl("NormalPopupPrompt", { bg = palette.bg_alt, fg = palette.fg, bold = true })
    set_hl("NormalPopupSubtle", { bg = palette.bg_alt, fg = palette.grey1 })
    set_hl("EndOfBuffer", { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.bg })

    set_hl("Visual", { bg = palette.blue3 })
    set_hl("VisualBold", { bg = palette.blue3, bold = true })

    set_hl("LineNr", { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.grey1 })
    set_hl("Cursor", { bg = palette.red1 })
    set_hl("CursorLine", { bg = palette.grey2 })
    set_hl("CursorLineNr", { bg = palette.bg, fg = palette.green1, bold = true })
    set_hl("CursorColumn", { bg = palette.bg_alt })

    set_hl("Folded", { bg = palette.bg_alt, fg = palette.grey1 })
    set_hl("FoldColumn", { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.fg })
    set_hl("SignColumn", { bg = config.ui.transparent_background and "NONE" or palette.bg })
    set_hl("ColorColumn", { bg = palette.bg_alt })

    set_hl("IndentGuide", { fg = palette.grey1 })
    set_hl("IndentGuideEven", { link = "IndentGuide" })
    set_hl("IndentGuideOdd", { link = "IndentGuide" })

    set_hl("TermCursor", { fg = palette.fg, reverse = true })
    set_hl("TermCursorNC", { fg = palette.fg_alt, reverse = true })
    set_hl("TermNormal", { link = "Normal" })
    set_hl("TermNormalNC", { link = "TermNormal" })

    set_hl("WildMenu", { bg = palette.blue3, fg = palette.fg })
    set_hl("Separator", { fg = palette.fg_alt })
    set_hl("VertSplit", { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.grey1 })

    set_hl("TabLine", { bg = palette.bg_alt, fg = palette.fg, bold = true })
    set_hl("TabLineSel",
        { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.blue1, bold = true })
    set_hl("TabLineFill", { bg = palette.bg, bold = true })

    set_hl("StatusLine", { bg = palette.bg_alt, fg = palette.green1 })
    set_hl("StatusLineNC", { bg = palette.bg_alt, fg = palette.green1 })
    set_hl("StatusLinePart", { bg = palette.bg_alt, fg = palette.green1, bold = true })
    set_hl("StatusLinePartNC", { link = "StatusLinePart" })

    set_hl("Pmenu", { bg = palette.bg_alt, fg = palette.fg })
    set_hl("PmenuSel", { bg = palette.blue1, fg = palette.black1 })
    set_hl("PmenuSelBold", { bg = palette.blue1, fg = palette.black1, bold = true })
    set_hl("PmenuSbar", { bg = palette.bg_alt })
    set_hl("PmenuThumb", { bg = palette.grey1 })

    -- Search, Highlight, Conceal, Messages
    set_hl("Search", { bg = palette.blue3, fg = palette.fg })
    set_hl("Substitute", { fg = palette.red1, bold = true, strikethrough = true })
    set_hl("IncSearch", { bg = palette.red3, fg = palette.yellow2, bold = true })
    set_hl("IncSearchCursor", { reverse = true })

    set_hl("Conceal", { fg = palette.grey1 })
    set_hl("SpecialKey", { fg = palette.purple1, bold = true })
    set_hl("NonText", { fg = palette.fg, bold = true })
    set_hl("MatchParen", { fg = palette.red1, bold = true })
    set_hl("Whitespace", { fg = palette.grey1 })

    set_hl("Highlight", { bg = palette.bg_alt })
    set_hl("HighlightSubtle", { link = "Highlight" })

    set_hl("Question", { fg = palette.green1, bold = true })

    set_hl("File", { fg = palette.fg })
    set_hl("Directory", { fg = palette.purple1, bold = true })
    set_hl("Title", { fg = palette.purple1, bold = true })

    set_hl("Bold", { bold = true })
    set_hl("Emphasis", { italic = true })

    -- Text Levels
    set_hl("TextNormal", { fg = palette.fg })
    set_hl("TextNormalBold", { fg = palette.fg, bold = true })
    set_hl("TextInfo", { fg = palette.blue1 })
    set_hl("TextInfoBold", { fg = palette.blue1, bold = true })
    set_hl("TextSuccess", { fg = palette.green1 })
    set_hl("TextSuccessBold", { fg = palette.green1, bold = true })
    set_hl("TextWarning", { fg = palette.yellow1 })
    set_hl("TextWarningBold", { fg = palette.yellow1, bold = true })
    set_hl("TextDebug", { fg = palette.yellow1 })
    set_hl("TextError", { fg = palette.red1 })
    set_hl("TextErrorBold", { fg = palette.red1, bold = true })
    set_hl("TextSpecial", { fg = palette.purple1 })
    set_hl("TextSpecialBold", { fg = palette.purple1, bold = true })
    set_hl("TextMuted", { fg = palette.grey3 })

    set_hl("Msg", { link = "TextSuccess" })
    set_hl("MoreMsg", { link = "TextInfo" })
    set_hl("WarningMsg", { link = "TextWarning" })
    set_hl("Error", { link = "TextError" })
    set_hl("ErrorMsg", { link = "TextError" })
    set_hl("ModeMsg", { link = "TextSpecial" })
    set_hl("Todo", { link = "TextWarningBold" })

    -- Checkhealth
    set_hl("healthError", { link = "ErrorMsg" })
    set_hl("healthSuccess", { link = "Msg" })
    set_hl("healthWarning", { link = "WarningMsg" })

    -- Main Syntax
    set_hl("Tag", { fg = palette.blue1, bold = true })
    set_hl("Link", { fg = palette.green1, underline = true })
    set_hl("URL", { link = "Link" })
    set_hl("Underlined", { fg = palette.blue1, underline = true })

    set_hl("Comment", { fg = palette.grey1, italic = config.ui.italic_comments })
    set_hl("CommentBold", { fg = palette.grey1, bold = true })
    set_hl("SpecialComment", { fg = palette.grey1, bold = true })

    set_hl("Macro", { fg = palette.purple1 })
    set_hl("Define", { fg = palette.purple1, bold = true })
    set_hl("Include", { fg = palette.purple1, bold = true })
    set_hl("PreProc", { fg = palette.purple1, bold = true })
    set_hl("PreCondit", { fg = palette.purple1, bold = true })

    set_hl("Label", { fg = palette.blue1 })
    set_hl("Repeat", { fg = palette.blue1 })
    set_hl("Keyword", { fg = palette.purple1, bold = true })
    set_hl("Operator", { fg = palette.purple1, bold = true })
    set_hl("Delimiter", { fg = palette.purple1, bold = true })
    set_hl("Statement", { fg = palette.purple1, bold = true })
    set_hl("Exception", { fg = palette.purple1, bold = true })
    set_hl("Conditional", { fg = palette.purple1, bold = true })

    set_hl("Variable", { fg = palette.orange1 })
    set_hl("VariableBuiltin", { fg = palette.orange1, bold = true })
    set_hl("Constant", { fg = palette.red1, bold = true })

    set_hl("Number", { fg = palette.orange1 })
    set_hl("Float", { link = "Number" })
    set_hl("Boolean", { fg = palette.orange1, bold = true })
    set_hl("Enum", { fg = palette.orange1 })

    set_hl("Character", { fg = palette.purple1, bold = true })
    set_hl("SpecialChar", { fg = palette.purple1, bold = true })
    set_hl("String", { fg = palette.green1 })
    set_hl("StringDelimiter", { link = "String" })

    set_hl("Special", { fg = palette.purple1 })
    set_hl("SpecialBold", { fg = palette.purple1, bold = true })

    set_hl("Field", { fg = palette.purple1 })
    set_hl("Argument", { fg = palette.purple2 })
    set_hl("Attribute", { fg = palette.purple2 })
    set_hl("Identifier", { fg = palette.purple2 })
    set_hl("Property", { fg = palette.purple2 })
    set_hl("Function", { fg = palette.purple2 })
    set_hl("FunctionBuiltin", { fg = palette.purple2, bold = true })
    set_hl("KeywordFunction", { fg = palette.blue1, bold = true })
    set_hl("Method", { fg = palette.purple1 })

    set_hl("Type", { fg = palette.yellow1 })
    set_hl("Typedef", { fg = palette.blue1 })
    set_hl("TypeBuiltin", { fg = palette.yellow1, bold = true })
    set_hl("Class", { fg = palette.blue1 })
    set_hl("StorageClass", { fg = palette.blue1 })
    set_hl("Structure", { fg = palette.blue1 })

    set_hl("Regexp", { fg = "#dd0093" })
    set_hl("RegexpSpecial", { fg = "#a40073" })
    set_hl("RegexpDelimiter", { fg = "#540063", bold = true })
    set_hl("RegexpKey", { fg = "#5f0041", bold = true })

    set_hl("CommentURL", { link = "URL" })
    set_hl("CommentLabel", { link = "CommentBold" })
    set_hl("CommentSection", { link = "CommentBold" })
    set_hl("Noise", { link = "Comment" })

    -- Diff
    set_hl("DiffAddedGutter", { fg = palette.green1, bold = true })
    set_hl("DiffModifiedGutter", { fg = palette.orange1, bold = true })
    set_hl("DiffRemovedGutter", { fg = palette.red1, bold = true })

    set_hl("DiffAddedGutterLineNr", { fg = palette.grey1 })
    set_hl("DiffModifiedGutterLineNr", { fg = palette.grey1 })
    set_hl("DiffRemovedGutterLineNr", { fg = palette.grey1 })

    set_hl("DiffAdd", { link = "DiffAddedGutter" })
    set_hl("DiffChange", { link = "DiffModifiedGutter" })
    set_hl("DiffDelete", { link = "DiffRemovedGutter" })

    set_hl("diffAdded", { fg = palette.green1, bg = palette.bg_alt })
    set_hl("diffChanged", { fg = palette.purple1 })
    set_hl("diffRemoved", { fg = palette.red1, bg = palette.black2 })
    set_hl("diffLine", { fg = palette.purple1 })
    set_hl("diffIndexLine", { fg = palette.aqua1 })
    set_hl("diffSubname", { fg = palette.aqua1 })
    set_hl("diffFile", { fg = palette.aqua1 })
    set_hl("diffOldFile", { fg = palette.blue1 })
    set_hl("diffNewFile", { fg = palette.blue1 })

    -- Markdown
    set_hl("markdownCode", { link = "Comment" })
    set_hl("markdownCodeBlock", { link = "markdownCode" })
    set_hl("markdownH1", { bold = true })
    set_hl("markdownH2", { bold = true })
    set_hl("markdownLinkText", { underline = true })

    -- LSP Diagnostics and related
    if config.ui.diagnostics_text_color then
        set_hl("ErrorMsgUnderline", { fg = palette.red1, underline = true })
        set_hl("WarningMsgUnderline", { fg = palette.yellow1, underline = true })
        set_hl("MoreMsgUnderline", { fg = palette.blue1, underline = true })
        set_hl("MsgUnderline", { fg = palette.green1, underline = true })
    else
        set_hl("ErrorMsgUnderline", { sp = palette.red1, underline = true })
        set_hl("WarningMsgUnderline", { sp = palette.yellow1, underline = true })
        set_hl("MoreMsgUnderline", { sp = palette.blue1, underline = true })
        set_hl("MsgUnderline", { sp = palette.green1, underline = true })
    end

    set_hl("LspHighlight", { bg = palette.bg_alt, bold = true })
    set_hl("LspSignatureActiveParameter", { fg = palette.purple1 })

    set_hl("DiagnosticFloatingError", { link = "ErrorMsg" })
    set_hl("DiagnosticFloatingWarn", { link = "WarningMsg" })
    set_hl("DiagnosticFloatingInfo", { link = "MoreMsg" })
    set_hl("DiagnosticFloatingHint", { link = "Msg" })

    set_hl("DiagnosticDefaultError", { link = "ErrorMsg" })
    set_hl("DiagnosticDefaultWarn", { link = "WarningMsg" })
    set_hl("DiagnosticDefaultInfo", { link = "MoreMsg" })
    set_hl("DiagnosticDefaultHint", { link = "Msg" })

    set_hl("DiagnosticVirtualTextError", { link = "ErrorMsg" })
    set_hl("DiagnosticVirtualTextWarn", { link = "WarningMsg" })
    set_hl("DiagnosticVirtualTextInfo", { link = "MoreMsg" })
    set_hl("DiagnosticVirtualTextHint", { link = "Msg" })

    set_hl("DiagnosticUnderlineError", { link = "ErrorMsgUnderline" })
    set_hl("DiagnosticUnderlineWarn", { link = "WarningMsgUnderline" })
    set_hl("DiagnosticUnderlineInfo", { link = "MoreMsgUnderline" })
    set_hl("DiagnosticUnderlineHint", { link = "MsgUnderline" })

    set_hl("DiagnosticSignError", { link = "ErrorMsg" })
    set_hl("DiagnosticSignWarning", { link = "WarningMsg" })
    set_hl("DiagnosticSignInformation", { link = "MoreMsg" })
    set_hl("DiagnosticSignHint", { link = "Msg" })

    set_hl("LspReferenceText", { link = "LspHighlight" })
    set_hl("LspReferenceRead", { link = "LspHighlight" })
    set_hl("LspReferenceWrite", { link = "LspHighlight" })

    -- Tree-Sitter
    if config.ui.enable_treesitter then
        set_hl("@annotation", { link = "PreProc" })
        set_hl("@attribute", { link = "Attribute" })
        set_hl("@conditional", { link = "Conditional" })
        set_hl("@comment", { link = "Comment" })
        set_hl("@constructor", { link = "Structure" })
        set_hl("@constant", { link = "Constant" })
        set_hl("@constant.builtin", { link = "Constant" })
        set_hl("@constant.macro", { link = "Macro" })
        set_hl("@error", { link = "Error" })
        set_hl("@exception", { link = "Exception" })
        set_hl("@field", { link = "Field" })
        set_hl("@float", { link = "Float" })
        set_hl("@function", { link = "Function" })
        set_hl("@function.builtin", { link = "FunctionBuiltin" })
        set_hl("@function.macro", { link = "Macro" })
        set_hl("@include", { link = "Include" })
        set_hl("@keyword", { link = "Keyword" })
        set_hl("@keyword.function", { link = "KeywordFunction" })
        set_hl("@label", { link = "Label" })
        set_hl("@math", { link = "Special" })
        set_hl("@method", { link = "Method" })
        set_hl("@namespace", { link = "Directory" })
        set_hl("@number", { link = "Number" })
        set_hl("@boolean", { link = "Boolean" })
        set_hl("@operator", { link = "Operator" })
        set_hl("@parameter", { link = "Argument" })
        set_hl("@parameter.reference", { link = "Argument" })
        set_hl("@property", { link = "Property" })
        set_hl("@punctuation.delimiter", { link = "Delimiter" })
        set_hl("@punctuation.bracket", { link = "Delimiter" })
        set_hl("@punctuation.special", { link = "Delimiter" })
        set_hl("@repeat", { link = "Repeat" })
        set_hl("@string", { link = "String" })
        set_hl("@string.regex", { link = "StringDelimiter" })
        set_hl("@string.escape", { link = "StringDelimiter" })
        set_hl("@structure", { link = "Structure" })
        set_hl("@tag", { link = "Tag" })
        set_hl("@tag.attribute", { link = "Attribute" })
        set_hl("@tag.delimiter", { link = "Delimiter" })
        set_hl("@strong", { link = "Bold" })
        set_hl("@uri", { link = "URL" })
        set_hl("@warning", { link = "WarningMsg" })
        set_hl("@danger", { link = "ErrorMsg" })
        set_hl("@type", { link = "Type" })
        set_hl("@type.builtin", { link = "TypeBuiltin" })
        set_hl("@variable", { link = "None" })
        set_hl("@variable.builtin", { link = "VariableBuiltin" })
        set_hl("@query.linter.error", { fg = palette.fg })
        set_hl("@text", { link = "TextNormal" })
        set_hl("@text.strong", { link = "TextNormalBold" })
        set_hl("@text.emphasis", { link = "Emphasis" })
        set_hl("@text.underline", { underline = true })
        set_hl("@text.strike", { fg = palette.purple1, strikethrough = true })
        set_hl("@text.title", { link = "Title" })
        set_hl("@text.uri", { link = "URL" })
        set_hl("@text.note", { link = "TextInfo" })
        set_hl("@text.warning", { link = "TextWarning" })
        set_hl("@text.danger", { link = "TextError" })
        set_hl("@todo", { link = "Todo" })
    end

    -- NetRW
    set_hl("netrwClassify", { fg = palette.blue1 })
    set_hl("netrwDir", { link = "Directory" })
    set_hl("netrwExe", { fg = palette.green1, bold = true })
    set_hl("netrwMakefile", { fg = palette.yellow1, bold = true })
    set_hl("netrwTreeBar", { link = "Comment" })

    -- Terminal colors
    if config.ui.terminal_colors then
        vim.g.terminal_color_0 = palette.bg
        vim.g.terminal_color_1 = palette.red1
        vim.g.terminal_color_2 = palette.green1
        vim.g.terminal_color_3 = palette.yellow1
        vim.g.terminal_color_4 = palette.blue1
        vim.g.terminal_color_5 = palette.purple1
        vim.g.terminal_color_6 = palette.aqua1
        vim.g.terminal_color_7 = palette.fg
        vim.g.terminal_color_8 = palette.grey1
        vim.g.terminal_color_9 = palette.red1
        vim.g.terminal_color_10 = palette.green1
        vim.g.terminal_color_11 = palette.orange1
        vim.g.terminal_color_12 = palette.blue1
        vim.g.terminal_color_13 = palette.purple1
        vim.g.terminal_color_14 = palette.aqua1
        vim.g.terminal_color_15 = palette.base8
        vim.g.terminal_color_background = palette.bg_alt
        vim.g.terminal_color_foreground = palette.fg_alt
    end

    -- Plugin integrations
    if config.plugins.indent_blankline then
        set_hl("IndentBlanklineChar", { fg = palette.grey1, nocombine = true })
        set_hl("IndentBlanklineContextChar", { fg = palette.blue1 or palette.orange1, nocombine = true })
        set_hl("IndentBlanklineSpaceChar", { link = "IndentBlanklineChar" })
        set_hl("IndentBlanklineSpaceCharBlankline", { link = "IndentBlanklineChar" })
    end

    if config.plugins.neorg then
        set_hl("NeorgMarkupVerbatim", { link = "Comment" })

        set_hl("NeorgHeading1Title", { link = "@attribute" })
        set_hl("NeorgHeading2Title", { link = "@label" })
        set_hl("NeorgHeading3Title", { link = "@math" })
        set_hl("NeorgHeading4Title", { link = "@string" })
        set_hl("NeorgHeading5Title", { link = "@type" })
        set_hl("NeorgHeading6Title", { link = "@number" })
        set_hl("NeorgHeading1Prefix", { link = "@attribute" })
        set_hl("NeorgHeading2Prefix", { link = "@label" })
        set_hl("NeorgHeading3Prefix", { link = "@math" })
        set_hl("NeorgHeading4Prefix", { link = "@string" })
        set_hl("NeorgHeading5Prefix", { link = "@type" })
        set_hl("NeorgHeading6Prefix", { link = "@number" })

        set_hl("Blue", { fg = palette.blue1 })
        set_hl("Yellow", { fg = palette.yellow1 })
        set_hl("Red", { fg = palette.red1 })
        set_hl("Green", { fg = palette.green1 })
        set_hl("Brown", { fg = palette.orange1 })

        set_hl("Headline1", { bg = palette.bg_alt })
        set_hl("Headline2", { bg = palette.bg_alt })
        set_hl("Headline3", { bg = palette.bg_alt })
        set_hl("Headline4", { bg = palette.bg_alt })
        set_hl("Headline5", { bg = palette.bg_alt })
        set_hl("Headline6", { bg = palette.bg_alt })
    end

    if config.plugins.vim_illuminate then
        set_hl("illuminatedWord", { underline = true })
    end

    if config.plugins.barbar then
        set_hl("BufferCurrent",
            { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.base8 or palette.base0 })
        set_hl("BufferCurrentIndex",
            { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.base6 })
        set_hl("BufferCurrentMod",
            { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.yellow1 })
        set_hl("BufferCurrentSign",
            { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.blue1 })
        set_hl("BufferCurrentTarget",
            { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.red1, bold = true })

        set_hl("BufferVisible", { fg = palette.base7, bg = config.ui.transparent_background and "NONE" or palette.bg })
        set_hl("BufferVisibleIndex",
            { fg = palette.base6, bg = config.ui.transparent_background and "NONE" or palette.bg })
        set_hl("BufferVisibleMod",
            { fg = palette.yellow1, bg = config.ui.transparent_background and "NONE" or palette.bg })
        set_hl("BufferVisibleSign",
            { fg = palette.base4, bg = config.ui.transparent_background and "NONE" or palette.bg })
        set_hl("BufferVisibleTarget",
            { fg = palette.red1, bg = config.ui.transparent_background and "NONE" or palette.bg, bold = true })

        set_hl("BufferInactive", { fg = palette.base6, bg = palette.base1 or palette.base8 })
        set_hl("BufferInactiveIndex", { fg = palette.base6, bg = palette.base1 or palette.base8 })
        set_hl("BufferInactiveMod", { fg = palette.yellow1, bg = palette.base1 or palette.base8 })
        set_hl("BufferInactiveSign", { fg = palette.base4, bg = palette.base1 or palette.base8 })
        set_hl("BufferInactiveTarget", { fg = palette.red1, bg = palette.base1 or palette.base8, bold = true })

        set_hl("BufferTabpages", { fg = palette.blue1, bg = palette.bg_alt, bold = true })
        set_hl("BufferTabpageFill", { fg = palette.base4, bg = palette.base1 or palette.base8, bold = true })

        set_hl("BufferPart", { fg = palette.fg_alt, bg = palette.bg_alt, bold = true })
    end

    if config.plugins.telescope then
        set_hl("TelescopeNormal", { fg = palette.fg })
        set_hl("TelescopeBorder", { fg = palette.blue1 or palette.red1 })
        set_hl("TelescopePrompt", { link = "TelescopeNormal" })
        set_hl("TelescopePromptBorder", { link = "TelescopeBorder" })
        set_hl("TelescopePromptPrefix", { fg = palette.blue1 or palette.red1 })
        set_hl("TelescopeResultsBorder", { link = "TelescopeBorder" })
        set_hl("TelescopePreviewBorder", { link = "TelescopeBorder" })
        set_hl("TelescopeMatching", { fg = palette.purple1, bold = true })
        set_hl("TelescopeSelection", { link = "VisualBold" })
        set_hl("TelescopeSelectionCaret", { fg = palette.blue1 or palette.red1 })
    end

    if config.plugins.neogit then
        set_hl("NeogitDiffAdd", { bg = "#e9f1e8", fg = "#40803f" })
        set_hl("NeogitDiffAddHighlight", { bg = "#d8e8d7", fg = palette.green1, bold = true })
        set_hl("NeogitDiffDelete", { bg = "#f7e9e8", fg = "#cc5655" })
        set_hl("NeogitDiffDeleteHighlight", { bg = "#f5d9d6", fg = palette.red1, bold = true })
        set_hl("NeogitDiffContext", { bg = config.ui.transparent_background and "NONE" or palette.bg, fg = palette.fg })
        set_hl("NeogitDiffContextHighlight", { bg = palette.bg_alt, fg = palette.fg, bold = true })
        set_hl("NeogitHunkHeader", { bg = palette.purple1, fg = palette.bg })
        set_hl("NeogitHunkHeaderHighlight", { bg = palette.purple1, fg = palette.bg_alt, bold = true })
        set_hl("NeogitStagedChanges", { fg = palette.blue1 or palette.orange1, bold = true })
        set_hl("NeogitStagedChangesRegion", { bg = palette.bg_alt })
        set_hl("NeogitStashes", { fg = palette.blue1 or palette.orange1, bold = true })
        set_hl("NeogitUnstagedChanges", { fg = palette.blue1 or palette.orange1, bold = true })
        set_hl("NeogitUntrackedfiles", { fg = palette.blue1 or palette.orange1, bold = true })
    end

    if config.plugins.dashboard then
        set_hl("dashboardHeader", { fg = palette.grey1 })
        set_hl("dashboardFooter", { link = "dashboardHeader" })
        set_hl("dashboardCenter", { fg = palette.blue1 or palette.orange1 })
        set_hl("dashboardShortcut", { fg = palette.purple1 })
    end

    if config.plugins.startify then
        set_hl("StartifyHeader", { fg = palette.fg_alt })
        set_hl("StartifyBracket", { fg = palette.grey1 })
        set_hl("StartifyNumber", { fg = palette.blue1 or palette.orange1 })
        set_hl("StartifyPath", { fg = palette.purple1 })
        set_hl("StartifySlash", { link = "StartifyPath" })
        set_hl("StartifyFile", { fg = palette.green1 })
    end

    if config.plugins.whichkey then
        set_hl("WhichKey", { fg = palette.blue1 or palette.red1 })
        set_hl("WhichKeyGroup", { fg = palette.purple2 })
        set_hl("WhichKeyDesc", { fg = palette.purple2 })
        set_hl("WhichKeySeparator", { link = "Separator" })
        set_hl("WhichKeyFloat", { fg = palette.base0 or palette.base6 })
        set_hl("WhichKeyValue", { fg = palette.grey1 })
    end

    if config.plugins.nvim_tree then
        set_hl("NvimTreeFolderName", { fg = palette.blue1 or palette.base8, bold = true })
        set_hl("NvimTreeRootFolder", { fg = palette.green1 })
        set_hl("NvimTreeEmptyFolderName", { fg = palette.fg_alt, bold = true })
        set_hl("NvimTreeSymlink", { fg = palette.fg, underline = true })
        set_hl("NvimTreeExecFile", { fg = palette.green1, bold = true })
        set_hl("NvimTreeImageFile", { fg = palette.blue1 or palette.red1 })
        set_hl("NvimTreeOpenedFile", { fg = palette.fg_alt })
        set_hl("NvimTreeSpecialFile", { fg = palette.fg, underline = true })
        set_hl("NvimTreeMarkdownFile", { fg = palette.fg, underline = true })

        set_hl("NvimTreeGitDirty", { link = "DiffModifiedGutter" })
        set_hl("NvimTreeGitStaged", { link = "DiffModifiedGutter" })
        set_hl("NvimTreeGitMerge", { link = "DiffModifiedGutter" })
        set_hl("NvimTreeGitRenamed", { link = "DiffModifiedGutter" })
        set_hl("NvimTreeGitNew", { link = "DiffAddedGutter" })
        set_hl("NvimTreeGitDeleted", { link = "DiffRemovedGutter" })

        set_hl("NvimTreeIndentMarker", { link = "IndentGuide" })
        set_hl("NvimTreeOpenedFolderName", { link = "NvimTreeFolderName" })
    end

    if config.plugins.lspsaga then
        set_hl("SagaShadow", { bg = config.ui.transparent_background and "NONE" or palette.bg })
        set_hl("LspSagaDiagnosticHeader", { fg = palette.red1 })
        set_hl("LspSagaDiagnosticBorder", { link = "Normal" })
        set_hl("LspSagaDiagnosticTruncateLine", { link = "Normal" })
        set_hl("LspFloatWinBorder", { link = "Normal" })
        set_hl("LspSagaBorderTitle", { link = "Title" })
        set_hl("TargetWord", { link = "Error" })
        set_hl("ReferencesCount", { link = "Title" })
        set_hl("ReferencesIcon", { link = "Special" })
        set_hl("DefinitionCount", { link = "Title" })
        set_hl("TargetFileName", { link = "Comment" })
        set_hl("DefinitionIcon", { link = "Special" })
        set_hl("ProviderTruncateLine", { link = "Normal" })
        set_hl("LspSagaFinderSelection", { link = "Search" })
        set_hl("DiagnosticTruncateLine", { link = "Normal" })
        set_hl("DefinitionPreviewTitle", { link = "Title" })
        set_hl("LspSagaShTruncateLine", { link = "Normal" })
        set_hl("LspSagaDocTruncateLine", { link = "Normal" })
        set_hl("LineDiagTuncateLine", { link = "Normal" })
        set_hl("LspSagaCodeActionTitle", { link = "Title" })
        set_hl("LspSagaCodeActionTruncateLine", { link = "Normal" })
        set_hl("LspSagaCodeActionContent", { link = "Normal" })
        set_hl("LspSagaRenamePromptPrefix", { link = "Normal" })
        set_hl("LspSagaRenameBorder", { link = "Bold" })
        set_hl("LspSagaHoverBorder", { link = "Bold" })
        set_hl("LspSagaSignatureHelpBorder", { link = "Bold" })
        set_hl("LspSagaCodeActionBorder", { link = "Bold" })
        set_hl("LspSagaDefPreviewBorder", { link = "Bold" })
        set_hl("LspLinesDiagBorder", { link = "Bold" })
    end
end

return M
