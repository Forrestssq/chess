---@param start_w_or_b string
local function load_opening_board_status(start_w_or_b)
    local opening_board_status = {}    
    for i = 1, 8 do
        opening_board_status[i] = {}
        for j = 1, 8 do
            opening_board_status[i][j] = 0
        end
    end
    
    -- 自己是白方
    if start_w_or_b:sub(1, 1) == 'w' then
        print("---- 1 ----")
        -- 插入 Pawn
        for i = 1, 8 do
            local wP = Piece('w', 'P')
            opening_board_status[2][i] = wP
            
            local bP = Piece('b', 'P')
            opening_board_status[7][i] = bP
        end

        -- Rook
        local wR = Piece('w', 'R')
        opening_board_status[1][1] = wR
        opening_board_status[1][8] = wR
        local bR = Piece('b', 'R')
        opening_board_status[8][1] = bR
        opening_board_status[8][8] = bR

        -- Knight
        local wN = Piece('w', 'N')
        opening_board_status[1][2] = wN
        opening_board_status[1][7] = wN
        local bN = Piece('b', 'N')
        opening_board_status[8][2] = bN
        opening_board_status[8][7] = bN

        -- Biship
        local wB = Piece('w', 'B')
        opening_board_status[1][3] = wB
        opening_board_status[1][6] = wB
        local bB = Piece('b', 'B')
        opening_board_status[8][3] = wB
        opening_board_status[8][6] = wB

        -- Queen
        local wQ = Piece('w', 'Q')
        opening_board_status[1][4] = wQ
        local bQ = Piece('b', 'Q')
        opening_board_status[8][4] = bQ

        -- King
        local wK = Piece('w', 'K')
        opening_board_status[1][5] = wK
        local bK = Piece('b', 'K')
        opening_board_status[8][5] = bK
        
    -- 自己是黑方
    elseif start_w_or_b:sub(1, 1) == 'b' then
        
    else
        error("Piece 的 Color 只能是 white/w 或 black/b")
    end

    return opening_board_status
end

return load_opening_board_status