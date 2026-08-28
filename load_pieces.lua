local function load_pieces()
    local output = {}
    for p in string.gmatch("BKNPQR", ".") do
        for c in string.gmatch("bw", '.') do
            local file_name = 'icons/' .. c..p..'.png'
            local name = c..p
            output[name] = love.graphics.newImage(file_name)
        end
    end
    return output
end

return load_pieces()