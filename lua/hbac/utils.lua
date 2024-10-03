local state = require("hbac.state")
local config = require("hbac.config")

local M = {}

M.get_listed_buffers = function()
	return vim.tbl_filter(function(bufnr)
		return vim.api.nvim_buf_get_option(bufnr, "buflisted")
	end, vim.api.nvim_list_bufs())
end

M.buf_autoclosable = function(bufnr)
	local current_buf = vim.api.nvim_get_current_buf()
	if state.is_pinned(bufnr) or bufnr == current_buf then
		return false
	end
	local buffer_windows = vim.fn.win_findbuf(bufnr)
	if #buffer_windows > 0 and not config.values.close_buffers_with_windows then
		return false
	end
	return true
end

M.get_pins = function()
	local pin_string = vim.g.Hbac_pinned_buffers or ""
	if string.len(pin_string) == 0 then
		return {}
	end
	local t = {}
	for entry in string.gmatch(pin_string, "[^,]+") do
		table.insert(t, tonumber(entry))
	end
	return t
end

M.set_pins = function(pins)
	vim.g.Hbac_pinned_buffers = table.concat(pins, ",")
end


return M
