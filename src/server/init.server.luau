--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AlephNum = require(ReplicatedStorage.Shared.AlephNum)

print(AlephNum.fromNumber(6.8374782828272e2):toSuffix())
print(AlephNum.fromNumber(6.8374782828272e3):toSuffix())
print(AlephNum.fromNumber(6.8374782828272e4):toSuffix())
print(AlephNum.fromNumber(6.8374782828272e5):toSuffix())
print(AlephNum.fromNumber(6.8374782828272e6):toSuffix())
print(AlephNum.fromNumber(6.8374782828272e7):toSuffix())
print(AlephNum.fromNumber(6.8374782828272e8):toSuffix())
