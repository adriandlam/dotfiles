-- Highlight groups for the Linear colorscheme.
--
-- Token semantics come straight from .config/bat/themes/Linear.tmTheme and the
-- Zed port, so a file looks the same in `bat`, Zed and here:
--   keyword  indigo   function purple   type   blue
--   string   teal     number   yellow   punct  muted

local M = {}

---@param c table palette
---@param opts table
function M.get(c, opts)
  local transparent = opts.transparent
  local bg = transparent and c.none or c.bg
  local bg_float = transparent and c.none or c.bg_editor
  local it = opts.italics

  local hl = {
    -- ── Editor ──────────────────────────────────────────────────────────
    Normal = { fg = c.fg, bg = bg },
    NormalNC = { fg = c.fg, bg = bg },
    NormalFloat = { fg = c.fg, bg = bg_float },
    FloatBorder = { fg = c.border, bg = bg_float },
    FloatTitle = { fg = c.indigo, bg = bg_float, bold = true },
    ColorColumn = { bg = c.bg_editor },
    Cursor = { fg = c.bg, bg = c.fg },
    lCursor = { fg = c.bg, bg = c.fg },
    CursorIM = { fg = c.bg, bg = c.fg },
    CursorLine = { bg = c.bg_editor },
    CursorColumn = { bg = c.bg_editor },
    CursorLineNr = { fg = c.fg, bold = true },
    LineNr = { fg = c.fg_comment },
    LineNrAbove = { fg = c.fg_comment },
    LineNrBelow = { fg = c.fg_comment },
    SignColumn = { fg = c.fg_comment, bg = bg },
    FoldColumn = { fg = c.fg_comment, bg = bg },
    Folded = { fg = c.fg_muted, bg = c.bg_editor },
    WinSeparator = { fg = c.border, bg = bg },
    VertSplit = { fg = c.border, bg = bg },
    EndOfBuffer = { fg = bg == c.none and c.bg or bg },
    NonText = { fg = c.fg_comment },
    Whitespace = { fg = c.border },
    SpecialKey = { fg = c.fg_comment },
    Conceal = { fg = c.fg_muted },
    Directory = { fg = c.blue },
    Title = { fg = c.blue, bold = true },
    MatchParen = { fg = c.yellow, bold = true },
    Visual = { bg = c.bg_visual },
    VisualNOS = { bg = c.bg_visual },
    Search = { fg = c.fg_dim, bg = c.bg_search },
    IncSearch = { fg = c.bg, bg = c.indigo },
    CurSearch = { fg = c.bg, bg = c.indigo },
    Substitute = { fg = c.bg, bg = c.red },
    QuickFixLine = { bg = c.bg_visual, bold = true },
    WinBar = { fg = c.fg_muted, bg = bg },
    WinBarNC = { fg = c.fg_comment, bg = bg },

    -- ── Messages ────────────────────────────────────────────────────────
    ErrorMsg = { fg = c.red },
    WarningMsg = { fg = c.yellow },
    ModeMsg = { fg = c.fg_muted, bold = true },
    MoreMsg = { fg = c.teal },
    Question = { fg = c.indigo },
    MsgArea = { fg = c.fg },
    MsgSeparator = { fg = c.border },

    -- ── Statusline / tabs ───────────────────────────────────────────────
    StatusLine = { fg = c.fg_muted, bg = c.bg_deepest },
    StatusLineNC = { fg = c.fg_comment, bg = c.bg_deepest },
    TabLine = { fg = c.fg_comment, bg = c.bg_dark },
    TabLineFill = { bg = c.bg_dark },
    TabLineSel = { fg = c.fg, bg = c.bg },

    -- ── Popup menu ──────────────────────────────────────────────────────
    Pmenu = { fg = c.fg_muted, bg = c.bg_editor },
    PmenuSel = { fg = c.fg, bg = c.bg_visual },
    PmenuKind = { fg = c.purple, bg = c.bg_editor },
    PmenuKindSel = { fg = c.purple, bg = c.bg_visual },
    PmenuExtra = { fg = c.fg_comment, bg = c.bg_editor },
    PmenuExtraSel = { fg = c.fg_comment, bg = c.bg_visual },
    PmenuSbar = { bg = c.bg_editor },
    PmenuThumb = { bg = c.fg_comment },
    WildMenu = { fg = c.bg, bg = c.indigo },

    -- ── Legacy syntax ───────────────────────────────────────────────────
    Comment = { fg = c.fg_comment, italic = it.comments },
    Constant = { fg = c.yellow },
    String = { fg = c.teal },
    Character = { fg = c.teal },
    Number = { fg = c.yellow },
    Boolean = { fg = c.yellow },
    Float = { fg = c.yellow },
    Identifier = { fg = c.fg },
    Function = { fg = c.purple, italic = it.functions },
    Statement = { fg = c.indigo, italic = it.keywords },
    Conditional = { fg = c.indigo, italic = it.keywords },
    Repeat = { fg = c.indigo, italic = it.keywords },
    Label = { fg = c.blue },
    Operator = { fg = c.fg_muted },
    Keyword = { fg = c.indigo, italic = it.keywords },
    Exception = { fg = c.indigo, italic = it.keywords },
    PreProc = { fg = c.indigo },
    Include = { fg = c.indigo, italic = it.keywords },
    Define = { fg = c.indigo },
    Macro = { fg = c.purple },
    PreCondit = { fg = c.indigo },
    Type = { fg = c.blue },
    StorageClass = { fg = c.indigo, italic = it.keywords },
    Structure = { fg = c.blue },
    Typedef = { fg = c.blue },
    Special = { fg = c.yellow },
    SpecialChar = { fg = c.yellow },
    Tag = { fg = c.blue },
    Delimiter = { fg = c.fg_muted },
    SpecialComment = { fg = c.fg_muted, italic = it.comments },
    Debug = { fg = c.red },
    Underlined = { underline = true },
    Ignore = { fg = c.fg_comment },
    Error = { fg = c.red },
    Todo = { fg = c.bg, bg = c.yellow, bold = true },

    -- ── Diff ────────────────────────────────────────────────────────────
    DiffAdd = { bg = c.diff_add_bg },
    DiffChange = { bg = c.diff_change_bg },
    DiffDelete = { bg = c.diff_del_bg },
    DiffText = { bg = c.diff_add_emph },
    diffAdded = { fg = c.green },
    diffRemoved = { fg = c.red },
    diffChanged = { fg = c.yellow },
    diffOldFile = { fg = c.red },
    diffNewFile = { fg = c.green },
    diffFile = { fg = c.indigo, bold = true },
    diffLine = { fg = c.fg_muted, italic = true },
    diffIndexLine = { fg = c.fg_comment },

    -- ── Spell ───────────────────────────────────────────────────────────
    SpellBad = { sp = c.red, undercurl = true },
    SpellCap = { sp = c.yellow, undercurl = true },
    SpellLocal = { sp = c.blue, undercurl = true },
    SpellRare = { sp = c.purple, undercurl = true },

    -- ── Treesitter ──────────────────────────────────────────────────────
    ["@comment"] = { link = "Comment" },
    ["@comment.documentation"] = { fg = c.fg_comment, italic = it.comments },
    ["@comment.error"] = { fg = c.red },
    ["@comment.warning"] = { fg = c.yellow },
    ["@comment.todo"] = { fg = c.bg, bg = c.yellow, bold = true },
    ["@comment.note"] = { fg = c.bg, bg = c.blue, bold = true },

    ["@string"] = { fg = c.teal },
    ["@string.documentation"] = { fg = c.teal },
    ["@string.escape"] = { fg = c.yellow },
    ["@string.regexp"] = { fg = c.yellow },
    ["@string.special"] = { fg = c.teal },
    ["@string.special.url"] = { fg = c.indigo, underline = true },
    ["@character"] = { fg = c.teal },
    ["@character.special"] = { fg = c.yellow },

    ["@number"] = { fg = c.yellow },
    ["@number.float"] = { fg = c.yellow },
    ["@boolean"] = { fg = c.yellow },
    ["@constant"] = { fg = c.yellow },
    ["@constant.builtin"] = { fg = c.yellow },
    ["@constant.macro"] = { fg = c.yellow },

    ["@function"] = { fg = c.purple, italic = it.functions },
    ["@function.builtin"] = { fg = c.purple },
    ["@function.call"] = { fg = c.purple },
    ["@function.macro"] = { fg = c.purple },
    ["@function.method"] = { fg = c.purple, italic = it.functions },
    ["@function.method.call"] = { fg = c.purple },
    ["@constructor"] = { fg = c.blue },

    ["@keyword"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.function"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.operator"] = { fg = c.indigo },
    ["@keyword.return"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.import"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.export"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.conditional"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.repeat"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.exception"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.coroutine"] = { fg = c.indigo, italic = it.keywords },
    ["@keyword.directive"] = { fg = c.indigo },

    ["@operator"] = { fg = c.fg_muted },
    ["@punctuation.delimiter"] = { fg = c.fg_muted },
    ["@punctuation.bracket"] = { fg = c.fg_muted },
    ["@punctuation.special"] = { fg = c.fg_muted },

    ["@variable"] = { fg = c.fg, italic = it.variables },
    ["@variable.builtin"] = { fg = c.fg_muted },
    ["@variable.parameter"] = { fg = c.fg, italic = it.variables },
    ["@variable.member"] = { fg = c.fg },
    ["@property"] = { fg = c.fg },
    ["@field"] = { fg = c.fg },

    ["@type"] = { fg = c.blue },
    ["@type.builtin"] = { fg = c.blue },
    ["@type.definition"] = { fg = c.blue },
    ["@type.qualifier"] = { fg = c.indigo },
    ["@attribute"] = { fg = c.teal },
    ["@module"] = { fg = c.blue },
    ["@namespace"] = { fg = c.blue },
    ["@label"] = { fg = c.blue },

    ["@tag"] = { fg = c.blue },
    ["@tag.builtin"] = { fg = c.blue },
    ["@tag.attribute"] = { fg = c.teal },
    ["@tag.delimiter"] = { fg = c.fg_muted },

    ["@diff.plus"] = { fg = c.green },
    ["@diff.minus"] = { fg = c.red },
    ["@diff.delta"] = { fg = c.yellow },

    -- Markup, matching the tmTheme's markdown block
    ["@markup"] = { fg = c.fg },
    ["@markup.heading"] = { fg = c.blue, bold = true },
    ["@markup.heading.1"] = { fg = c.blue, bold = true },
    ["@markup.heading.2"] = { fg = c.indigo, bold = true },
    ["@markup.heading.3"] = { fg = c.purple, bold = true },
    ["@markup.heading.4"] = { fg = c.teal, bold = true },
    ["@markup.heading.5"] = { fg = c.yellow, bold = true },
    ["@markup.heading.6"] = { fg = c.fg_muted, bold = true },
    ["@markup.strong"] = { fg = c.purple, bold = true },
    ["@markup.italic"] = { fg = c.fg, italic = true },
    ["@markup.strikethrough"] = { fg = c.fg_comment, strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.raw"] = { fg = c.teal },
    ["@markup.raw.block"] = { fg = c.teal },
    ["@markup.link"] = { fg = c.purple },
    ["@markup.link.url"] = { fg = c.teal, underline = true },
    ["@markup.link.label"] = { fg = c.purple },
    ["@markup.list"] = { fg = c.red },
    ["@markup.list.checked"] = { fg = c.green },
    ["@markup.list.unchecked"] = { fg = c.fg_comment },
    ["@markup.quote"] = { fg = c.fg_comment, italic = true },
    ["@markup.math"] = { fg = c.teal },

    -- ── LSP semantic tokens ─────────────────────────────────────────────
    ["@lsp.type.class"] = { fg = c.blue },
    ["@lsp.type.comment"] = {},
    ["@lsp.type.decorator"] = { fg = c.yellow },
    ["@lsp.type.enum"] = { fg = c.blue },
    ["@lsp.type.enumMember"] = { fg = c.yellow },
    ["@lsp.type.function"] = { fg = c.purple },
    ["@lsp.type.interface"] = { fg = c.blue },
    ["@lsp.type.macro"] = { fg = c.purple },
    ["@lsp.type.method"] = { fg = c.purple },
    ["@lsp.type.namespace"] = { fg = c.blue },
    ["@lsp.type.parameter"] = { fg = c.fg },
    ["@lsp.type.property"] = { fg = c.fg },
    ["@lsp.type.struct"] = { fg = c.blue },
    ["@lsp.type.type"] = { fg = c.blue },
    ["@lsp.type.typeParameter"] = { fg = c.blue },
    ["@lsp.type.variable"] = { fg = c.fg },
    ["@lsp.type.keyword"] = { fg = c.indigo },
    ["@lsp.type.string"] = { fg = c.teal },
    ["@lsp.type.number"] = { fg = c.yellow },
    ["@lsp.type.operator"] = { fg = c.fg_muted },
    ["@lsp.mod.readonly"] = { fg = c.yellow },
    ["@lsp.mod.deprecated"] = { strikethrough = true },
    ["@lsp.typemod.function.defaultLibrary"] = { fg = c.purple },
    ["@lsp.typemod.variable.defaultLibrary"] = { fg = c.fg_muted },

    -- ── Diagnostics ─────────────────────────────────────────────────────
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.fg_muted },
    DiagnosticOk = { fg = c.green },
    DiagnosticVirtualTextError = { fg = c.red, bg = c.bg_editor },
    DiagnosticVirtualTextWarn = { fg = c.yellow, bg = c.bg_editor },
    DiagnosticVirtualTextInfo = { fg = c.blue, bg = c.bg_editor },
    DiagnosticVirtualTextHint = { fg = c.fg_muted, bg = c.bg_editor },
    DiagnosticVirtualTextOk = { fg = c.green, bg = c.bg_editor },
    DiagnosticUnderlineError = { sp = c.red, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.yellow, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.fg_muted, undercurl = true },
    DiagnosticUnderlineOk = { sp = c.green, undercurl = true },
    DiagnosticFloatingError = { fg = c.red },
    DiagnosticFloatingWarn = { fg = c.yellow },
    DiagnosticFloatingInfo = { fg = c.blue },
    DiagnosticFloatingHint = { fg = c.fg_muted },
    DiagnosticSignError = { fg = c.red },
    DiagnosticSignWarn = { fg = c.yellow },
    DiagnosticSignInfo = { fg = c.blue },
    DiagnosticSignHint = { fg = c.fg_muted },
    DiagnosticUnnecessary = { link = "Comment" },
    DiagnosticDeprecated = { sp = c.fg_comment, strikethrough = true },

    -- ── LSP ─────────────────────────────────────────────────────────────
    LspReferenceText = { bg = c.bg_visual },
    LspReferenceRead = { bg = c.bg_visual },
    LspReferenceWrite = { bg = c.bg_visual },
    LspSignatureActiveParameter = { fg = c.yellow, bold = true },
    LspCodeLens = { fg = c.fg_comment },
    LspInlayHint = { fg = c.fg_comment, bg = c.bg_editor },

    -- ── gitsigns ────────────────────────────────────────────────────────
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.yellow },
    GitSignsDelete = { fg = c.red },
    GitSignsAddInline = { bg = c.diff_add_emph },
    GitSignsChangeInline = { bg = c.diff_change_bg },
    GitSignsDeleteInline = { bg = c.diff_del_emph },
    GitSignsCurrentLineBlame = { fg = c.fg_comment, italic = true },

    -- ── snacks.nvim (LazyVim's dashboard, picker, indent, notifier) ─────
    SnacksNormal = { fg = c.fg, bg = bg_float },
    SnacksBackdrop = { bg = c.bg_deepest },
    SnacksWinBar = { fg = c.fg_muted, bg = bg_float },
    SnacksDashboardHeader = { fg = c.indigo },
    SnacksDashboardTitle = { fg = c.blue },
    SnacksDashboardIcon = { fg = c.purple },
    SnacksDashboardDesc = { fg = c.fg_muted },
    SnacksDashboardKey = { fg = c.yellow },
    SnacksDashboardFooter = { fg = c.fg_comment, italic = true },
    SnacksDashboardDir = { fg = c.fg_comment },
    SnacksDashboardSpecial = { fg = c.teal },
    SnacksPicker = { fg = c.fg, bg = bg_float },
    SnacksPickerBorder = { fg = c.border, bg = bg_float },
    SnacksPickerTitle = { fg = c.indigo, bold = true },
    SnacksPickerTree = { fg = c.border },
    SnacksPickerCol = { fg = c.border },
    SnacksPickerDir = { fg = c.fg_comment },
    SnacksPickerFile = { fg = c.fg },
    SnacksPickerMatch = { fg = c.indigo, bold = true },
    SnacksPickerSelected = { fg = c.teal },
    SnacksPickerCursorLine = { bg = c.bg_visual },
    SnacksPickerPrompt = { fg = c.indigo },
    SnacksIndent = { fg = c.border_soft },
    SnacksIndentScope = { fg = c.fg_comment },
    SnacksNotifierInfo = { fg = c.blue },
    SnacksNotifierWarn = { fg = c.yellow },
    SnacksNotifierError = { fg = c.red },
    SnacksNotifierDebug = { fg = c.fg_comment },
    SnacksNotifierTrace = { fg = c.purple },

    -- ── which-key ───────────────────────────────────────────────────────
    WhichKey = { fg = c.indigo },
    WhichKeyGroup = { fg = c.blue },
    WhichKeyDesc = { fg = c.fg },
    WhichKeySeparator = { fg = c.fg_comment },
    WhichKeyFloat = { bg = bg_float },
    WhichKeyBorder = { fg = c.border, bg = bg_float },
    WhichKeyIcon = { fg = c.purple },
    WhichKeyIconAzure = { fg = c.blue },

    -- ── noice ───────────────────────────────────────────────────────────
    NoiceCmdline = { fg = c.fg },
    NoiceCmdlineIcon = { fg = c.indigo },
    NoiceCmdlinePopup = { fg = c.fg, bg = bg_float },
    NoiceCmdlinePopupBorder = { fg = c.border },
    NoiceCmdlinePopupTitle = { fg = c.indigo },
    NoiceConfirmBorder = { fg = c.border },
    NoiceMini = { fg = c.fg_muted },

    -- ── bufferline ──────────────────────────────────────────────────────
    BufferLineFill = { bg = c.bg_dark },
    BufferLineBackground = { fg = c.fg_comment, bg = c.bg_dark },
    BufferLineBufferSelected = { fg = c.fg, bg = c.bg, bold = true },
    BufferLineBufferVisible = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineIndicatorSelected = { fg = c.indigo, bg = c.bg },
    BufferLineSeparator = { fg = c.bg_deepest, bg = c.bg_dark },
    BufferLineModified = { fg = c.yellow, bg = c.bg_dark },
    BufferLineModifiedSelected = { fg = c.yellow, bg = c.bg },

    -- ── trouble ─────────────────────────────────────────────────────────
    TroubleNormal = { fg = c.fg, bg = bg_float },
    TroubleText = { fg = c.fg_muted },
    TroubleCount = { fg = c.purple, bg = c.bg_visual },
    TroubleIndent = { fg = c.border },

    -- ── todo-comments ───────────────────────────────────────────────────
    TodoBgFIX = { fg = c.bg, bg = c.red, bold = true },
    TodoBgTODO = { fg = c.bg, bg = c.blue, bold = true },
    TodoBgHACK = { fg = c.bg, bg = c.yellow, bold = true },
    TodoBgWARN = { fg = c.bg, bg = c.yellow, bold = true },
    TodoBgPERF = { fg = c.bg, bg = c.purple, bold = true },
    TodoBgNOTE = { fg = c.bg, bg = c.teal, bold = true },
    TodoBgTEST = { fg = c.bg, bg = c.purple, bold = true },
    TodoFgFIX = { fg = c.red },
    TodoFgTODO = { fg = c.blue },
    TodoFgHACK = { fg = c.yellow },
    TodoFgWARN = { fg = c.yellow },
    TodoFgPERF = { fg = c.purple },
    TodoFgNOTE = { fg = c.teal },
    TodoFgTEST = { fg = c.purple },

    -- ── flash ───────────────────────────────────────────────────────────
    FlashBackdrop = { fg = c.fg_comment },
    FlashLabel = { fg = c.bg, bg = c.indigo, bold = true },
    FlashMatch = { fg = c.fg, bg = c.bg_search },
    FlashCurrent = { fg = c.bg, bg = c.yellow },

    -- ── blink.cmp / nvim-cmp ────────────────────────────────────────────
    BlinkCmpMenu = { fg = c.fg_muted, bg = bg_float },
    BlinkCmpMenuBorder = { fg = c.border, bg = bg_float },
    BlinkCmpMenuSelection = { bg = c.bg_visual },
    BlinkCmpLabel = { fg = c.fg_muted },
    BlinkCmpLabelMatch = { fg = c.indigo, bold = true },
    BlinkCmpKind = { fg = c.purple },
    BlinkCmpDoc = { fg = c.fg, bg = bg_float },
    BlinkCmpDocBorder = { fg = c.border, bg = bg_float },
    CmpItemAbbr = { fg = c.fg_muted },
    CmpItemAbbrMatch = { fg = c.indigo, bold = true },
    CmpItemAbbrDeprecated = { fg = c.fg_comment, strikethrough = true },
    CmpItemKind = { fg = c.purple },
    CmpItemMenu = { fg = c.fg_comment },

    -- ── mini.hipatterns / mini.* ────────────────────────────────────────
    MiniHipatternsFixme = { fg = c.bg, bg = c.red, bold = true },
    MiniHipatternsHack = { fg = c.bg, bg = c.yellow, bold = true },
    MiniHipatternsTodo = { fg = c.bg, bg = c.blue, bold = true },
    MiniHipatternsNote = { fg = c.bg, bg = c.teal, bold = true },
    MiniIndentscopeSymbol = { fg = c.fg_comment },

    -- ── yanky ───────────────────────────────────────────────────────────
    YankyPut = { bg = c.bg_search },
    YankyYanked = { bg = c.bg_visual },

    -- ── copilot ─────────────────────────────────────────────────────────
    CopilotSuggestion = { fg = c.fg_comment, italic = true },
    CopilotAnnotation = { fg = c.fg_comment },

    -- ── treewalker ──────────────────────────────────────────────────────
    TreewalkerHighlight = { bg = c.bg_visual },

    -- ── terminal-adjacent ───────────────────────────────────────────────
    Added = { fg = c.green },
    Changed = { fg = c.yellow },
    Removed = { fg = c.red },
    healthSuccess = { fg = c.green },
    healthWarning = { fg = c.yellow },
    healthError = { fg = c.red },
  }

  return hl
end

--- Neovim's :terminal palette, mirroring .config/ghostty/themes/linear-dark
--- so a shell inside nvim matches the shell outside it.
---@param c table palette
function M.terminal(c)
  vim.g.terminal_color_0 = c.bg_deepest
  vim.g.terminal_color_1 = c.red
  vim.g.terminal_color_2 = c.green
  vim.g.terminal_color_3 = c.yellow
  vim.g.terminal_color_4 = c.blue
  vim.g.terminal_color_5 = c.purple
  vim.g.terminal_color_6 = c.teal
  vim.g.terminal_color_7 = c.fg_dim
  vim.g.terminal_color_8 = c.fg_comment
  vim.g.terminal_color_9 = c.red_bright
  vim.g.terminal_color_10 = c.teal
  vim.g.terminal_color_11 = c.yellow_bright
  vim.g.terminal_color_12 = c.indigo
  vim.g.terminal_color_13 = c.purple_bright
  vim.g.terminal_color_14 = c.teal_bright
  vim.g.terminal_color_15 = c.fg_bright
end

return M
