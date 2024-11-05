local M = {}

local function goto_different_indent(inc)
  local current_line = vim.fn.line(".")
  local current_indent = vim.fn.indent(current_line)
  local wrapped = 0
  local next_line = inc(current_line, wrapped)

  while wrapped < 2 and next_line ~= current_line do
    if vim.fn.indent(next_line) ~= current_indent and vim.fn.nextnonblank(next_line) == next_line then
      -- vim.notify("set_line" .. next_line)
      vim.cmd("normal! m`") -- add to jumplist
      vim.api.nvim_win_set_cursor(0, { next_line, 0 })
      return
    end
    next_line, wrapped = inc(next_line, wrapped)
  end
end

M.next_indent = function()
  goto_different_indent(function(old_line, wrapped)
    local line = old_line + 1
    if line > vim.fn.line("$") then
      return 1, wrapped + 1
    else
      return line, wrapped
    end
  end)
end

M.prev_indent = function()
  goto_different_indent(function(old_line, wrapped)
    local line = old_line - 1
    if line < 1 then
      return vim.fn.line("$"), wrapped + 1
    else
      return line, wrapped
    end
  end)
end

return M
