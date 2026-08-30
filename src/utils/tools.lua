local tools = {}

--- 把 array 从 index 位置开始往后删完（包括 index 项本身）。 返回删完的 table
---@param target_array table
---@param index number
---@return table
function tools.remove_items_after_index(target_array, index)
    for i = #target_array, index, -1 do
        target_array[i] = nil
    end
    return target_array
end

return tools