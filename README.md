<!-- markdownlint-disable -->
<br />
<div align="center">
  <a href="https://github.com/nvim-neorocks/rocks-lazy.nvim">
    <img src="./rocks-header.svg" alt="rocks-lazy.nvim">
  </a>
  <p align="center">
    <!-- <br /> -->
    <!-- <a href="./doc/rocks-lazy.txt"><strong>Explore the docs »</strong></a> -->
    <!-- <br /> -->
    <br />
    <a href="https://github.com/nvim-neorocks/rocks-lazy.nvim/issues/new?assignees=&labels=bug">Report Bug</a>
    ·
    <a href="https://github.com/nvim-neorocks/rocks-lazy.nvim/issues/new?assignees=&labels=enhancement">Request Feature</a>
    ·
    <a href="https://github.com/nvim-neorocks/rocks.nvim/discussions/new?category=q-a">Ask Question</a>
  </p>
  <p>
    <strong>
      A lazy-loading module for <a href="https://github.com/nvim-neorocks/rocks.nvim/">rocks.nvim</a>!
    </strong>
  </p>
</div>
<!-- markdownlint-restore -->

[![LuaRocks][luarocks-shield]][luarocks-url]

> [!WARNING]
>
> This module is WIP and does not have a stable release yet.

## :star2: Summary

`rocks-lazy.nvim` is a rocks.nvim module that helps you lazy-load
your `opt` rocks.nvim plugins
using the [`lz.n`](https://github.com/nvim-neorocks/lz.n) library.

> [!NOTE]
>
> **Should I lazy-load plugins?**
>
> It should be a plugin author's responsibility to ensure their plugin doesn't
> unnecessarily impact startup time, not yours!
>
> See [our "DO's and DONT's" guide for plugin developers](https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#sleeping_bed-lazy-loading).
>
> Regardless, the current status quo is horrible, and some authors may
> not have the will or capacity to improve their plugins' startup impact.
>
> If you find a plugin that takes too long to load,
> or worse, forces you to load it manually at startup with a
> call to a heavy `setup` function,
> consider opening an issue on the plugin's issue tracker.

## :pencil: Requirements

- An up-to-date `rocks.nvim`.

## :hammer: Installation

Simply run `:Rocks install rocks-lazy.nvim`,
and you are good to go!

## :books: Usage

With this module installed, you can add the following fields to a `[plugins]` entry
in your `rocks.toml`:

### Fields

#### `event`

Lazy-load on an event (`:h autocmd-events`).

- Type: `string?` or `string[]`

Events can be specified with or without patterns, e.g.
`BufEnter` or `BufEnter *.lua`.

Example:

```toml
[plugins.nvim-cmp]
version = "scm"
opt = true
event = "InsertEnter"
```

```toml
[plugins]
nvim-cmp = { version = "scm", opt = true, event = "InsertEnter" }
```

#### `cmd`

Lazy-load on a command (`:h user-commands`).

- Type: `string?` or `string[]`

Example:

```toml
[plugins."telescope.nvim"]
version = "0.1.8"
opt = true
cmd = "Telescope"
```

```toml
[plugins]
"telescope.nvim" = { version = "0.1.8", opt = true, cmd = "Telescope" }
```

#### `ft`

Lazy-load on a `:h filetype` event.

- Type: `string?` or `string[]`

Example:

```toml
[plugins.neorg]
version = "8.0.0"
opt = true
ft = "norg"
```

```toml
[plugins]
neorg = { version = "8.0.0", opt = true, ft = "norg" }
```

#### `keys`

Lazy-load on key mappings.

- Type: `string?` or `string[]` or `rocks.lazy.KeysSpec[]`

Where `rocks.lazy.KeysSpec` is a table with the following fields:

- `lhs`: `string`
- `rhs`: `string?`
- `mode`: `string?` or `string[]` (default: `"n"`)
- `[string]`: Options, see `:h vim.keymap.set`

> [!NOTE]
>
> If unspecified, the default `mode` is `n`.

Examples:

```toml
[plugins."neo-tree.nvim"]
version = "scm"
opt = true
keys = { lhs = "<leader>ft", rhs = "<CMD>Neotree toggle<CR>", desc = "NeoTree toggle" }

[plugins."dial.nvim"]
version = "0.4.0"
opt = true
keys = ["<C-a>", { lhs = "<C-x>", mode = "n" }]
```

```toml
[plugins]
"neo-tree.nvim" = { version = "scm", opt = true, keys = { "<leader>ft", "<CMD>Neotree toggle<CR>", desc = "NeoTree toggle" } }
```

#### `colorscheme`

Lazy-load when setting a colorscheme.

- Type: `string?` or `string[]`

Example:

```toml
[plugins."kanagawa.nvim"]
version = "1.0.0"
opt = true
colorscheme = [
  "kanagawa",
  "kanagawa-dragon",
  "kanagawa-lotus",
  "kanagawa-wave"
]
```

```toml
[plugins]
"sweetie.nvim" = { version = "1.0.0", opt = true, colorscheme = "sweetie" }
```

> [!TIP]
>
> You can specify combinations of the above lazy-loading fields
>
> Example:
>
> ```toml
> [plugins."telescope.nvim"]
> version = "0.1.8"
> opt = true
> cmd = "Telescope"
> keys = [ { lhs = "<leader>t", rhs = "<CMD>Telescope<CR>" } ]
> ```

## :book: License

`rocks-lazy.nvim` is licensed under [GPLv3](./LICENSE).

[luarocks-shield]: https://img.shields.io/luarocks/v/neorocks/rocks-lazy.nvim?logo=lua&color=purple&style=for-the-badge
[luarocks-url]: https://luarocks.org/modules/neorocks/rocks-lazy.nvim
