local _MODREV, _SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "rocks-lazy.nvim"
version = _MODREV .. _SPECREV

dependencies = {
    "lua >= 5.1",
    "rocks.nvim >= 2.31.0",
    "lz.n >= 1.2.4",
}

source = {
    url = "git://github.com/nvim-neorocks/" .. package,
}

build = {
    type = "builtin",
    copy_directories = {
        "plugin",
    },
}
