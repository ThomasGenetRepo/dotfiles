-- lua/config/mode-cursorline.lua
--
-- Colors the cursor's line number by mode (insert/visual/replace/command/
-- terminal), so the mode is visible at a glance without a statusline.

local M = {}

function M.setup(opts)
	opts = opts or {}
	local va = vim.api
	local group = va.nvim_create_augroup("LineNumberChangeMode", {
		clear = true,
	})

	local function set_hl_for_mode(mode)
		-- Fall back to the "n" (normal) entry for submodes we don't list
		-- explicitly (operator-pending "no", insert-completion "ic", etc.),
		-- so every transition resolves to something instead of leaving
		-- whatever color the previous mode set.
		local hl = opts.mode[mode] or opts.mode.n

		if hl then
			va.nvim_set_hl(0, "CursorLineNr", hl)

			-- The statuscolumn may not repaint when switching to command mode so
			-- we force a redraw here to make sure the color updates
			if mode == "c" then
				vim.cmd.redraw()
			end
		end
	end

	set_hl_for_mode(va.nvim_get_mode().mode)

	va.nvim_create_autocmd("ModeChanged", {
		group = group,
		callback = function()
			local new_mode = vim.v.event.new_mode

			if opts.debug then
				vim.notify(new_mode, vim.log.levels.DEBUG)
			end

			set_hl_for_mode(new_mode)
		end,
	})
end

return M
