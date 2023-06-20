local subcommands = require("hbac.command.subcommands")
local config = require("hbac.command.config")

local M = {
	subcommands = subcommands,
}

M.vim_cmd_func = function(arg)
	if subcommands[arg] then
		subcommands[arg]()
	else
		vim.notify("Unknown command: " .. arg, vim.log.levels.WARN, config.notify_opts)
	end
end


M.create_user_command = function()
	local opts = {
		nargs = 1,
		complete = function()
			return { unpack(vim.tbl_keys(subcommands)) }
		end,
	}

	vim.api.nvim_create_user_command("Hbac", function(args)
		M.vim_cmd_func(args.args)
	end, opts)
end

return M
