local spinner_frames = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'}
local spinner_index = 1
local loading = true

local options = {
  endpoint = "http://localhost:3000",
}

local function update_spinner(message)
  if loading then
    vim.o.statusline = message .. spinner_frames[spinner_index]
    spinner_index = (spinner_index % #spinner_frames) + 1
    vim.defer_fn(function() update_spinner(message) end, 100)
  else
    vim.o.statusline = "Loading complete"
  end
end

local function start_loading()
  loading = true
  update_spinner("Loading ")
end

local function stop_loading()
  loading = false
end

local M = {}

local function makeHttpRequest(url, data)
    local plenary_http = require("plenary.curl")
    local json = vim.fn.json_encode(data)

    local response = plenary_http.post(url, {
        body = json,
        headers = {
            ["Content-Type"] = "application/json",
        },
    })

    if response.status == 200 then
        return {
            status_code = response.status,
            text = response.body
        }
    else
        return nil, "HTTP request failed with status: " .. response.status
    end
end

local function getSelectedText()
    -- Save current register contents and visual mode
    local saved_register = vim.fn.getreg('"')
    local saved_visual_mode = vim.fn.mode()

    -- Enter visual mode and yank selection to @" register
    vim.cmd('normal! gv"xy')

    -- Retrieve text from @" register
    local selected_text = vim.fn.getreg('"')

    -- Restore original register contents and visual mode
    vim.fn.setreg('"', saved_register)
    vim.api.nvim_feedkeys(saved_visual_mode, 'x', true)

    return selected_text
end

local uv = vim.loop

local write_file = function(path, data)
  local fd = uv.fs_open(path, "w", 438)
  uv.fs_write(fd, data)
  uv.fs_close(fd)
end

function M.setup(user_options)
  options = vim.tbl_deep_extend("force", options, user_options or {})
end

function M.sendSelectedText()
    start_loading()
    local selected_text = getSelectedText()
    local endpoint_url = options.endpoint
    local response, err = makeHttpRequest(endpoint_url, { extension = vim.bo.filetype, code = selected_text })

    if response then
        if response.status_code == 200 then
            local extension = vim.bo.filetype
            if extension == "javascript" then
              extension = "mjs"
            end

            local filename = "bench." .. extension
            update_spinner("Creating " .. filename)
            write_file(filename, response.text)
            stop_loading()
            vim.api.nvim_command("vsplit " .. filename)
        else
            print("HTTP request failed. Error code:", response.status_code)
        end
    else
        print("HTTP request failed. Error:", err)
    end
end

return M
