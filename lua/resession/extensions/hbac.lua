local hbac_state = require("hbac.state")

local M = {}

local function get_buffer_ids(buf_name)
	local buf_ids = {}
	local buf_nums = vim.api.nvim_list_bufs()
	for _, buf_num in pairs(buf_nums) do
		if buf_name ~= "" and buf_name == vim.api.nvim_buf_get_name(buf_num) then
			buf_ids[#buf_ids + 1] = buf_num
		end
	end
	return buf_ids
end

local function get_pinned_buffers()
	local pinned_buffers = {}
	for k, v in pairs(hbac_state.pinned_buffers) do
		if v == true then
			if vim.api.nvim_buf_is_valid(k) then
				pinned_buffers[#pinned_buffers + 1] = vim.api.nvim_buf_get_name(k)
			end
		end
	end
	return vim.json.encode(pinned_buffers)
end

local function set_pinned_buffers(pinned_buffers)
	local cache = {}
	for _, v in pairs(vim.json.decode(pinned_buffers)) do
		for _, buf in pairs(get_buffer_ids(v)) do
			cache[buf] = true
		end
	end
	hbac_state.pinned_buffers = cache
end

M.on_save = function()
	return { pinned_buffers = get_pinned_buffers() }
end

M.on_post_load = function(data)
	set_pinned_buffers(data.pinned_buffers)
end

return M
