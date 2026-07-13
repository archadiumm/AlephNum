--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AlephNum = require(ReplicatedStorage.Shared.AlephNum)

print(AlephNum.fromLeaderboard(AlephNum.toLeaderboard("1e600")))
