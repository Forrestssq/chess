local function load_pieces()
    ---@type table<string, love.Image>
    local output = {}
    for c in string.gmatch("bw", '.') do
        for p in string.gmatch("BKNPQR", ".") do
            local file_name = 'assets/icons/' .. c .. p .. '.png'
            local name = c..p
            output[name] = love.graphics.newImage(file_name)
        end
    end
    return output
end

return load_pieces()