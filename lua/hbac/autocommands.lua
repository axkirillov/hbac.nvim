local M = {}

local state = require("hbac.state")

local CONSTANTS = {
	AUGROUP_AUTO_CLOSE = "hbac_autoclose",
}

M.autoclose = {}

M.autoclose.setup = function()
	local config = require("hbac.setup").opts

	state.autoclose_enabled = true
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = vim.api.nvim_create_augroup(CONSTANTS.AUGROUP_AUTO_CLOSE, { clear = true }),
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
				if name ~= "" and listed then
					return true
				end
				return false
			end, vim.api.nvim_list_bufs())
			local num_buffers = #buffers
			if num_buffers <= config.threshold then
				return
			end

			local buffers_to_close = num_buffers - config.threshold

			-- Buffer sorted by current > pinned > is_in_window > others (by bufnr)
			table.sort(buffers, function(a, b)
				if a == current_buf or b == current_buf then
					return b == current_buf
				end
				if state.is_pinned(a) ~= state.is_pinned(b) then
					return state.is_pinned(b)
				end

				local a_windowed = #(vim.fn.win_findbuf(a)) > 0
				local b_windowed = #(vim.fn.win_findbuf(b)) > 0
				if a_windowed ~= b_windowed then
					return b_windowed
				end
				return a < b
			end)

			for i = 1, buffers_to_close, 1 do
				local buffer = buffers[i]
				local buffer_windows = vim.fn.win_findbuf(buffer)
				if state.is_pinned(buffer) or buffer == current_buf then
					break
				elseif #buffer_windows > 0 and not config.close_buffers_with_windows then
					break
				else
					config.close_command(buffer)
				end
			end
		end,
	})
end

M.autoclose.disable = function()
	-- pcall failure likely indicates that augroup doesn't exist - which is fine, since its
	-- autocmds is effectively disabled in that case
	pcall(function()
		vim.api.nvim_del_augroup_by_name(CONSTANTS.AUGROUP_AUTO_CLOSE)
	end)
end

return M
