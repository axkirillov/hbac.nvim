local id = vim.api.nvim_create_augroup("hbac", {
	clear = false
})

local M = {
	persistant_buffers = {},
	last = nil
}

M.persist_buffer = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	M.persistant_buffers[bufnr] = true
end

M.close_last = function()
	if M.last == nil then
		return
	end

	if not M.persistant_buffers[M.last] then
		vim.cmd('bd ' .. tostring(M.last))
	end

	M.last = nil
end

M.setup = function()
	vim.api.nvim_create_autocmd({ "BufRead" }, {
		group = id,
		pattern = { "*" },
		callback = function()
			vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
				buffer = 0,
				once = true,
				callback = function()
					M.persist_buffer()
				end
			})
		end
	})

	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = id,
		pattern = { "*" },
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
			-- if the buffer is not a file - do nothing
			if buftype ~= "" then
				return
			end

			if bufnr == M.last then
				return
			end

			M.close_last()
		end
	})

	vim.api.nvim_create_autocmd({ "BufLeave" }, {
		group = id,
		pattern = { "*" },
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')

			-- if the buffer is not a file - do nothing
			if buftype ~= "" then
				return
			end

			M.last = bufnr
		end
	})
end


local function close_unused()
	local curbufnr = vim.api.nvim_get_current_buf()
	local buflist = vim.api.nvim_list_bufs()
	for _, bufnr in ipairs(buflist) do
		if vim.bo[bufnr].buflisted and bufnr ~= curbufnr and not M.persistant_buffers[bufnr] then
			vim.cmd('bd ' .. tostring(bufnr))
		end
	end
end

return {
	close_unused = close_unused,
	setup = M.setup,
}
