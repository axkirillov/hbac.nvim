local state = require("hbac.state")

local M = {
	opts = {
		threshold = 10,
		autoclose = true,
		close_buffers_with_windows = false,
		close_command = function(bufnr)
			vim.api.nvim_buf_delete(bufnr, {})
		end,
	},
}

local id = vim.api.nvim_create_augroup("hbac", {
	clear = false,
})

M.setup = function(user_opts)
	local command = require("hbac.command")
	M.opts = vim.tbl_extend("force", M.opts, user_opts or {})

	vim.api.nvim_create_autocmd({ "BufRead" }, {
		group = id,
		pattern = { "*" },
		callback = function()
			vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
				buffer = 0,
				once = true,
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					if state.is_pinned(bufnr) then
						return
					end
					state.toggle_pin(bufnr)
				end,
			})
		end,
	})

	vim.api.nvim_create_user_command(command.vim_cmd_name, function(args)
		command.vim_cmd_func(args.args)
	end, command.vim_cmd_opts)

	if M.opts.autoclose then
		require("hbac.autocommands").autoclose.setup()
	end
end

return M
