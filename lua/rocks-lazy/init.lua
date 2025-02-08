---@mod rocks-lazy lazy-loading module for rocks.nvim
local rocks_lazy = {}

---The default `before` hook.
---If rocks-config.nvim is installed, this invokes
---the |rocks-config.configure| function.
---@param plugin lz.n.Plugin
rocks_lazy.default_before_hook = function(plugin)
    require("rocks-lazy.internal").config_hook(plugin)
end

return rocks_lazy
