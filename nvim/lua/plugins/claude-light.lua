-- Claude Code Light Theme for Neovim
-- Colors extracted from Claude Code's light theme

local function setup_claude_light()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = "light"

  -- Claude Code light theme palette
  local c = {
    bg = "#FFFFFF",
    bg_dim = "#F0F0F0", -- userMessageBackground
    bg_code = "#FAF5FA", -- bashMessageBackground
    bg_info = "#E6F5FA", -- memoryBackground
    fg = "#000000", -- text
    inactive = "#666666",
    subtle = "#AFAFAF",
    border = "#999999", -- promptBorder
    selection = "#B4D5FF", -- selectionBg
    claude = "#D77757", -- claude orange
    blue = "#5769F7", -- claude blue / suggestion
    green = "#2C7A39", -- success
    red = "#AB2B3F", -- error
    warning = "#966C1E",
    purple = "#8700FF", -- merged / autoAccept
    teal = "#006666", -- planMode
    cyan = "#009999", -- background accent
    ide_blue = "#4782C8", -- ide
    prof_blue = "#6A9BCC", -- professionalBlue
    diff_add = "#C7E1CB", -- diffAddedDimmed
    diff_del = "#FDD2D8", -- diffRemovedDimmed
    diff_add_word = "#2F9D44", -- diffAddedWord
    diff_del_word = "#D1454B", -- diffRemovedWord
    diff_add_bright = "#69DB7C",
    diff_del_bright = "#FFA8B4",
    fast_orange = "#FF6A00",
  }

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- Editor basics
  hi("Normal", { fg = c.fg, bg = c.bg })
  hi("NormalFloat", { fg = c.fg, bg = c.bg_dim })
  hi("FloatBorder", { fg = c.border, bg = c.bg_dim })
  hi("FloatTitle", { fg = c.claude, bg = c.bg_dim, bold = true })
  hi("Cursor", { fg = c.bg, bg = c.fg })
  hi("CursorLine", { bg = c.bg_dim })
  hi("CursorColumn", { bg = c.bg_dim })
  hi("ColorColumn", { bg = c.bg_dim })
  hi("LineNr", { fg = c.subtle })
  hi("CursorLineNr", { fg = c.claude, bold = true })
  hi("SignColumn", { bg = c.bg })
  hi("FoldColumn", { fg = c.subtle, bg = c.bg })
  hi("Folded", { fg = c.inactive, bg = c.bg_dim })
  hi("VertSplit", { fg = c.bg_dim })
  hi("WinSeparator", { fg = c.bg_dim })
  hi("Visual", { bg = c.selection })
  hi("VisualNOS", { bg = c.selection })
  hi("Search", { fg = c.fg, bg = "#FFE68A" })
  hi("IncSearch", { fg = c.bg, bg = c.claude })
  hi("CurSearch", { fg = c.bg, bg = c.claude })
  hi("Substitute", { fg = c.bg, bg = c.red })

  -- Statusline
  hi("StatusLine", { fg = c.fg, bg = c.bg_dim })
  hi("StatusLineNC", { fg = c.inactive, bg = c.bg_dim })
  hi("WinBar", { fg = c.fg, bg = c.bg, bold = true })
  hi("WinBarNC", { fg = c.inactive, bg = c.bg })

  -- Tabline
  hi("TabLine", { fg = c.inactive, bg = c.bg_dim })
  hi("TabLineFill", { bg = c.bg_dim })
  hi("TabLineSel", { fg = c.claude, bg = c.bg, bold = true })

  -- Pmenu (completion menu)
  hi("Pmenu", { fg = c.fg, bg = c.bg_dim })
  hi("PmenuSel", { fg = c.fg, bg = c.selection })
  hi("PmenuSbar", { bg = c.bg_dim })
  hi("PmenuThumb", { bg = c.subtle })

  -- Messages
  hi("ErrorMsg", { fg = c.red, bold = true })
  hi("WarningMsg", { fg = c.warning, bold = true })
  hi("ModeMsg", { fg = c.blue, bold = true })
  hi("MoreMsg", { fg = c.green })
  hi("Question", { fg = c.blue })
  hi("Title", { fg = c.claude, bold = true })
  hi("Directory", { fg = c.blue })
  hi("NonText", { fg = c.subtle })
  hi("SpecialKey", { fg = c.subtle })
  hi("Whitespace", { fg = c.subtle })
  hi("EndOfBuffer", { fg = c.bg_dim })
  hi("Conceal", { fg = c.inactive })
  hi("MatchParen", { fg = c.claude, bold = true, underline = true })

  -- Diff
  hi("DiffAdd", { bg = c.diff_add })
  hi("DiffChange", { bg = "#E0E8F0" })
  hi("DiffDelete", { bg = c.diff_del })
  hi("DiffText", { bg = c.selection })
  hi("diffAdded", { fg = c.diff_add_word })
  hi("diffRemoved", { fg = c.diff_del_word })

  -- Spell
  hi("SpellBad", { sp = c.red, undercurl = true })
  hi("SpellCap", { sp = c.warning, undercurl = true })
  hi("SpellLocal", { sp = c.blue, undercurl = true })
  hi("SpellRare", { sp = c.purple, undercurl = true })

  -- Syntax highlighting
  hi("Comment", { fg = c.inactive, italic = true })
  hi("Constant", { fg = c.teal })
  hi("String", { fg = c.green })
  hi("Character", { fg = c.green })
  hi("Number", { fg = c.teal })
  hi("Boolean", { fg = c.teal })
  hi("Float", { fg = c.teal })
  hi("Identifier", { fg = c.fg })
  hi("Function", { fg = c.claude })
  hi("Statement", { fg = c.blue })
  hi("Conditional", { fg = c.blue })
  hi("Repeat", { fg = c.blue })
  hi("Label", { fg = c.blue })
  hi("Operator", { fg = c.fg })
  hi("Keyword", { fg = c.blue })
  hi("Exception", { fg = c.red })
  hi("PreProc", { fg = c.purple })
  hi("Include", { fg = c.purple })
  hi("Define", { fg = c.purple })
  hi("Macro", { fg = c.purple })
  hi("PreCondit", { fg = c.purple })
  hi("Type", { fg = c.purple })
  hi("StorageClass", { fg = c.blue })
  hi("Structure", { fg = c.purple })
  hi("Typedef", { fg = c.purple })
  hi("Special", { fg = c.claude })
  hi("SpecialChar", { fg = c.claude })
  hi("Tag", { fg = c.claude })
  hi("Delimiter", { fg = c.fg })
  hi("SpecialComment", { fg = c.inactive, italic = true })
  hi("Debug", { fg = c.red })
  hi("Underlined", { underline = true })
  hi("Error", { fg = c.red })
  hi("Todo", { fg = c.blue, bold = true })

  -- Treesitter
  hi("@variable", { fg = c.fg })
  hi("@variable.builtin", { fg = c.teal, italic = true })
  hi("@variable.parameter", { fg = c.fg })
  hi("@variable.member", { fg = c.fg })
  hi("@constant", { fg = c.teal })
  hi("@constant.builtin", { fg = c.teal })
  hi("@constant.macro", { fg = c.purple })
  hi("@module", { fg = c.ide_blue })
  hi("@string", { fg = c.green })
  hi("@string.escape", { fg = c.claude })
  hi("@string.regexp", { fg = c.claude })
  hi("@character", { fg = c.green })
  hi("@number", { fg = c.teal })
  hi("@boolean", { fg = c.teal })
  hi("@float", { fg = c.teal })
  hi("@function", { fg = c.claude })
  hi("@function.builtin", { fg = c.claude })
  hi("@function.call", { fg = c.claude })
  hi("@function.macro", { fg = c.purple })
  hi("@method", { fg = c.claude })
  hi("@method.call", { fg = c.claude })
  hi("@constructor", { fg = c.purple })
  hi("@keyword", { fg = c.blue })
  hi("@keyword.function", { fg = c.blue })
  hi("@keyword.operator", { fg = c.blue })
  hi("@keyword.return", { fg = c.blue })
  hi("@keyword.import", { fg = c.purple })
  hi("@conditional", { fg = c.blue })
  hi("@repeat", { fg = c.blue })
  hi("@label", { fg = c.blue })
  hi("@operator", { fg = c.fg })
  hi("@exception", { fg = c.red })
  hi("@type", { fg = c.purple })
  hi("@type.builtin", { fg = c.purple })
  hi("@type.qualifier", { fg = c.blue })
  hi("@attribute", { fg = c.purple })
  hi("@property", { fg = c.fg })
  hi("@field", { fg = c.fg })
  hi("@parameter", { fg = c.fg })
  hi("@punctuation.bracket", { fg = c.inactive })
  hi("@punctuation.delimiter", { fg = c.inactive })
  hi("@punctuation.special", { fg = c.claude })
  hi("@comment", { fg = c.inactive, italic = true })
  hi("@tag", { fg = c.claude })
  hi("@tag.attribute", { fg = c.blue })
  hi("@tag.delimiter", { fg = c.inactive })
  hi("@text.title", { fg = c.claude, bold = true })
  hi("@text.strong", { bold = true })
  hi("@text.emphasis", { italic = true })
  hi("@text.uri", { fg = c.blue, underline = true })
  hi("@text.literal", { fg = c.green })

  -- LSP Semantic Tokens
  hi("@lsp.type.class", { fg = c.purple })
  hi("@lsp.type.decorator", { fg = c.claude })
  hi("@lsp.type.enum", { fg = c.purple })
  hi("@lsp.type.enumMember", { fg = c.teal })
  hi("@lsp.type.function", { fg = c.claude })
  hi("@lsp.type.interface", { fg = c.purple })
  hi("@lsp.type.keyword", { fg = c.blue })
  hi("@lsp.type.macro", { fg = c.purple })
  hi("@lsp.type.method", { fg = c.claude })
  hi("@lsp.type.namespace", { fg = c.ide_blue })
  hi("@lsp.type.parameter", { fg = c.fg })
  hi("@lsp.type.property", { fg = c.fg })
  hi("@lsp.type.struct", { fg = c.purple })
  hi("@lsp.type.type", { fg = c.purple })
  hi("@lsp.type.typeParameter", { fg = c.purple })
  hi("@lsp.type.variable", { fg = c.fg })

  -- Diagnostics
  hi("DiagnosticError", { fg = c.red })
  hi("DiagnosticWarn", { fg = c.warning })
  hi("DiagnosticInfo", { fg = c.blue })
  hi("DiagnosticHint", { fg = c.teal })
  hi("DiagnosticOk", { fg = c.green })
  hi("DiagnosticUnderlineError", { sp = c.red, undercurl = true })
  hi("DiagnosticUnderlineWarn", { sp = c.warning, undercurl = true })
  hi("DiagnosticUnderlineInfo", { sp = c.blue, undercurl = true })
  hi("DiagnosticUnderlineHint", { sp = c.teal, undercurl = true })
  hi("DiagnosticVirtualTextError", { fg = c.red, bg = "#FDEAED" })
  hi("DiagnosticVirtualTextWarn", { fg = c.warning, bg = "#FDF5E6" })
  hi("DiagnosticVirtualTextInfo", { fg = c.blue, bg = "#EAEDFD" })
  hi("DiagnosticVirtualTextHint", { fg = c.teal, bg = "#E6F5FA" })

  -- Git signs
  hi("GitSignsAdd", { fg = c.diff_add_word })
  hi("GitSignsChange", { fg = c.blue })
  hi("GitSignsDelete", { fg = c.diff_del_word })

  -- Telescope
  hi("TelescopeNormal", { fg = c.fg, bg = c.bg })
  hi("TelescopeBorder", { fg = c.border, bg = c.bg })
  hi("TelescopePromptNormal", { fg = c.fg, bg = c.bg_dim })
  hi("TelescopePromptBorder", { fg = c.border, bg = c.bg_dim })
  hi("TelescopePromptTitle", { fg = c.bg, bg = c.claude })
  hi("TelescopePreviewTitle", { fg = c.bg, bg = c.blue })
  hi("TelescopeResultsTitle", { fg = c.bg, bg = c.teal })
  hi("TelescopeSelection", { bg = c.selection })
  hi("TelescopeMatching", { fg = c.claude, bold = true })

  -- nvim-cmp
  hi("CmpItemAbbr", { fg = c.fg })
  hi("CmpItemAbbrMatch", { fg = c.claude, bold = true })
  hi("CmpItemAbbrMatchFuzzy", { fg = c.claude })
  hi("CmpItemKindFunction", { fg = c.claude })
  hi("CmpItemKindMethod", { fg = c.claude })
  hi("CmpItemKindVariable", { fg = c.fg })
  hi("CmpItemKindKeyword", { fg = c.blue })
  hi("CmpItemKindClass", { fg = c.purple })
  hi("CmpItemKindInterface", { fg = c.purple })
  hi("CmpItemKindModule", { fg = c.ide_blue })
  hi("CmpItemKindProperty", { fg = c.fg })
  hi("CmpItemKindSnippet", { fg = c.teal })
  hi("CmpItemKindText", { fg = c.inactive })

  -- Indent guides
  hi("IndentBlanklineChar", { fg = "#E8E8E8" })
  hi("IblIndent", { fg = "#E8E8E8" })
  hi("IblScope", { fg = c.blue })
  hi("MiniIndentscopeSymbol", { fg = c.blue })

  -- Notify
  hi("NotifyERRORBorder", { fg = c.red })
  hi("NotifyWARNBorder", { fg = c.warning })
  hi("NotifyINFOBorder", { fg = c.blue })
  hi("NotifyDEBUGBorder", { fg = c.inactive })
  hi("NotifyTRACEBorder", { fg = c.purple })
  hi("NotifyERRORIcon", { fg = c.red })
  hi("NotifyWARNIcon", { fg = c.warning })
  hi("NotifyINFOIcon", { fg = c.blue })
  hi("NotifyDEBUGIcon", { fg = c.inactive })
  hi("NotifyTRACEIcon", { fg = c.purple })
  hi("NotifyERRORTitle", { fg = c.red })
  hi("NotifyWARNTitle", { fg = c.warning })
  hi("NotifyINFOTitle", { fg = c.blue })
  hi("NotifyDEBUGTitle", { fg = c.inactive })
  hi("NotifyTRACETitle", { fg = c.purple })

  -- Neo-tree
  hi("NeoTreeNormal", { fg = c.fg, bg = c.bg })
  hi("NeoTreeNormalNC", { fg = c.fg, bg = c.bg })
  hi("NeoTreeDirectoryIcon", { fg = c.blue })
  hi("NeoTreeDirectoryName", { fg = c.blue })
  hi("NeoTreeRootName", { fg = c.claude, bold = true })
  hi("NeoTreeGitAdded", { fg = c.diff_add_word })
  hi("NeoTreeGitModified", { fg = c.blue })
  hi("NeoTreeGitDeleted", { fg = c.diff_del_word })
  hi("NeoTreeGitUntracked", { fg = c.warning })
  hi("NeoTreeIndentMarker", { fg = "#E8E8E8" })

  -- Which-key
  hi("WhichKey", { fg = c.claude })
  hi("WhichKeyGroup", { fg = c.blue })
  hi("WhichKeyDesc", { fg = c.fg })
  hi("WhichKeySeparator", { fg = c.subtle })
  hi("WhichKeyFloat", { bg = c.bg_dim })

  -- Dashboard / mini.starter
  hi("MiniStarterHeader", { fg = c.claude })
  hi("MiniStarterFooter", { fg = c.inactive, italic = true })
  hi("MiniStarterItem", { fg = c.fg })
  hi("MiniStarterItemBullet", { fg = c.blue })
  hi("MiniStarterItemPrefix", { fg = c.claude })
  hi("MiniStarterSection", { fg = c.blue, bold = true })
  hi("MiniStarterQuery", { fg = c.claude })

  -- Lualine (will be picked up if lualine uses auto theme)
  hi("lualine_a_normal", { fg = c.bg, bg = c.blue, bold = true })
  hi("lualine_a_insert", { fg = c.bg, bg = c.green, bold = true })
  hi("lualine_a_visual", { fg = c.bg, bg = c.purple, bold = true })
  hi("lualine_a_command", { fg = c.bg, bg = c.claude, bold = true })
  hi("lualine_a_replace", { fg = c.bg, bg = c.red, bold = true })

  -- Noice / cmdline
  hi("NoiceCmdlinePopup", { fg = c.fg, bg = c.bg_dim })
  hi("NoiceCmdlinePopupBorder", { fg = c.border })
  hi("NoiceCmdlineIcon", { fg = c.claude })

  -- Lazy.nvim UI
  hi("LazyButton", { fg = c.fg, bg = c.bg_dim })
  hi("LazyButtonActive", { fg = c.bg, bg = c.blue })
  hi("LazyH1", { fg = c.bg, bg = c.blue, bold = true })
  hi("LazySpecial", { fg = c.claude })
end

-- Register as a colorscheme
vim.api.nvim_create_user_command("ClaudeLight", function()
  setup_claude_light()
  vim.g.colors_name = "claude-light"
end, {})

-- Auto-switch: claude-light for light mode, tokyonight for dark mode
local function apply_colorscheme()
  if vim.o.background == "light" then
    vim.cmd("colorscheme claude-light")
  else
    vim.cmd("colorscheme tokyonight")
  end
end

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = apply_colorscheme,
})

return {
  { "folke/tokyonight.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        apply_colorscheme()
      end,
    },
  },
}
