vim.g.lz_n = {
    load = function() end,
}

local tempdir = vim.fn.tempname()
local config_path = vim.fs.joinpath(tempdir, "rocks.toml")

vim.system({ "rm", "-r", tempdir }):wait()
vim.system({ "mkdir", "-p", tempdir .. "/lua/lazy_specs" }):wait()

local rocks_lazy = require("rocks-lazy.internal")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("rocks-lazy.nvim", function()
    it("toml + lua plugin dir", function()
        vim.g.lz_n_did_load = false
        vim.g.rocks_nvim = {
            rocks_path = tempdir,
            config_path = config_path,
        }
        local config_content = [[
[plugins."dial.nvim"]
version = "0.4.0"
opt = true
keys = [ "<C-a>", { lhs = "<C-x>", mode = "n" }]

[rocks_lazy]
import = "lazy_specs/"
]]
        local config = require("rocks.config.internal")
        local fh = assert(io.open(config.config_path, "w"), "Could not open rocks.toml for writing")
        fh:write(config_content)
        fh:close()
        local plugin_config_content = [[
return {
  "telescope.nvim",
  cmd = "Telescope",
}
]]
        local spec_file = vim.fs.joinpath(tempdir, "lua", "lazy_specs", "telescope.lua")
        fh = assert(io.open(spec_file, "w"), "Could not open config file for writing")
        fh:write(plugin_config_content)
        fh:close()
        vim.opt.runtimepath:append(tempdir)
        local spy_load = spy.on(loader, "_load")
        rocks_lazy.load()
        vim.cmd.Telescope()
        assert.spy(spy_load).called(1)
        local feed = vim.api.nvim_replace_termcodes("<Ignore><C-x>", true, true, true)
        vim.api.nvim_feedkeys(feed, "ix", false)
        assert.spy(spy_load).called(2)
    end)
end)
