local M = {
	pinned_buffers = {},
	autoclose_enabled = false,
}

M.toggle_pin = function(bufnr)
	if M.pinned_buffers[bufnr] == true then
		M.pinned_buffers[bufnr] = false
		return "unpinned"
	end

	M.pinned_buffers[bufnr] = true
	return "pinned"
end

M.is_pinned = function(bufnr)
	return M.pinned_buffers[bufnr] == true
end

return M
