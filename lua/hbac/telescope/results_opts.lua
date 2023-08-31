-- NOTE: These are copied/modified from telescope.builtin.internal.buffers
local M = {}

local most_recent_bufs = function(bufnrs)
	local mru_bufs = {}
	for _, buf in ipairs(bufnrs) do
		table.insert(mru_bufs, buf)
	end
	table.sort(mru_bufs, function(a, b)
		return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
	end)
	return mru_bufs
end

M.filter_bufnrs_by_opts = function(opts, bufnrs)
	local mru_bufs = most_recent_bufs(bufnrs)
	bufnrs = vim.tbl_filter(function(b)
		local function buf_in_cwd(cwd)
			return string.find(vim.api.nvim_buf_get_name(b), cwd, 1, true)
		end
		if
			(opts.show_all_buffers == false and not vim.api.nvim_buf_is_loaded(b))
			or (opts.ignore_current_buffer and b == mru_bufs[1])
			or (opts.cwd_only and not buf_in_cwd(vim.loop.cwd()))
			or (not opts.cwd_only and opts.cwd and not buf_in_cwd(opts.cwd))
		then
			return false
		end
		return true
	end, bufnrs)

	if not next(bufnrs) then
		return {}
	end
	if opts.sort_mru then
		bufnrs = most_recent_bufs(bufnrs)
	end

	local default_selection_idx = 1
	if opts.sort_lastused then
		local active, alternate = mru_bufs[1], mru_bufs[2]
		local idx = 1
		for i, bufnr in ipairs(bufnrs) do
			if not opts.ignore_current_buffer and bufnr == active then
				default_selection_idx = 2
			end
			if bufnr == active or bufnr == alternate then
				idx = (opts.ignore_current_buffer or bufnrs[1] ~= active) and 1 or 2
				table.remove(bufnrs, i)
				table.insert(bufnrs, idx, bufnr)
			end
		end
	end

	return bufnrs, default_selection_idx
end

return M
