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

M.telescope = function()
	vim.notify('This command has been removed. Check the docs for a migration guide.', vim.log.levels.WARN, notify_opts)
end

return M
