local missing = ""
for _, dependency in ipairs({ "plenary", "telescope" }) do
	if not pcall(require, dependency) then
		missing = missing .. "\n- " .. dependency .. ".nvim"
	end
end

if missing ~= "" then
	local msg = "Missing dependencies:" .. missing
	vim.notify(msg, vim.log.levels.ERROR, { title = "Hbac" })
	return false
end

local pickers = require("telescope.pickers")
local telescope_conf = require("telescope.config").values

local M = {}

local attach_mappings = function(opts)
	return function(_, map)
		local telescope_mappings = require("hbac.config").values.telescope.mappings
		telescope_mappings = vim.tbl_deep_extend("force", telescope_mappings, opts.mappings or {})
		for mode, hbac_telescope_mappings in pairs(telescope_mappings) do
			for key, action in pairs(hbac_telescope_mappings) do
				map(mode, key, action)
			end
		end
		return true
	end
end

M.pin_picker = function(opts)
	local make_finder = require("hbac.telescope.make_finder")
	opts = opts or {}
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
