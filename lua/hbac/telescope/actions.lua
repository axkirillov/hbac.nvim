local action_state = require("telescope.actions.state")
local hbac_actions = require("hbac.command.actions")
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

	picker:refresh(finder(finder_opts), { reset_prompt = false })
end

local function hbac_toggle_pin(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, hbac_actions.toggle_pin)
end
local function hbac_pin_all(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, hbac_actions.pin_all)
end
local function hbac_unpin_all(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, hbac_actions.unpin_all)
end
local function hbac_close_unpinned(prompt_bufnr)
	execute_telescope_action(prompt_bufnr, hbac_actions.close_unpinned)
end
local function hbac_delete_buffer(prompt_bufnr)
	local close_command = require("hbac.config").values.close_command
	execute_telescope_action(prompt_bufnr, close_command)
end


M.close_unpinned = hbac_close_unpinned
M.delete_buffer = hbac_delete_buffer
M.pin_all = hbac_pin_all
M.unpin_all = hbac_unpin_all
M.toggle_pin = hbac_toggle_pin

return M
