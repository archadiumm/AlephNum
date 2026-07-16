--!nocheck

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const AlephNum = require(ReplicatedStorage.Shared.AlephNum)

print(AlephNum.cmp("1e12", "9.45e11", "<"))
print(AlephNum.cmp("1e1e132", "9.435e11", ">"))