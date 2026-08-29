local Piece = Object:extend()

---comment
---@param color string
---@param type string
function Piece:new(color, type)
    -- 检查类型合不合法
    local names = "KQRBNP"
    local s, _ = names:find(type)
    if s == nil then
        error("棋子名字错了，要在 KQRBNP 才合法")
    end

    if color:sub(1, 1) == 'w' then
        self.color = 'w'
    elseif color:sub(1, 1) == 'b' then
        self.color = 'b'
    else
        error("Piece 的 Color 只能是 white/w 或 black/b")
    end
    
    self.type = type
    self.has_moves = false -- 记录棋子有没有移动过（ 王车易位，过路兵 ）
end

---@return string
function Piece:name()
    return self.color .. self.type
end

return Piece