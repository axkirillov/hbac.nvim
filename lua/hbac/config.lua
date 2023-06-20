local M = {}

local defaults = {
	autoclose = true,
	threshold = 10,
	close_buffers_with_windows = false,
	close_command = function(bufnr)
		vim.api.nvim_buf_delete(bufnr, {})
	end,
	telescope = {
		mappings = {
			n = {
				close_unpinned = "<M-c>",
				delete_buffer = "<M-x>",
				pin_all = "<M-a>",
				unpin_all = "<M-u>",
				toggle_selections = "<M-y>",
			},
			i = {
				close_unpinned = "<M-c>",
				delete_buffer = "<M-x>",
				pin_all = "<M-a>",
				unpin_all = "<M-u>",
				toggle_selections = "<M-y>",
			},
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
