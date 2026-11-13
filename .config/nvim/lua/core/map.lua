-- Shared keymap helper: silent by default, desc as the 4th arg.
return function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end
