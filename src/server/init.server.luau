local AlephNum = require(game.ReplicatedStorage.Shared.AlephNum)

local div = AlephNum.div(38000, 1000000)
print(div:toNumber(), AlephNum.sqrt(div):toNumber())
