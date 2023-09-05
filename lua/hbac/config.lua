local actions = require("hbac.telescope.actions")

local M = {}

local action_mappings = {
	["<M-c>"] = actions.close_unpinned,
	["<M-x>"] = actions.delete_buffer,
	["<M-a>"] = actions.pin_all,
	["<M-u>"] = actions.unpin_all,
	["<M-y>"] = actions.toggle_pin,
}

local defaults = {
	autoclose = true,
	threshold = 10,
	close_buffers_with_windows = false,
	close_command = function(bufnr) vim.api.nvim_buf_delete(bufnr, {}) end,
	telescope = {
		sort_mru = true,
		sort_lastused = true,
		selection_strategy = "row",
		mappings = {
			n = action_mappings,
			i = action_mappings,
		},
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
