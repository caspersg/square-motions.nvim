local M = {}

M.next_quickfix = function()
  local ok, _ = pcall(vim.cmd.cnext)
  if not ok then
    pcall(vim.cmd.cfirst)
    -- print("cfirst")
  end
end

M.prev_quickfix = function()
  local ok, _ = pcall(vim.cmd.cprev)
  if not ok then
    pcall(vim.cmd.clast)
    -- print("clast")
  end
end

return M
