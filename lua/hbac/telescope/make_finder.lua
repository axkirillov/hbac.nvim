local plenary = require("plenary")
local finders = require("telescope.finders")
local results_opts = require("hbac.telescope.results_opts")

local M = {
	default_selection_idx = 1,
	finder_opts = {},
}

local function get_entries(opts)

	local display = require("hbac.telescope.make_display").display
	local buflist = require("hbac.utils").get_listed_buffers()
	local filtered_bufnrs = {}
	filtered_bufnrs, M.default_selection_idx = results_opts.filter_bufnrs_by_opts(opts, buflist)

	local entries = {}
	for _, bufnr in ipairs(filtered_bufnrs) do
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		table.insert(entries, {
			filename = bufname,
			display = display,
			value = bufnr,
			ordinal = plenary.path:new(bufname):make_relative(),
		})
	end
	return entries
end

M.make_finder = function(opts)
	M.finder_opts = opts or {}
	return finders.new_table({
		results = get_entries(opts),
		entry_maker = function(entry)
			return {
				filename = entry.filename,
				value = entry.value,
				display = entry.display,
				ordinal = entry.ordinal,
				path = entry.filename,
			}
		end,
	})
end

return M
