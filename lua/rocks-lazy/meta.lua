---@meta
error("Cannot require a meta module")

---@class rocks.lazy.RockSpec: RockSpec lz.n.PluginSpecHandlers
---@field name string Name of the plugin
---@field opt? boolean If 'true', will not be loaded on startup.
---
---Load a plugin on one or more |autocmd-events|.
---@field event? string | lz.n.EventSpec[]
---
--- Load a plugin on one or more |user-commands|.
--- @field cmd? string[]|string
---
--- Load a plugin on one or more |FileType| events.
--- @field ft? string[]|string
---
--- Load a plugin on one or more |key-mapping|s.
--- @field keys? string|string[]|lz.n.KeysSpec[]
---
--- Load a plugin on one or more |colorscheme| events.
--- @field colorscheme? string[]|string

---@class rocks.lazy.KeysSpec: vim.keymap.set.Opts
---@field lhs string
---@field rhs? string
---@field desc? string
---@field noremap? boolean
---@field remap? boolean
---@field expr? boolean
---@field nowait? boolean
---@field ft? string|string[]
---@field mode? string|string[]

---@type lz.n.Spec
vim.g.rocks_nvim.lz_spec = vim.g.rocks_nvim.lz_spec
