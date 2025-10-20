-- Public entrypoint
local C = require("oil_header.config")
local A = require("oil_header.autocmds")

local M = {}

--- Setup the header extension.
-- @param opts table|nil
--   - winhl: string|nil  -> window highlight overrides, e.g. "Normal:NormalFloat,EndOfBuffer:NormalFloat"
--   - force_quit: boolean|nil -> if true, use :qall! when exiting via Oil-only flow
function M.setup(opts)
    C.apply(opts or {})
    A.setup()
end

return M
