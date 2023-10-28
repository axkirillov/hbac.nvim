local telescope = require('telescope')

return telescope.register_extension({
	exports = {
		buffers = require('hbac.telescope').pin_picker,
	}
})
