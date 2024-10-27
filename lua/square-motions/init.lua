local ts_move = require("nvim-treesitter.textobjects.move")
local indent = require("square-motions.indent")
local quickfix = require("square-motions.quickfix")

local M = {}

--- execute a basic key sequence
--- @param cmd_str string: the exact keys for the motion
local function cmd(cmd_str)
  return function()
    vim.cmd("normal! " .. vim.api.nvim_replace_termcodes(cmd_str, true, true, true))
  end
end

M.default_config = {
  next_prefix = "]",
  prev_prefix = "[",
  motions = {
    -- these will be default keymaps soon, so could be removed soon
    { key = "d", desc = "[d]iagnostic", next = vim.diagnostic.goto_next, prev = vim.diagnostic.goto_prev },
    { key = "q", desc = "[q]uickfix item", next = quickfix.next_quickfix, prev = quickfix.prev_quickfix },
    { key = "b", desc = "[b]uffer", next = vim.cmd.bnext, prev = vim.cmd.bprevious },

    { key = "t", desc = "[t]ab", next = vim.cmd.tabnext, prev = vim.cmd.tabprevious },
    { key = "l", desc = "fo[l]d", next = cmd("zj"), prev = cmd("zk") },
    { key = "w", desc = "[w]indow", next = cmd("<C-w>w"), prev = cmd("<C-w>W") },

    { key = "n", desc = "i[n]dent", next = indent.next_indent, prev = indent.prev_indent },
    {
      key = "j",
      desc = "[j]umps",
      next = function()
        -- C-i is a special case, it's the same as tab, so it requires feedkeys
        -- TODO: But this doesn't work in operator pending mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-i>", true, true, true), "n", true)
      end,
      prev = cmd("<C-o>"),
    },
  },

  swap_next = "]S",
  swap_prev = "[S",
  textobjects = {
    -- already taken
    -- ib iB ip is it iw iW i<brackets and quotes>
    -- ab aB ap as at aw aW a<brackets and quotes>

    { key = "ia", desc = "[a]ssignment", query = "@assignment.inner" },
    { key = "aa", desc = "[a]ssignment", query = "@assignment.outer" },
    -- TODO find better keys for rhs/lhs
    { key = "iR", desc = "assignment [R]hs", query = "@assignment.rhs" },
    { key = "iL", desc = "assignment [L]hs", query = "@assignment.lhs" },

    { key = "iA", desc = "[a]ttribute", query = "@attribute.inner" },
    { key = "aA", desc = "[a]ttribute", query = "@attribute.outer" },

    { key = "ik", desc = "bloc[k]", query = "@block.inner" },
    { key = "ak", desc = "bloc[k]", query = "@block.outer" },

    { key = "ic", desc = "[c]all", query = "@call.inner" },
    { key = "ac", desc = "[c]all", query = "@call.outer" },

    { key = "iC", desc = "[C]lass", query = "@class.inner" },
    { key = "aC", desc = "[C]lass", query = "@class.outer" },

    { key = "io", desc = "c[o]mment", query = "@comment.inner" },
    { key = "ao", desc = "c[o]mment", query = "@comment.outer" },

    { key = "in", desc = "co[n]ditional", query = "@conditional.inner" },
    { key = "an", desc = "co[n]ditional", query = "@conditional.outer" },

    { key = "ie", desc = "fram[e]", query = "@frame.inner" },
    { key = "ae", desc = "fram[e]", query = "@frame.outer" },

    { key = "if", desc = "[f]unction", query = "@function.inner" },
    { key = "af", desc = "[f]unction", query = "@function.outer" },

    { key = "il", desc = "[l]oop", query = "@loop.inner" },
    { key = "al", desc = "[l]oop", query = "@loop.outer" },

    { key = "iN", desc = "[N]umber", query = "@number.inner" },

    { key = "iP", desc = "[P]arameter", query = "@parameter.inner" },
    { key = "aP", desc = "[P]arameter", query = "@parameter.outer" },

    { key = "ig", desc = "re[g]ex", query = "@regex.inner" },
    { key = "ag", desc = "pe[g]ex", query = "@regex.outer" },

    { key = "ir", desc = "[r]eturn", query = "@return.inner" },
    { key = "ar", desc = "[r]eturn", query = "@return.outer" },

    { key = "iO", desc = "sc[O]pename", query = "@scopename.inner" },

    { key = "aS", desc = "[S]tatement", query = "@statement.outer" },

    -- ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
  },
}

M.textobject_motions = function()
  local keymaps = {}
  for _, def in ipairs(M.config.textobjects) do
    local next = function()
      ts_move.goto_next(def.query)
    end
    local prev = function()
      ts_move.goto_previous(def.query)
    end
    table.insert(keymaps, { key = def.key, desc = def.desc, next = next, prev = prev })
  end
  return keymaps
end

--- setup the plugin
--- @param opts table: configuration options
M.setup = function(opts)
  M.config = vim.tbl_deep_extend("keep", opts or {}, M.default_config)

  for _, def in ipairs(M.config.motions) do
    local desc = { desc = def.desc, remap = true }
    vim.keymap.set({ "n", "v", "o" }, M.config.next_prefix .. def.key, def.next, desc)
    vim.keymap.set({ "n", "v", "o" }, M.config.prev_prefix .. def.key, def.prev, desc)
  end

  for _, def in ipairs(M.textobject_motions()) do
    local next_key = M.config.next_prefix .. def.key
    local prev_key = M.config.prev_prefix .. def.key
    local desc = { desc = def.desc, remap = true }
    vim.keymap.set({ "n", "v", "o" }, next_key, def.next, desc)
    vim.keymap.set({ "n", "v", "o" }, prev_key, def.prev, desc)
  end

  local keymaps = M.textobject_keymaps(M.config)

  -- vim.notify("keymaps " .. vim.inspect(keymaps))
  require("nvim-treesitter.configs").setup({
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = keymaps.select_keymaps,
        include_surrounding_whitespace = false,
      },
      -- using this to define the keymaps means those keymaps cannot be overridden
      -- which breaks last-motions
      -- move = {
      --     enable = true,
      --     set_jumps = true, -- whether to set jumps in the jumplist
      --     goto_next = keymaps.next,
      --     goto_previous = keymaps.prev,
      -- },
      swap = {
        enable = true,
        swap_next = keymaps.swap_next,
        swap_previous = keymaps.swap_prev,
      },
    },
  })
end

M.textobject_keymaps = function(config)
  local select_keymaps = {}
  local next = {}
  local prev = {}
  local swap_next = {}
  local swap_prev = {}

  for _, def in ipairs(config.textobjects) do
    -- vim.notify("ts " .. vim.inspect(def))
    select_keymaps[def.key] = { query = def.query, desc = def.desc }
    next[config.next_prefix .. def.key] = { query = def.query, desc = def.desc }
    prev[config.prev_prefix .. def.key] = { query = def.query, desc = def.desc }
    swap_next[config.swap_next .. def.key] = { query = def.query, desc = def.desc }
    swap_prev[config.swap_prev .. def.key] = { query = def.query, desc = def.desc }
  end

  return {
    select_keymaps = select_keymaps,
    next = next,
    prev = prev,
    swap_next = swap_next,
    swap_prev = swap_prev,
  }
end
return M
