if vim.g.rocks_lazy_nvim_loaded then
    return
end

vim.g.rocks_lazy_nvim_loaded = true

require("rocks-lazy.internal").load()
