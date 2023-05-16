local hbac_config = require("hbac.setup").opts
local state = require("hbac.state")

local entry_display = require("telescope.pickers.entry_display")
local has_devicons, devicons = pcall(require, "nvim-web-devicons")
local Path = require("plenary.path")

local cwd = vim.loop.cwd()
local os_home = vim.loop.os_homedir()

local M = {}

M.display = function(entry)
	local bufnr, bufname = entry.value, entry.ordinal

	local function get_pin_icon()
		local pin_icons = hbac_config.telescope.pin_icons
		local is_pinned = state.is_pinned(bufnr)
		local pin_icon = is_pinned and pin_icons[1] or pin_icons[2]
		local pin_icon_hl = is_pinned and pin_icons[3] or pin_icons[4]
		return pin_icon, pin_icon_hl
	end

	local function get_devicon()
		if not has_devicons then
			return "", ""
		end
		return devicons.get_icon(bufname, string.match(bufname, "%a+$"), { default = true })
	end

	local function get_display_text()
		local function format_filepath()
			local path = vim.fn.fnamemodify(bufname, ":p:h")
			if cwd and vim.startswith(path, cwd) then
				path = string.sub(path, #cwd + 2)
			elseif os_home and vim.startswith(path, os_home) then
				path = "~/" .. Path:new(path):make_relative(os_home)
			end
			return path
		end

		local bufpath = format_filepath()
		local display_filename = vim.fn.fnamemodify(bufname, ":t")
		if bufpath == "" then
			return display_filename
		end
		return display_filename .. " (" .. bufpath .. ")"
	end

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 2 },
			{ width = 2 },
			{ remaining = true },
		},
	})

	return displayer({
		{ get_pin_icon() },
		{ get_devicon() },
		get_display_text(),
	})
end

return M
