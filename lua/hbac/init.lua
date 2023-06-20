local command = require("hbac.command")
local setup = require("hbac.setup")

return {
	setup = setup.setup,
	cmd = command.vim_cmd_func,
	close_unpinned = command.subcommands.close_unpinned,
	telescope = command.subcommands.telescope,
	pin_all = command.subcommands.pin_all,
	unpin_all = command.subcommands.unpin_all,
	toggle_autoclose = command.subcommands.toggle_autoclose,
	toggle_pin = command.subcommands.toggle_pin,
}
