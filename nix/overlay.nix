{
  self,
  rocks-nvim-flake,
}: final: prev: let
  name = "rocks-lazy.nvim";

  luaPackage-override = luaself: luaprev: {
    lz-n = luaself.callPackage ({
      buildLuarocksPackage,
      fetchurl,
      fetchzip,
      luaOlder,
    }:
      buildLuarocksPackage {
        pname = "lz.n";
        version = "1.2.3-1";
        knownRockspec =
          (fetchurl {
            url = "mirror://luarocks/lz.n-1.2.3-1.rockspec";
            sha256 = "1h89pkj8j82wfzqvia54q70y1zpdwkc4j8kifl3xpmyyp4kgibkw";
          })
          .outPath;
        src = fetchzip {
          url = "https://github.com/nvim-neorocks/lz.n/archive/v1.2.3.zip";
          sha256 = "1bms3ynha48mar2zfmyd3vlvxz7v3q1v5jxp1dhxwmyxa1dp2vhc";
        };
        disabled = luaOlder "5.1";
      }) {};

    rocks-lazy-nvim = luaself.callPackage ({
      luaOlder,
      buildLuarocksPackage,
      lua,
      rocks-nvim,
      lz-n,
    }:
      buildLuarocksPackage {
        pname = name;
        version = "scm-1";
        knownRockspec = "${self}/rocks-lazy.nvim-scm-1.rockspec";
        src = self;
        disabled = luaOlder "5.1";
        propagatedBuildInputs = [
          rocks-nvim
          lz-n
        ];
      }) {};
  };
  lua5_1 = prev.lua5_1.override {
    packageOverrides = luaPackage-override;
  };
  lua51Packages = final.lua5_1.pkgs;
  luajit = prev.luajit.override {
    packageOverrides = luaPackage-override;
  };
  luajitPackages = final.luajit.pkgs;

  neovim-with-rocks = let
    rocks = rocks-nvim-flake.packages.${final.system}.rocks-nvim;
    rocks-lazy = final.luajitPackages.rocks-lazy-nvim;
    lz-n = final.luajitPackages.lz-n;
    neovimConfig = final.neovimUtils.makeNeovimConfig {
      withPython3 = true;
      viAlias = false;
      vimAlias = false;
      # plugins = [ final.vimPlugins.rocks-nvim ];
      extraLuaPackages = ps: [ps.rocks-nvim];
    };
  in
    final.wrapNeovimUnstable final.neovim-nightly (neovimConfig
      // {
        luaRcContent =
          /*
          lua
          */
          ''
            -- Copied from installer.lua
            local rocks_config = {
                rocks_path = vim.fn.stdpath("data") .. "/rocks",
                luarocks_binary = "${final.luajitPackages.luarocks}/bin/luarocks",
            }

            vim.g.rocks_nvim = rocks_config

            local luarocks_path = {
                vim.fs.joinpath("${rocks}", "share", "lua", "5.1", "?.lua"),
                vim.fs.joinpath("${rocks}", "share", "lua", "5.1", "?", "init.lua"),
                vim.fs.joinpath("${rocks-lazy}", "share", "lua", "5.1", "?.lua"),
                vim.fs.joinpath("${rocks-lazy}", "share", "lua", "5.1", "?", "init.lua"),
                vim.fs.joinpath("${lz-n}", "share", "lua", "5.1", "?.lua"),
                vim.fs.joinpath("${lz-n}", "share", "lua", "5.1", "?", "init.lua"),
                vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
                vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
            }
            package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

            local luarocks_cpath = {
                vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
                vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
            }
            package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")

            vim.opt.runtimepath:append(vim.fs.joinpath("${rocks}", "rocks.nvim-scm-1-rocks", "rocks.nvim", "*"))
            vim.opt.runtimepath:append(vim.fs.joinpath("${rocks-lazy}", "rocks-lazy.nvim-scm-1-rocks", "rocks-lazy.nvim", "*"))
          '';
        wrapRc = true;
        wrapperArgs =
          final.lib.escapeShellArgs neovimConfig.wrapperArgs
          + " "
          + ''--set NVIM_APPNAME "nvimrocks"'';
      });
in {
  inherit
    lua5_1
    lua51Packages
    luajit
    luajitPackages
    neovim-with-rocks
    ;

  vimPlugins =
    prev.vimPlugins
    // {
      rocks-git-nvim = final.neovimUtils.buildNeovimPlugin {
        pname = name;
        version = "dev";
        src = self;
      };
    };

  rocks-lazy-nvim = lua51Packages.rocks-lazy-nvim;
}
