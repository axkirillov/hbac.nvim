local M = {}

local defaults = {
	autoclose = true,
	threshold = 10,
	close_buffers_with_windows = false,
	close_command = function(bufnr) vim.api.nvim_buf_delete(bufnr, {}) end,
	telescope = {
		sort_mru = true,
		sort_lastused = true,
		selection_strategy = "row",
		use_default_mappings = true,
		mappings = nil,
		pin_icons = {
			pinned = { "󰐃 ", hl = "DiagnosticOk" },
			unpinned = { "󰤱 ", hl = "DiagnosticError" },
		},
	},
}

M.setup = function(user_config)
	M.values = vim.tbl_deep_extend("force", defaults, user_config or {})
end

return M
