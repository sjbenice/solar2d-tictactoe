local Minimax = {}
local MATCH_COUNT = 3

local function itemIndexFromPos(x, y, dimension)
    return x + (y - 1) * dimension
end

local function evaluate(board, dimension)
    local matched = false
    local result = 0
    local pos = 0

    for x = 1, dimension do
        local match = 1
        for y = 1, dimension - 1 do
            pos = board[itemIndexFromPos(x, y, dimension)]
            if pos ~= 0 and pos == board[itemIndexFromPos(x, y + 1, dimension)] then
                match = match + 1
            else
                match = 1
            end
            if match == MATCH_COUNT then
                matched = true
                break
            end
        end

        if matched then
            break
        end
    end

    if not matched then
        for y = 1, dimension do
            local match = 1
            for x = 1, dimension - 1 do
                pos = board[itemIndexFromPos(x, y, dimension)]
                if pos ~= 0 and pos == board[itemIndexFromPos(x + 1, y, dimension)] then
                    match = match + 1
                else
                    match = 1
                end
                if match == MATCH_COUNT then
                    matched = true
                    break
                end
            end
    
            if matched then
                break
            end
        end
    end
    
    if not matched then
        for x = 1, dimension - MATCH_COUNT + 1 do
            local match = 1
            for y = 1, dimension - MATCH_COUNT + 1 do
                pos = board[itemIndexFromPos(x, y, dimension)]
                if pos ~= 0 then
                    matched = true
                    for i = 1, MATCH_COUNT - 1 do
                        if pos ~= board[itemIndexFromPos(x + i, y + i, dimension)] then
                            matched = false
                            break
                        end
                    end
                    if matched then
                        break
                    end
                end
            end
    
            if matched then
                break
            end
        end
    end

    if not matched then
        for x = 1, dimension - MATCH_COUNT + 1 do
            local match = 1
            for y = MATCH_COUNT, dimension do
                pos = board[itemIndexFromPos(x, y, dimension)]
                if pos ~= 0 then
                    matched = true
                    for i = 1, MATCH_COUNT - 1 do
                        if pos ~= board[itemIndexFromPos(x + i, y - i, dimension)] then
                            matched = false
                            break
                        end
                    end
                    if matched then
                        break
                    end
                end
            end
    
            if matched then
                break
            end
        end
    end

    if matched then
        if pos > 0 then
            result = -10
        else
            result = 10
        end
    end

    return result
end

-- Function to perform minimax with alpha-beta pruning
local function minimax(board, dimension, depth, isMaximizingPlayer, alpha, beta)
    local result = evaluate(board, dimension)
    if result ~= 0 then
        return result
    end
    -- print("minimax"..dimension..","..depth)
    if isMaximizingPlayer then
        local bestScore = -math.huge
        for i = 1, dimension do
            for j = 1, dimension do
                local pos = itemIndexFromPos(i, j, dimension)
                if board[pos] == 0 then
                    board[pos] = -1
                    bestScore = math.max(bestScore, minimax(board, dimension, depth + 1, false, alpha, beta))
                    board[pos] = 0
                    alpha = math.max(alpha, bestScore)
                    if beta <= alpha then
                        break
                    end
                end
            end
        end
        return bestScore
    else
        local bestScore = math.huge
        for i = 1, dimension do
            for j = 1, dimension do
                local pos = itemIndexFromPos(i, j, dimension)
                if board[pos] == 0 then
                    board[pos] = 1
                    bestScore = math.min(bestScore, minimax(board, dimension, depth + 1, true, alpha, beta))
                    board[pos] = 0
                    beta = math.min(beta, bestScore)
                    if beta <= alpha then
                        break
                    end
                end
            end
        end
        return bestScore
    end
end

-- Function to find the best move using minimax
function Minimax.findBestMove(board, dimension)
    local bestScore = -math.huge
    local bestMove = 0
    for i = 1, dimension do
        for j = 1, dimension do
            local pos = itemIndexFromPos(i, j, dimension)
            if board[pos] == 0 then
                board[pos] = -1
                local score = minimax(board, dimension, 0, false, -math.huge, math.huge)
                board[pos] = 0
                if score > bestScore then
                    bestScore = score
                    bestMove = i + (j - 1) * dimension
                end
            end
        end
    end
    return bestMove
end

return Minimax
