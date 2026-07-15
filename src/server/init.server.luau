--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AlephNum = require(ReplicatedStorage.Shared.AlephNum)

print(AlephNum.fromNumber(10e6):toSuffix())