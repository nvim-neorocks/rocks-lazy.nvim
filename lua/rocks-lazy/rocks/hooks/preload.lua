---@type rocks.hooks.RockSpecModifier
return {
    type = "RockSpecModifier",
    ---@param rock rocks.lazy.RockSpec
    hook = function(rock)
        if rock.cmd or rock.event or rock.ft or rock.keys or rock.colorscheme then
            rock.opt = true
        end
        return rock
    end,
}
