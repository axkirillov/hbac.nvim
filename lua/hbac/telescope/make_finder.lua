local finders = require("telescope.finders")

local M = {}

M.make_finder = function()
	local make_display = require("hbac.telescope.make_display")
	local utils = require("hbac.utils")

	local display = make_display.display

	local function get_entries()
		local entries = {}
		local buflist = utils.get_buffers()
		for _, bufnr in ipairs(buflist) do
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			table.insert(entries, {
				display = display,
				value = bufnr,
				ordinal = bufname,
			})
		end
		return entries
	end

	return finders.new_table({
		results = get_entries(),
		entry_maker = function(entry)
			return {
				value = entry.value,
				display = entry.display,
				ordinal = entry.ordinal,
				path = entry.ordinal,
			}
		end,
	})
end

return M
