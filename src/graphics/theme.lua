-- Dedicated module for defining the UI theme elements.
---@alias ThemeColor [number, number, number, number]

---@class ThemePanels
---@field wood NineSlice
---@field woodInterior NineSlice

---@class ThemeFonts
---@field title love.Font
---@field body love.Font

---@class ThemeColors
---@field text ThemeColor
---@field meleeSwing ThemeColor

---@class theme
---@field panels ThemePanels
---@field fonts ThemeFonts
---@field colors ThemeColors
local theme = {}

---@type ThemePanels
theme.panels = {
    wood = NineSlice.new(GArt["panel-wood"], 6, 5, 6, 5),
    woodInterior = NineSlice.new(GArt["panel-wood-interior"], 5, 5, 5, 5),
}

---@type ThemeFonts
theme.fonts = {
    title = GFonts["ninjaMedium"],
    body = GFonts["ninjaSmall"],
}

---@type ThemeColors
theme.colors = {
    text = { 1, 1, 1, 1 },
    meleeSwing = { 1, 0.9, 0.6, 1 },
}

-- TODO: consider refactoring to factory `theme.new(art, fonts)` to reduce global coupling
-- and/or support multiple themes.
return theme
