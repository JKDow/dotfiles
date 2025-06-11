return {
    "lervag/vimtex",                     -- Core LaTeX plugin
    lazy = false,
    init = function()
        vim.g.vimtex_view_method = "zathura" -- or 'skim', 'sioyek', etc.
        vim.g.vimtex_compiler_method = "latexmk"
    end
}
