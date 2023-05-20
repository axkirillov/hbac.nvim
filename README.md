# hbac.nvim
Heuristic buffer auto-close
# overview
Automagically close the unedited buffers in your bufferlist when it becomes too long. The "edited" buffers remain untouched. For a buffer to be considered edited it is enough to enter insert mode once or modify it in any way.

# description
You like using the buffer list, but you hate it when it has too many buffers, because you loose the overview for what files you are *actually* working on. Indeed, a lot of the times, when browsing code you want to look at some files, that you are not actively working on, like checking the definitions or going down the callstack when debugging. These files then pollute the bufferlist and make it harder to find ones you actually care about.
Reddit user **xmsxms** [posted](https://www.reddit.com/r/neovim/comments/12c4ad8/closing_unused_buffers/?utm_source=share&utm_medium=web2x&context=3) a script that marks all once edited files in a session as important and provides a keybinding to close all the rest. In fact, I used some of his code in this plugin, and you can achieve the same effect as his script using hbac.
The main feature of this plugin, however, is the automatic closing of buffers. If the number of buffers reaches a threshold (default is 10), the oldest unedited buffer will be closed once you open a new one.

# installation

with [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'axkirillov/hbac.nvim',
  requires = {
  -- these are optional, add them, if you want the telescope module
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons'
    }
}
```
with [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua	
{
  'axkirillov/hbac.nvim',
  dependencies = {
  -- these are optional, add them, if you want the telescope module
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons'
  },
  config = function ()
    require("hbac").setup()
  end
}
```

# configuration
```lua
require("hbac").setup({
  autoclose     = true, -- set autoclose to false if you want to close manually
  threshold     = 10, -- hbac will start closing unedited buffers once that number is reached
  close_command = function(bufnr)
    vim.api.nvim_buf_delete(bufnr, {})
  end,
  close_buffers_with_windows = false, -- hbac will close buffers with associated windows if this option is `true`
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
        -- as above
      },
    },
    -- Pinned/unpinned icons and their hl groups. Defaults to nerdfont icons
    pin_icons = {
      pinned = { "󰐃 ", hl = "DiagnosticOk" },
      unpinned = { "󰤱 ", hl = "DiagnosticError" },
    },
  },
})
```

# usage
Let hbac do its magick 😊

or

- `:Hbac toggle_pin` - toggle a pin of the current buffer to prevent it from being auto-closed
- `:Hbac close_unpinned` - close all unpinned buffers
- `:Hbac pin_all` - pin all buffers
- `:Hbac unpin_all` - unpin all buffers
- `:Hbac toggle_autoclose` - toggle autoclose behavior
- `:Hbac telescope` - open the telescope picker

or, if you prefer to use lua:
```lua
local hbac = require("hbac")
hbac.toggle_pin()
hbac.close_unpinned()
hbac.pin_all()
hbac.unpin_all()
hbac.toggle_autoclose()
hbac.telescope()
```

## Telescope integration

The plugin provides a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) integration to view and manage the pin states of buffers. This requires telescope and its dependency [plenary.nvim](https://github.com/nvim-lua/plenary.nvim). [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) is also recommended.

The picker provides the following actions:

- `hbac_toggle_selections` - toggle the pin state of the selected buffers (either
  single or multi-selections)
- `hbac_pin_all` - pin all buffers
- `hbac_unpin_all` - unpin all buffers
- `hbac_close_unpinned` - close all unpinned buffers
- `hbac_delete_buffer` - delete the selected buffers with the function set in `opts.close_command` (`nvim_buf_delete` by default`)

You can also call the picker function directly and pass a table of options (see `:h telescope.setup()` for valid option keys):

```lua
require("hbac.telescope").pin_picker({
  layout_strategy = "horizontal",
  initial_mode = "normal",
  -- etc.
})
```

## How to check the pin status of the current buffer

The `state` module exposes the `is_pinned` function, which returns the pin status of any buffer as a boolean value. You can use this check to display the pin status in your statusline or wherever you find convenient. Here is an example [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) integration:

```lua
lualine_c = {
    {
      function()
        local cur_buf = vim.api.nvim_get_current_buf()
        return require("hbac.state").is_pinned(cur_buf) and "📍" or ""
        -- tip: nerd fonts have pinned/unpinned icons!
      end,
      color = { fg = "#ef5f6b", gui = "bold" },
    }
  }
```
