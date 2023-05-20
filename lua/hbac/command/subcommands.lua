local autocommands = require("hbac.autocommands")
local hbac_config = require("hbac.setup").opts
local state = require("hbac.state")
local utils = require("hbac.utils")

local M = {
	toggle_all_value = true,
}

M.close_unpinned = function()
	local buflist = utils.get_listed_buffers()
	for _, bufnr in ipairs(buflist) do
		if utils.buf_autoclosable(bufnr) then
			hbac_config.close_command(bufnr)
		end
	end
end

M.toggle_pin = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local pinned_state = state.toggle_pin(bufnr) and "pinned" or "unpinned"
	return bufnr, pinned_state
end

M.toggle_all = function()
	local buflist = utils.get_listed_buffers()
	for _, bufnr in ipairs(buflist) do
		state.pinned_buffers[bufnr] = M.toggle_all_value
	end
	M.toggle_all_value = not M.toggle_all_value
	return M.toggle_all_value
end

M.toggle_autoclose = function()
	state.autoclose_enabled = not state.autoclose_enabled
	if state.autoclose_enabled then
		autocommands.autoclose.setup()
		return state.autoclose_enabled
	end
	autocommands.autoclose.disable()
	return state.autoclose_enabled
end

return M
