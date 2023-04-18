local command = require("hbac.command")

return {
	setup = require("hbac.setup").setup,
	cmd = command.vim_cmd_func,
	close_unpinned = command.subcommands.close_unpinned,
	toggle_pin = command.subcommands.toggle_pin
}
