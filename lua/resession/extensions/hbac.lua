local utils = require("hbac.utils")

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
	for _, v in ipairs(utils.get_pins()) do
		if vim.api.nvim_buf_is_valid(v) then
			pinned_buffers[#pinned_buffers + 1] = vim.api.nvim_buf_get_name(v)
		end
	end
	return vim.json.encode(pinned_buffers)
end

local function set_pinned_buffers(pinned_buffers)
	local cache = {}
	for _, v in pairs(vim.json.decode(pinned_buffers)) do
		for _, buf in pairs(get_buffer_ids(v)) do
			table.insert(cache, tonumber(buf))
		end
	end
	utils.set_pins(cache)
end

M.on_save = function()
	return { pinned_buffers = get_pinned_buffers() }
end

M.on_post_load = function(data)
	set_pinned_buffers(data.pinned_buffers)
end

return M
