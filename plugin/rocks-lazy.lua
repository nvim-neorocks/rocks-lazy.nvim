if vim.g.rocks_lazy_nvim_loaded then
    return
end

vim.g.rocks_lazy_nvim_loaded = true

local api = require("rocks.api")
local lz_n = require("lz.n")

local user_rocks = api.get_user_rocks()

local has_rocks_config, rocks_config = pcall(require, "rocks-config")
---@type fun(name: string) | nil
local config_hook = has_rocks_config and type(rocks_config.configure) == "function" and rocks_config.configure or nil

--- HACK: For some reason, if a RockSpec contains a list
--- (e.g. colorscheme = [ .. ]) then vim.deepcopy errors
--- if we don't fix it. This is possibly a toml_edit.lua bug!
---
---@generic T
---@param value T | T[]
---@return T | T[]
local function clone_toml_list(value)
    if vim.islist(value) then
        ---@cast value string[]
        return vim.list_extend({}, value)
    end
    return value
end

---@param keys string | string[] | rocks.lazy.KeysSpec[] | nil
---@return string | string[] | lz.n.KeysSpec[] | nil
local function to_lz_n_keys_spec(keys)
    if not keys or type(keys) == "string" then
        return keys
    end
    return vim.iter(keys)
        :map(function(value)
            if type(value) ~= "table" then
                return value
            end
            local result = vim.deepcopy(value)
            result[1] = value.lhs
            result.lhs = nil
            result[2] = value.rhs
            result.rhs = nil
            return result
        end)
        :totable()
end

---@type lz.n.PluginSpec[]
local specs = vim.iter(user_rocks)
    :filter(function(_, rock)
        ---@cast rock rocks.lazy.RockSpec
        return rock.opt == true
            or rock.event ~= nil
            or rock.cmd ~= nil
            or rock.keys ~= nil
            or rock.ft ~= nil
            or rock.colorscheme ~= nil
    end)
    :map(function(_, rock)
        ---@cast rock rocks.lazy.RockSpec
        ---@type lz.n.PluginSpec
        return {
            rock.name,
            before = config_hook,
            lazy = rock.opt,
            event = clone_toml_list(rock.event),
            cmd = clone_toml_list(rock.cmd),
            keys = to_lz_n_keys_spec(clone_toml_list(rock.keys)),
            ft = clone_toml_list(rock.ft),
            colorscheme = clone_toml_list(rock.colorscheme),
        }
    end)
    :totable()

local lz_spec = vim.g.rocks_nvim and vim.g.rocks_nvim.lz_spec or {}
if type(lz_spec) == "string" then
    table.insert(specs, { import = lz_spec })
else
    local is_single_plugin_spec = type(lz_spec[1]) == "string"
    if is_single_plugin_spec then
        table.insert(specs, lz_spec)
    elseif vim.islist(lz_spec) then
        vim.list_extend(specs, lz_spec)
    end
end

lz_n.load(specs)
