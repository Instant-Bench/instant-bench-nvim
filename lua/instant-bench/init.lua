local M = {}

local function makeHttpRequest(url, data)
    local requests = require("requests")
    local reponse = requests.post{url, data}
    return response
end

local function getSelectedText()
    -- Save current register contents and visual mode
    local saved_register = vim.fn.getreg('"')
    local saved_visual_mode = vim.fn.visualmode()

    -- Enter visual mode and yank selection to @" register
    vim.cmd('normal! gv"xy')

    -- Retrieve text from @" register
    local selected_text = vim.fn.getreg('"')

    -- Restore original register contents and visual mode
    vim.fn.setreg('"', saved_register)
    vim.fn.visualmode(saved_visual_mode)

    return selected_text
end

function M.sendSelectedText()
    local selected_text = getSelectedText()
    print("Selected:", selected_text)
    print("File type:", vim.bo.filetype)
    local endpoint_url = "http://localhost:3000/"
    local res, code, headers, body = makeHttpRequest(endpoint_url, {"extension": vim.bo.filetype, "code": selected_text})

    if code == 200 then
        print("HTTP request successful!")
        print("Response Body:", body)
    else
        print("HTTP request failed. Error code:", code)
        print("Response Body:", body)
    end
end

return M
