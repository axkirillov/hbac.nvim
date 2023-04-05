local id = vim.api.nvim_create_augroup("hbac", {
	clear = false
})

local M = {
	persistant_buffers = {},
}

M.persist_buffer = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	M.persistant_buffers[bufnr] = true
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

			if M.last == nil then
				return
			end

			if M.persistant_buffers[M.last] then
				return
			end

			local min = 2 ^ 1023
			local buffers = vim.api.nvim_list_bufs()
			local num_buffers = 0
			for _, buf in ipairs(buffers) do
				local name = vim.api.nvim_buf_get_name(buf)
				local listed = vim.api.nvim_buf_get_option(buf, 'buflisted')
				if name ~= "" and listed then
					num_buffers = num_buffers + 1
					if not M.persistant_buffers[buf] then
						min = math.min(min, buf)
					end
				end
			end

			if num_buffers <= 10 then
				return
			end

			if min >= 2 ^ 1023 then
				return
			end

			vim.api.nvim_buf_delete(min, {})
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
