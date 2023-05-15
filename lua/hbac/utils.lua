M = {}

M.get_buffers = function()
	return vim.tbl_filter(function(bufnr)
		local name = vim.api.nvim_buf_get_name(bufnr)
		local listed = vim.api.nvim_buf_get_option(bufnr, "buflisted")
		if name ~= "" and listed then
			return true
		end
		return false
	end, vim.api.nvim_list_bufs())
end

return M
