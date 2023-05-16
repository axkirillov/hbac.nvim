local subcommands = require("hbac.command.subcommands")

local notify_opts = { title = "Hbac" }

local M = {
	subcommands = {},
}

M.subcommands.close_unpinned = function()
	subcommands.close_unpinned()
	vim.notify("Closed unpinned buffers", "info", notify_opts)
end

M.subcommands.toggle_pin = function()
	local bufnr, pinned_state = subcommands.toggle_pin()
	vim.notify(bufnr .. " " .. pinned_state, "info", notify_opts)
end

M.subcommands.toggle_all = function()
	local toggle_all_value = subcommands.toggle_all() and "pinned" or "unpinned"
	vim.notify(toggle_all_value .. " all buffers", "info", notify_opts)
end

M.subcommands.toggle_autoclose = function()
	local autoclose_state = subcommands.toggle_autoclose() and "enabled" or "disabled"
	vim.notify("Autoclose " .. autoclose_state, "info", notify_opts)
end

M.subcommands.telescope = function(opts)
	local hbac_telescope = require("hbac.telescope")
	if not hbac_telescope then
		return
	end
	hbac_telescope.pin_picker(opts)
end

M.vim_cmd_name = "Hbac"

M.vim_cmd_func = function(arg)
	if M.subcommands[arg] then
		M.subcommands[arg]()
	else
		vim.notify("Unknown command: " .. arg, "warn", notify_opts)
	end
end

M.vim_cmd_opts = {
	nargs = 1,
	complete = function()
		return { unpack(vim.tbl_keys(M.subcommands)) }
	end,
}

return M
