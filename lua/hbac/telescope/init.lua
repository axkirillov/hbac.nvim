local actions = require("hbac.telescope.actions")
local pickers = require("telescope.pickers")
local telescope_conf = require("telescope.config").values

local default_mappings = {
	["<M-c>"] = actions.close_unpinned,
	["<M-x>"] = actions.delete_buffer,
	["<M-a>"] = actions.pin_all,
	["<M-u>"] = actions.unpin_all,
	["<M-y>"] = actions.toggle_pin,
}

local M = {}

local attach_mappings = function(opts)
	return function(_, map)
		for mode, hbac_telescope_mappings in pairs(opts.mappings) do
			for key, action in pairs(hbac_telescope_mappings) do
				map(mode, key, action)
			end
		end
		return true
	end
end

local parse_opts = function(opts)
	local telescope_opts = require("hbac.config").values.telescope
	opts.mappings = telescope_opts.use_default_mappings
		and vim.tbl_deep_extend('force', { i = default_mappings, n = default_mappings }, telescope_opts.mappings or {})
		or (telescope_opts.mappings or {})
	return vim.tbl_deep_extend("force", telescope_opts, opts or {})
end

M.pin_picker = function(opts)
	local make_finder = require("hbac.telescope.make_finder")
	opts = parse_opts(opts or {})
	pickers.new(opts, {
		prompt_title = "Hbac Pin States",
		finder = make_finder.make_finder(opts),
		sorter = telescope_conf.generic_sorter(opts),
		attach_mappings = attach_mappings(opts),
		previewer = telescope_conf.file_previewer(opts),
		default_selection_index = make_finder.default_selection_idx,
	}):find()
end

return M
