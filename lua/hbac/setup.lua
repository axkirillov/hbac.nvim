local command = require("hbac.command")
local state = require("hbac.state")

local M = {
	CONSTANTS = {
		AUGROUP_AUTO_CLOSE = "hbac_autoclose",
	},
	opts = {
		threshold = 10,
		autoclose = true,
	},
}

local id = vim.api.nvim_create_augroup("hbac", {
	clear = false,
})

M.setup_autoclose = function()
	state.autoclose_enabled = true
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = vim.api.nvim_create_augroup(M.CONSTANTS.AUGROUP_AUTO_CLOSE, { clear = true }),
		pattern = { "*" },
		callback = function()
			local current_buf = vim.api.nvim_get_current_buf()
			local buftype = vim.api.nvim_buf_get_option(current_buf, "buftype")
			-- if the buffer is not a file - do nothing
			if buftype ~= "" then
				return
			end

			local buffers = vim.tbl_filter(function(buf)
				local name = vim.api.nvim_buf_get_name(buf)
				local listed = vim.api.nvim_buf_get_option(buf, "buflisted")
				local windows_with_buf = vim.fn.win_findbuf(buf)
				if name ~= "" and listed and #windows_with_buf == 0 then
					return true
				end
				return false
			end, vim.api.nvim_list_bufs())
			local num_buffers = #buffers
			if num_buffers <= M.opts.threshold then
				return
			end

			local buffers_to_close = num_buffers - M.opts.threshold

			-- Buffer sorted by current > pinned > others (by bufnr)
			table.sort(buffers, function(a, b)
				if a == current_buf or state.is_pinned(a) then
					return false
				end
				if b == current_buf or state.is_pinned(b) then
					return true
				end
				return a < b
			end)

			for i = 1, buffers_to_close, 1 do
				local buffer = buffers[i]
				if not state.is_pinned(buffer) and buffer ~= current_buf then
					vim.api.nvim_buf_delete(buffer, {})
				else -- We've reached the pinned buffers/current buffer
					break
				end
			end
		end,
	})
end

M.setup = function(opts)
	M.opts = vim.tbl_extend("force", M.opts, opts or {})
	opts = M.opts
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

	if not opts.autoclose then
		return
	end

	M.setup_autoclose()
end

return M
