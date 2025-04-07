M = {}

local function Is_Open_File(bufname)
  local is_nvimtree = string.sub(bufname, 1, 8) == "NvimTree"
  local is_scratch = bufname == ""
  local is_term_file = string.sub(bufname, 1, 4) == "term"

  return not (is_nvimtree or is_scratch or is_term_file)
end

function M.SessionSave()
  vim.cmd("silent !rm -f .session")
  vim.cmd("silent !touch .session")

  for tab = 1, vim.fn.bufnr('$') do
    local bufname = vim.fn.bufname(tab)
    local abs_path = ""

    if string.sub(bufname, 1, 1) ~= '/' then
      abs_path = vim.fn.getcwd() .. "/"
    end

    if Is_Open_File(bufname) then
      vim.cmd("silent !echo -e '" .. abs_path .. bufname .. "'" .. ">> .session")
    end
  end
end

function M.SessionRestore()
  local tabs = vim.api.nvim_get_current_win()

  local handle = io.popen("cat .session")

  if handle == nil or handle:read("*line") == "" then
    return
  end

  local line = handle:read("*line")
  while line do
    vim.cmd("e " .. line)
    line = handle:read("*line")
  end

  vim.cmd("ToggleTerm size=15 dir=" .. vim.fn.getcwd() .. " direction=horizontal name=term")
  vim.api.nvim_set_current_win(tabs)

  local nt_api = require('nvim-tree.api')
  require('nvim-tree').setup({})
  nt_api.tree.open()

  vim.api.nvim_set_current_win(tabs)
end

return M
