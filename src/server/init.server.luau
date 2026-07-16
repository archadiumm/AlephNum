--!nocheck

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Aleph = require(ReplicatedStorage.Shared.AlephNum)

const UpdateFunctions = {}

UpdateFunctions.Snowflakes = {}
UpdateFunctions.Snowflakes.Multiplier = {}

UpdateFunctions.GetCostFromBaseAndUnderExp = function(Base: Aleph.AN, UnderExp: Aleph.AN, CurrentLevel: Aleph.AN, Amount: Aleph.AN): (Aleph.AN, string)
    local St = Aleph.mul(Base, Aleph.pow(UnderExp, CurrentLevel))
    local Cost = St * ((UnderExp ^ Amount - Aleph.new(1)) / (UnderExp - Aleph.new(1)))
    return Cost
end

UpdateFunctions.GetMaxBuyAmountFromBaseAndUnderExp = function(Base: Aleph.AN, UnderExp: Aleph.AN, CurrentLevel: Aleph.AN, Balance: Aleph.AN): (Aleph.AN, string)
    local Nom = Aleph.new(Balance) *(UnderExp - Aleph.new(1))
    print('nom', Nom)

    local Denom = Base * (UnderExp ^ CurrentLevel)
    print('denom', Denom)

    local Num = Nom / Denom print('num', Num)
    local WLog = Num + Aleph.new(1) print('wlog', WLog)
    local N = WLog:log(UnderExp) print('nnnn', N)
    
    return N
end

UpdateFunctions.Snowflakes.Multiplier.CostToLevel = function(CurrentLevel: number, Amount: number): (Aleph.AN, any)
    local Amount = Aleph.new(Amount)
    local Base = Aleph.new(10)
    local Expunder = Aleph.new(1.1)
    local CurrentLevel = Aleph.new(CurrentLevel)
    local Cost = UpdateFunctions.GetCostFromBaseAndUnderExp(Base, Expunder, CurrentLevel, Amount)
    
    return Cost, CurrentLevel + Amount, Amount
end

UpdateFunctions.Snowflakes.Multiplier.MaxBuyAmountFromBalance = function(CurrentLevel: number, Balance: number): (number)
    local Base = Aleph.new(10)
    local Expunder = Aleph.new(1.1)
    local CurrentLevel = Aleph.new(CurrentLevel)
    local N = UpdateFunctions.GetMaxBuyAmountFromBaseAndUnderExp(Base, Expunder, CurrentLevel, Balance)

    return Aleph.floor(N)
end

print(UpdateFunctions.GetMaxBuyAmountFromBaseAndUnderExp(10, 1.1, 1, Aleph.fromString("1e1111111111")))

print(Aleph.fromLeaderboard(Aleph.fromString("1e400"):toLeaderboard()))