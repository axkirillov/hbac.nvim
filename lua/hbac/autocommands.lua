local state = require("hbac.state")
local utils = require("hbac.utils")
local config = require("hbac.config")

local M = {
  autoclose = {
    name = "hbac_autoclose",
  },
  autopin = {
    name = "hbac_autopin",
  },
}

-- Track buffers that should be pinned via OptionSet
-- false = waiting for modified event, true = already pinned
local _optionset_buffers = {}
local _optionset_autocmd_id = nil

-- Setup global OptionSet autocmd (called once)
local function setup_optionset_autocmd()
  if _optionset_autocmd_id then
    return
  end

  _optionset_autocmd_id = vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("hbac_optionset", { clear = true }),
    pattern = "modified",
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      -- Only pin if this buffer is waiting for OptionSet and not already pinned
      if _optionset_buffers[bufnr] == false and not state.is_pinned(bufnr) then
        _optionset_buffers[bufnr] = true
        state.toggle_pin(bufnr)
      end
    end,
  })
end

local function debounce(func, timeout)
  local timer_id
  return function(...)
    local args = { ... }
    if timer_id then
      vim.fn.timer_stop(timer_id)
    end
    timer_id = vim.defer_fn(function()
      func(unpack(args))
    end, timeout)
  end
end

local function check_buffers()
  if vim.g.SessionLoad then
    debounce(check_buffers, 50)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(current_buf, "buftype")
  -- if the buffer is not a file - do nothing
  if buftype ~= "" then
    return
  end

  local buffers = vim.tbl_filter(function(buf)
    -- Filter out buffers that are not listed, and pinned buffers if count_pinned == false
    return vim.api.nvim_buf_get_option(buf, "buflisted") and (config.values.count_pinned or not state.is_pinned(buf))
  end, vim.api.nvim_list_bufs())

  local num_buffers = #buffers

  if num_buffers <= config.values.threshold then
    return
  end

  local buffers_to_close = num_buffers - config.values.threshold

  -- Buffer sorted by current > pinned > is_in_window > named > unnamed
  table.sort(buffers, function(a, b)
    if a == current_buf or b == current_buf then
      return b == current_buf
    end
    if state.is_pinned(a) ~= state.is_pinned(b) then
      return state.is_pinned(b)
    end

    local a_windowed = #(vim.fn.win_findbuf(a)) > 0
    local b_windowed = #(vim.fn.win_findbuf(b)) > 0
    if a_windowed ~= b_windowed then
      return b_windowed
    end

    local a_unnamed = vim.api.nvim_buf_get_name(a) == ""
    local b_unnamed = vim.api.nvim_buf_get_name(b) == ""
    if a_unnamed ~= b_unnamed then
      return a_unnamed
    end

    return a < b
  end)

  for i = 1, buffers_to_close, 1 do
    local buffer = buffers[i]
    if not utils.buf_autoclosable(buffer) then
      break
    else
      config.values.close_command(buffer)
    end
  end
end

M.autoclose.setup = function()
  state.autoclose_enabled = true
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = vim.api.nvim_create_augroup(M.autoclose.name, { clear = true }),
    pattern = { "*" },
    callback = function()
      check_buffers()
    end,
  })
end

M.autoclose.disable = function()
  -- pcall failure likely indicates that augroup doesn't exist - which is fine, since its
  -- autocmds is effectively disabled in that case
  pcall(function()
    vim.api.nvim_del_augroup_by_name(M.autoclose.name)
  end)
end

M.autopin.setup = function()
  if #config.values.autopin_events == 0 then
    return
  end
  state.autopin_enabled = true

  local id = vim.api.nvim_create_augroup(M.autopin.name, {
    clear = false,
  })

  vim.api.nvim_create_autocmd({ "BufRead" }, {
    group = id,
    pattern = { "*" },
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local pinned = false

      local function try_pin()
        if pinned or state.is_pinned(bufnr) then
          return
        end
        pinned = true
        state.toggle_pin(bufnr)
      end

      for _, event in ipairs(config.values.autopin_events) do
        -- Replace deprecated BufModifiedSet with OptionSet modified for Neovim 0.12+
        -- See: https://github.com/neovim/neovim/commit/443171328531e33a7caecda0b81dadd826518a58
        if event == "BufModifiedSet" and vim.fn.has("nvim-0.12") == 1 then
          -- Mark this buffer for autopin via OptionSet
          _optionset_buffers[bufnr] = false
          setup_optionset_autocmd()
        else
          vim.api.nvim_create_autocmd(event, {
            buffer = bufnr,
            once = true,
            callback = try_pin,
          })
        end
      end
    end,
  })
end

M.autopin.disable = function()
  -- pcall failure likely indicates that augroup doesn't exist - which is fine, since its
  -- autocmds is effectively disabled in that case
  pcall(function()
    vim.api.nvim_del_augroup_by_name(M.autopin.name)
  end)
end

return M
