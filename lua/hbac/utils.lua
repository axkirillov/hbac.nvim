local state = require("hbac.state")
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
	local config = require("hbac.setup").opts
	if #buffer_windows > 0 and not config.close_buffers_with_windows then
		return false
	end
	return true
end

return M
