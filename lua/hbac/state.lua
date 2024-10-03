local M = {
	autoclose_enabled = false,
}

M.is_pinned = function(bufnr)
	local utils = require("hbac.utils")
	local pins = utils.get_pins()
	return vim.tbl_contains(pins, bufnr)
end

M.set_pin = function(bufnr, pinned)
	local utils = require("hbac.utils")
	local pins = utils.get_pins()
	if pinned and not M.is_pinned(bufnr) then
		table.insert(pins, bufnr)
		utils.set_pins(pins)
	elseif not pinned and M.is_pinned(bufnr) then
		local filtered_pins = vim.tbl_filter(function(pin) return pin ~= bufnr end, pins)
		utils.set_pins(filtered_pins)
	end
end

M.toggle_pin = function(bufnr)
	local value = M.is_pinned(bufnr)
	M.set_pin(bufnr, not value)
	return not value
end

return M
