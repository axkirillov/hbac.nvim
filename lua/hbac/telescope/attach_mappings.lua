local action_state = require("telescope.actions.state")

local config = require("hbac.config")
local state = require("hbac.state")
local actions = require("hbac.command.actions")
local make_finder = require("hbac.telescope.make_finder")

local M = {}

local function execute_telescope_action(prompt_bufnr, action)
	local finder, finder_opts = make_finder.make_finder, make_finder.finder_opts
	local picker = action_state.get_current_picker(prompt_bufnr)
	local multi_selection = picker:get_multi_selection()

	if next(multi_selection) then
		for _, entry in ipairs(multi_selection) do
			action(entry.value)
		end
	else
		local single_selection = action_state.get_selected_entry()
		action(single_selection.value)
	end

	local row = picker:get_selection_row()
	picker:register_completion_callback(function()
		picker:set_selection(row)
	end)
	picker:refresh(finder(finder_opts), { reset_prompt = false })
end

local function hbac_toggle_selections(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, state.toggle_pin)
end
local function hbac_pin_all(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, actions.pin_all)
end
local function hbac_unpin_all(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, actions.unpin_all)
end
local function hbac_close_unpinned(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, actions.close_unpinned)
end
local function hbac_delete_buffer(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, config.values.close_command)
end

M.attach_mappings = function(_, map)
	local hbac_telescope_actions = {
		close_unpinned = hbac_close_unpinned,
		delete_buffer = hbac_delete_buffer,
		pin_all = hbac_pin_all,
		unpin_all = hbac_unpin_all,
		toggle_selections = hbac_toggle_selections,
	}

	for mode, hbac_cmds in pairs(config.values.telescope.mappings) do
		for hbac_cmd, key in pairs(hbac_cmds) do
			map(mode, key, hbac_telescope_actions[hbac_cmd])
		end
	end

	return true
end

return M
