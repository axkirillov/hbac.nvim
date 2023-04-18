local command = require("hbac.command")
local state   = require("hbac.state")

local M = {}

local id = vim.api.nvim_create_augroup("hbac", {
	clear = false
})

M.setup = function(opts)
	opts = opts or {
		autoclose = true,
		threshold = 10
	}

	vim.api.nvim_create_autocmd({ "BufRead" }, {
		group = id,
		pattern = { "*" },
		callback = function()
			vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
				buffer = 0,
				once = true,
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					state.toggle_pin(bufnr)
				end
			})
		end
	})

	vim.api.nvim_create_user_command(
		command.vim_cmd_name,
		function(args)
			command.vim_cmd_func(args.args)
		end,
		command.vim_cmd_opts
	)

	if not opts.autoclose then
		return
	end

	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = id,
		pattern = { "*" },
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
			-- if the buffer is not a file - do nothing
			if buftype ~= "" then
				return
			end

			local min = 2 ^ 1023
			local buffers = vim.api.nvim_list_bufs()
			local num_buffers = 0
			for _, buf in ipairs(buffers) do
				local name = vim.api.nvim_buf_get_name(buf)
				local listed = vim.api.nvim_buf_get_option(buf, 'buflisted')
				if name ~= "" and listed then
					num_buffers = num_buffers + 1
					if not state.is_pinned(buf) then
						min = math.min(min, buf)
					end
				end
			end

			if num_buffers <= opts.threshold then
				return
			end

			if min == bufnr then
				return
			end

			if min >= 2 ^ 1023 then
				return
			end

			vim.api.nvim_buf_delete(min, {})
		end
	})

end

return M
