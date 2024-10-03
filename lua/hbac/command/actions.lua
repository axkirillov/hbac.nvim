local state = require("hbac.state")

local M = {}

M.close_unpinned = function()
	local config = require("hbac.config")
	local utils = require("hbac.utils")
	local buflist = utils.get_listed_buffers()
	for _, bufnr in ipairs(buflist) do
		if utils.buf_autoclosable(bufnr) then
			config.values.close_command(bufnr)
		end
	end
end

M.toggle_pin = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local pinned_state = state.toggle_pin(bufnr) and "pinned" or "unpinned"

	vim.api.nvim_exec_autocmds("User",
		{ pattern = "HBACPinned", data = { bufnr = bufnr, state = pinned_state } })
	return bufnr, pinned_state
end

M.set_all = function(pinned)
	local utils = require("hbac.utils")
	local buflist = utils.get_listed_buffers()
	for _, bufnr in ipairs(buflist) do
		state.set_pin(bufnr, pinned)
	end
end

M.pin_all = function()
	M.set_all(true)
end

M.unpin_all = function()
	M.set_all(false)
end

M.toggle_autoclose = function()
	local autocommands = require("hbac.autocommands")
	state.autoclose_enabled = not state.autoclose_enabled
	if state.autoclose_enabled then
		autocommands.autoclose.setup()
		return state.autoclose_enabled
	end
	autocommands.autoclose.disable()
	return state.autoclose_enabled
end

return M
