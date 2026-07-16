--!nocheck

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const AlephNum = require(ReplicatedStorage.Shared.AlephNum)

const weirdnum = AlephNum.fromString("0.06e565")

print(weirdnum:toSuffix(), weirdnum:toScientific())
print(weirdnum)