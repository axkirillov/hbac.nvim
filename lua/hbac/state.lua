local M = {
	pinned_buffers = {},
	autoclose_enabled = false,
}

M.toggle_pin = function(bufnr)
	M.pinned_buffers[bufnr] = not M.pinned_buffers[bufnr]
	return M.pinned_buffers[bufnr]
end

M.is_pinned = function(bufnr)
	return M.pinned_buffers[bufnr] == true
end

return M
