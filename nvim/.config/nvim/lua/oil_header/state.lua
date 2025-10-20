local S = {}

-- map: oil_win_id -> header_win_id
S.headers = {}

function S.header_for(oil_win)
    return S.headers[oil_win]
end

function S.set_header(oil_win, hdr_win)
    S.headers[oil_win] = hdr_win
end

function S.clear_header(oil_win)
    S.headers[oil_win] = nil
end

function S.clear_all()
    S.headers = {}
end

function S.find_host_for_header_win(hdr_win)
    for oil_win, hw in pairs(S.headers) do
        if hw == hdr_win then return oil_win end
    end
end

return S
