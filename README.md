# hbac.nvim
Heuristic buffer auto-close
# overview
Automagically close the unedited buffers in your bufferlist when it becomes too long. The "edited" buffers remain untouched. For a buffer to be considered edited it is enough to enter insert mode once or modify it in any way.

# description
You like using the buffer list, but you hate it when it has too many buffers, because you loose the overview for what files you are *actually* working on. Indeed, a lot of the times, when browsing code you want to look at some files, that you are not actively working on, like checking the definitions or going down the callstack when debugging. These files then pollute the bufferlist and make it harder to find ones you actually care about.
Reddit user **xmsxms** [posted](https://www.reddit.com/r/neovim/comments/12c4ad8/closing_unused_buffers/?utm_source=share&utm_medium=web2x&context=3) a script that marks all once edited files in a session as important and provides a keybinding to close all the rest. In fact, I used some of his code in this plugin, and you can achieve the same effect as his script using hbac.
The main feature of this plugin, however, is the automatic closing of buffers. If the number of buffers reaches a threschold (default is 10), the oldest unedited buffer will be closed once you open a new one.

# installation

with packer
```lua
use 'axkirillov/hbac.nvim'
```
with lazy
```lua	
{
  'axkirillov/hbac.nvim',
  config = function ()
    require("hbac").setup()
  end
}
```

# configuration
```lua
require("hbac").setup({
  autoclose = true, -- set autoclose to false if you want to close manually
  threshold = 10 -- hbac will start closing unedited buffers once that number is reached
})
```

# usage
Let hbac do its magick 😊

or

use `require("hbac").close_unused()` to close all unedited buffers
