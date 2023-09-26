
function ColorMyPencils(color)
    -- color = color or "rose-pine"
    -- color = color or "tokyonight"
    color = color or "onedark"
	vim.cmd.colorscheme(color)
end 


ColorMyPencils()
