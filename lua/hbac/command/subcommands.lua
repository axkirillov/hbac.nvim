local actions = require("hbac.command.actions")
local notify_opts = require("hbac.command.config").notify_opts

local M = {}

M.close_unpinned = function()
	actions.close_unpinned()
	vim.notify("Closed unpinned buffers", vim.log.levels.INFO, notify_opts)
end

M.toggle_pin = function()
	local bufnr, pinned_state = actions.toggle_pin()
	vim.notify(bufnr .. " " .. pinned_state, vim.log.levels.INFO, notify_opts)
end

M.pin_all = function()
	actions.pin_all()
	vim.notify("Pinned all buffers", vim.log.levels.INFO, notify_opts)
end

M.unpin_all = function()
	actions.unpin_all()
	vim.notify("Unpinned all buffers", vim.log.levels.INFO, notify_opts)
end

M.toggle_autoclose = function()
	local autoclose_state = actions.toggle_autoclose() and "enabled" or "disabled"
	vim.notify("Autoclose " .. autoclose_state, vim.log.levels.INFO, notify_opts)
end

M.telescope = function(opts)
	local hbac_telescope = require("hbac.telescope")
	if not hbac_telescope then
		return
	end
	local telescope_opts = require("hbac.config").values.telescope
	opts = vim.tbl_deep_extend("force", telescope_opts, opts or {})
	hbac_telescope.pin_picker(opts)
end

return M
