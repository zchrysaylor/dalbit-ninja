---@class NineSlice
---@field img love.Image
---@field borders { l: number, r: number, t: number, b: number }
---@field midW number
---@field midH number
---@field quads table<string, love.Quad>
local nineSlice = {}
nineSlice.__index = nineSlice

---Draw the nine-slice at the requested size.
---Sizes smaller than the border footprint are clamped so corners never overlap.
---@param x number Top-left X position in pixels
---@param y number Top-left Y position in pixels
---@param w number Requested width in pixels
---@param h number Requested height in pixels
---@return nil
function nineSlice:draw(x, y, w, h)
    local b = self.borders
    local img = self.img
    local q = self.quads

    w = math.max(w, b.l + b.r)
    h = math.max(h, b.t + b.b)

    local innerW = w - b.l - b.r
    local innerH = h - b.t - b.b
    local sx = innerW / self.midW -- horizontal stretch for middle slices
    local sy = innerH / self.midH -- vertical stretch for middle slices

    local d = love.graphics.draw

    -- Corners (no scaling)
    d(img, q.tl, x, y)
    d(img, q.tr, x + b.l + innerW, y)
    d(img, q.bl, x, y + b.t + innerH)
    d(img, q.br, x + b.l + innerW, y + b.t + innerH)

    -- Edges (stretch one axis)
    d(img, q.tm, x + b.l, y, 0, sx, 1)
    d(img, q.bm, x + b.l, y + b.t + innerH, 0, sx, 1)
    d(img, q.ml, x, y + b.t, 0, 1, sy)
    d(img, q.mr, x + b.l + innerW, y + b.t, 0, 1, sy)

    -- Center (stretch both axes)
    d(img, q.mm, x + b.l, y + b.t, 0, sx, sy)
end

---Create a new nine-slice.
---@param img love.Image Source image containing the 3x3 slice layout
---@param left number Left border width in pixels
---@param right number Right border width in pixels
---@param top number Top border height in pixels
---@param bottom number Bottom border height in pixels
---@return NineSlice
function nineSlice.new(img, left, right, top, bottom)
    local self = setmetatable({}, nineSlice)

    local iw, ih = img:getDimensions()
    assert(left >= 0 and right >= 0 and top >= 0 and bottom >= 0)
    assert(left + right <= iw, "NineSlice borders exceed image width")
    assert(top + bottom <= ih, "NineSlice borders exceed image height")

    local midW = iw - left - right
    local midH = ih - top - bottom

    self.img = img
    self.midW, self.midH = midW, midH
    self.borders = { l = left, r = right, t = top, b = bottom }

    local q = love.graphics.newQuad
    self.quads = {
        tl = q(0, 0, left, top, iw, ih),
        tm = q(left, 0, midW, top, iw, ih),
        tr = q(left + midW, 0, right, top, iw, ih),
        ml = q(0, top, left, midH, iw, ih),
        mm = q(left, top, midW, midH, iw, ih),
        mr = q(left + midW, top, right, midH, iw, ih),
        bl = q(0, top + midH, left, bottom, iw, ih),
        bm = q(left, top + midH, midW, bottom, iw, ih),
        br = q(left + midW, top + midH, right, bottom, iw, ih),
    }

    return self
end

return nineSlice
