--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AlephNum = require(ReplicatedStorage.Shared.AlephNum)

print(AlephNum.huge() * 10)
