---@mod rocks-lazy.internal lazy-loading module for rocks.nvim

local rocks_lazy = {}

function rocks_lazy.load()
    local api = require("rocks.api")
    local log = require("rocks.log")
    local lz_n = require("lz.n")

    local user_rocks = api.get_user_rocks()

    local has_rocks_config, rocks_config = pcall(require, "rocks-config")

    local config_hook = has_rocks_config
            and type(rocks_config.configure) == "function"
            ---@param plugin lz.n.Plugin
            and function(plugin)
                local rock_spec = user_rocks[plugin.name]
                if rock_spec then
                    pcall(vim.cmd.packadd, { plugin.name, bang = true })
                    rocks_config.configure(
                        rock_spec,
                        ---@param items? rock_name[]
                        function(items)
                            vim
                                .iter(items or {})
                                ---@param item rock_name
                                :each(function(item)
                                    pcall(vim.cmd.packadd, { item, bang = true })
                                end)
                        end
                    )
                else
                    log.warn(
                        ("rocks-lazy: skipping rocks-config hook because %s not found in user rocks."):format(
                            plugin.name
                        )
                    )
                end
            end
        or function(_) end

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
                load = vim.cmd.packadd,
            }
        end)
        :totable()

    local rocks_toml = api.get_rocks_toml()
    local config = rocks_toml.rocks_lazy or {}
    local lz_specs = config.import
    if type(lz_specs) == "string" then
        table.insert(specs, { import = lz_specs })
    end

    lz_n.load(specs)
end

return rocks_lazy
