local command = require("hbac.command")
local autocommands = require("hbac.autocommands")
local config = require("hbac.config")

local M = {
}

M.setup = function(user_opts)
	config.setup(user_opts)

	autocommands.autopin.setup()

	command.create_user_command()

	if config.values.autoclose then
		autocommands.autoclose.setup()
	end
end

return M
