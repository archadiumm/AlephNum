--!optimize 2

--[[
	Creator: @archadiumm
	Name: AlephNum
	Description: Calculate numbers up to 10 ↑↑↑ 16 (https://googology.fandom.com/wiki/Arrow_notation)
	GitHub: https://github.com/archadiumm/AlephNum/
	
	Inspired By:
	 * @FoundForces - EternityNum2 Developer
	 * @KdudeDev - InfiniteMath Developer
	 
	 * Everything Upgrade Tree (and other incrementals)
]]

-- // Type Aliases \\ --

type ANConvertible = AN? | string | number
type ComparisonOperator = "==" | ">=" | "<=" | ">" | "<" | "!=" | "~="
type ANProperty = "Sign" | "Exp" | "Layer" | "Mantissa"
type Notation = "Scientific" | "Suffix" | "None"
type SciNotation = "None" | "Scientific" | "Suffix"
type ConfigKey = "StrictMode" | "Notation" | "Digits" | "Threshold" | "SciNotation" | "SciThreshold"

type Config = {
	StrictMode: boolean,
	Notation: Notation,
	SciNotation: SciNotation,
	Threshold: number,
	SciThreshold: number,
	Digits: number,
}

type SuffixSets = {
	sets: { string },
	firstSuffixes: { string },
	secondSuffixes: { string },
	thirdSuffixes: { string },
	multSuffixes: { string },
}

type ANTuple = {
	Sign: number,
	Layer: number | AN,
	Exp: number,
	Mantissa: number,
}

-- // Constants \\ --

const AlephNum = {}
const AN = {}

AlephNum.__index = AN

const HttpService = game:GetService("HttpService")
const endpoint = "https://api.github.com/repos/archadiumm/alephnum/releases/latest"
const versionName = "2.0.0"

AlephNum.Config: Config = {
	["StrictMode"] = false, -- If true, the script will halt instead of give warnings when things go wrong.

	["Notation"] = "Scientific", -- Scientific (1e10), Suffix (1T), or None (100000000000000000000...)
	["SciNotation"] = "None", -- None (1e1000000000000), Scientific (1e2e3e10), or Suffix (1e20k)

	["Threshold"] = 1e3, -- How big a number needs to be to be abbreviated into the Notation.
	["SciThreshold"] = 10, -- Caps out scientific abbreviated numbers from being too long (2e1e1e1e1e1e1e1e1e1e1e1e1e10 vs 2 * 10 ^^ 14)

	["Digits"] = 2, -- How many decimal places are shown (1k or 1.23k or 1.234567k, etc.)
}

const zero: AN = {
	Sign = 0 :: number,
	Layer = 0 :: number,
	Exp = 0 :: number,
	Mantissa = 0 :: number,
}

const expLimit = 1e10
const inf = (2 - 2 ^ -52) * 2 ^ 1023

const compareStrings = { "==", ">=", "<=", ">", "<", "!=", "~=" }

const suffixes: SuffixSets = {
	sets = { "k", "M", "B" },
	firstSuffixes = { "U", "D", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No" },
	secondSuffixes = { "De", "Vt", "Tg", "qg", "Qg", "sg", "Sg", "Og", "Ng" },
	thirdSuffixes = { "Ce", "Du", "Tr", "Qa", "Qi", "Se", "Si", "Ot", "Ni" },
	multSuffixes = {
		"Mi",
		"Mc",
		"Na",
		"Pi",
		"Fm",
		"At",
		"Zp",
		"Yc",
		"Xo",
		"Ve",
		"Me",
		"Due",
		"Tre",
		"Te",
		"Pt",
		"He",
		"Hp",
		"Oct",
		"En",
		"Ic",
		"Mei",
		"Dui",
		"Tri",
		"Teti",
		"Pti",
		"Hei",
		"Hp",
		"Oci",
		"Eni",
		"Tra",
		"TeC",
		"MTc",
		"DTc",
		"TrTc",
		"TeTc",
		"PeTc",
		"HTc",
		"HpT",
		"OcT",
		"EnT",
		"TetC",
		"MTetc",
		"DTetc",
		"TrTetc",
		"TeTetc",
		"PeTetc",
		"HTetc",
		"HpTetc",
		"OcTetc",
		"EnTetc",
		"PcT",
		"MPcT",
		"DPcT",
		"TPCt",
		"TePCt",
		"PePCt",
		"HePCt",
		"HpPct",
		"OcPct",
		"EnPct",
		"HCt",
		"MHcT",
		"DHcT",
		"THCt",
		"TeHCt",
		"PeHCt",
		"HeHCt",
		"HpHct",
		"OcHct",
		"EnHct",
		"HpCt",
		"MHpcT",
		"DHpcT",
		"THpCt",
		"TeHpCt",
		"PeHpCt",
		"HeHpCt",
		"HpHpct",
		"OcHpct",
		"EnHpct",
		"OCt",
		"MOcT",
		"DOcT",
		"TOCt",
		"TeOCt",
		"PeOCt",
		"HeOCt",
		"HpOct",
		"OcOct",
		"EnOct",
		"Ent",
		"MEnT",
		"DEnT",
		"TEnt",
		"TeEnt",
		"PeEnt",
		"HeEnt",
		"HpEnt",
		"OcEnt",
		"EnEnt",
		"Hect",
		"MeHect",
	},
}

local randFrames = 0
local lastRF = os.clock()

const scriptLocation: string = script:GetFullName()

-- // Functions \\ --

const function reverse<T>(tbl: { T }): { T }
	local result = table.create(#tbl)

	for i = 1, #tbl do
		result[i] = tbl[#tbl - i + 1]
	end

	return result
end

const function getRand(min: number, max: number): number
	min = AlephNum.toNumber(min)
	max = AlephNum.toNumber(max)

	if (os.clock() - lastRF) > 0.1 then
		lastRF = 0
	end

	const quantized = math.round((os.clock() * 1000) + randFrames)
	randFrames += 1

	const rand = Random.new(quantized)
	return rand:NextInteger(min, max)
end

const function toLength(number: number, length: number): string
	number = math.round(number * 100)

	local text: string = tostring(number)

	if string.len(text) >= length then
		return text:sub(0, length)
	else
		repeat
			text = `0{text}`
		until string.len(text) >= length

		return text:sub(0, length)
	end
end

const function checkVersion(): ()
	const httpCheck, _ = pcall(function()
		return HttpService:GetAsync("https://google.com/")
	end)

	if not httpCheck then
		warn(`┏ [AlephNum] AlephNum cannot check the latest version!`)
		warn(`┃  ╸ Please turn on HTTP Requests to fix this.`)
		warn(`┗  ╸ Experience Settings > Security > Allow HTTP Requests`)
	else
		const request: string = HttpService:GetAsync(endpoint)

		if not request then
			return
		end

		const response: { versionName: string, tag_name: string, html_url: string } = HttpService:JSONDecode(request)

		if response["tag_name"] == nil then
			return
		end

		if response.tag_name ~= versionName then
			local numVersion: string = (versionName:gsub("%D", ""))
			local numTag: string = (response.tag_name:gsub("%D", ""))

			numVersion = (tonumber(numVersion) or 100) :: number
			numTag = (tonumber(numTag) or 100) :: number

			if numVersion >= numTag then
				warn(`┏ [AlephNum] Wow, you are in the future! Is this a dev build?`)
				warn(
					`┃  ╸ v{versionName} is unstable right now, so you can downgrade to v{response.tag_name} from the link below.`
				)
				warn(`┗  ╸ https://github.com/archadiumm/AlephNum/releases/latest`)

				return
			end

			warn(`┏ [AlephNum] Seems like you are currently running v{versionName}.`)
			warn(`┃  ╸ Please download the newest version (v{response.tag_name}) from the link below.`)
			warn(`┗  ╸ https://github.com/archadiumm/AlephNum/releases/latest`)
		else
			const url_table = { url = response.html_url }

			print(`┏ [AlephNum] Currently using the latest version. (v{versionName}).`)
			print(`┗  ╸ For more information, check out the changelog at:`, url_table)
		end
	end
end

const function isNIL(value: any): boolean
	return (value == nil)
end

const function isAN(value: ANConvertible): boolean
	return (
		typeof(value) == "table"
		and (not isNIL(value["Sign"]) and not isNIL(value["Layer"]) and not isNIL(value["Exp"]))
	)
end

const function toNumber(value: ANConvertible): number
	if typeof(value) == "number" then
		return value
	end

	if isAN(value.Layer) or value.Layer > 1 then
		return math.huge
	end

	if value.Layer == 0 then
		return value.Sign * value.Mantissa * value.Exp
	else
		return value.Sign * value.Mantissa * (10 ^ value.Exp)
	end
end

const function getDepth(value: ANConvertible): number
	if typeof(value) ~= "table" then
		return 0
	end

	local depth = 0

	repeat
		if value and typeof(value) == "table" then
			value = value.Layer
			depth += 1
		else
			break
		end
	until false

	return depth
end

const function debugWhere(): (string, string)
	local level = 0

	local scriptName: string = debug.info(level, "s")
	local line: string = debug.info(level, "l")

	repeat
		scriptName = debug.info(level, "s")
		line = debug.info(level, "l")

		level += 1

		if level > 25 then
			scriptName = "[NIL]"
			line = "[NIL]"

			break
		end

	until level > 0 and not scriptLocation:find(scriptName) and scriptName ~= "[C]" and line > 0

	return scriptName, line
end

const function correct(value: ANConvertible): AN
	if not value then
		value = zero
		return value
	end

	-- ~ Nil Checks ~ --
	value.Exp = value.Exp or 0
	value.Layer = value.Layer or 0
	value.Mantissa = math.abs(value.Mantissa or 1)

	-- ~ Layer to Number/AN ~ --
	if isAN(value.Layer) and toNumber(value.Layer) < inf then
		value.Layer = toNumber(value.Layer)
	end

	if not isAN(value.Layer) and (not isNIL(value.Layer) and value.Layer >= inf) then
		value.Layer = AlephNum.fromNumber(value.Layer)

		if AlephNum.Config.DepthWarnings then
			const scriptName: string, line: string = debugWhere()

			warn(`┏ [AlephNum] A number has exceeded the Layer Limit!`)
			warn(`┃  ╸ Numbers past Layer 1e+308 are buggy, so be cautious!`)
			warn(`┗  ╸ Go to script: {scriptName} on line {line} to fix this.`)
		end
	end

	-- ~ Layer Down ~ --
	while toNumber(value.Layer) > 0 and value.Exp == 0 do
		value.Layer -= 1

		if value.Layer == 0 then
			value.Exp = value.Mantissa
			value.Mantissa = 1

			break
		end
	end

	-- ~ Cleanup ~ --
	if value.Exp ~= value.Exp or math.isinf(value.Exp) then
		value.Exp = expLimit - 1
		value.Layer += 1
	end

	if value.Mantissa ~= value.Mantissa or math.isinf(value.Mantissa) then
		value.Mantissa = 1
	end

	if value.Exp == 0 and value.Mantissa == 0 then
		value = zero
	end

	if math.sign(value.Exp) ~= 0 and value.Sign == 0 then
		value.Sign = 1
	end

	if value.Mantissa >= 10 then
		local loggedMantissa = value.Mantissa

		for index: number = 1, value.Layer do
			loggedMantissa = math.log10(loggedMantissa)
			value.Mantissa /= 10
		end

		const mantissaLog = math.floor(loggedMantissa)
		value.Exp += mantissaLog
	end

	-- ~ Layer 0 ~ --
	if value.Layer == 0 then
		value.Exp = value.Exp * value.Mantissa
		value.Mantissa = 1
	end

	if value.Layer == 0 and math.sign(value.Exp) == -1 then
		value.Sign = -value.Sign
		value.Exp = -value.Exp
	end

	if value.Layer == 0 and value.Exp == 0 then
		value.Sign = 0
	end

	-- ~ Layer 1 ~ --
	if value.Exp <= 0 and value.Layer == 1 then
		value.Exp = math.pow(10, value.Exp) * value.Mantissa
		value.Layer = 0
		value.Mantissa = 1
	end

	while value.Exp >= expLimit do
		value.Exp = math.log10(value.Exp)
		value.Layer += 1
	end

	if value.Layer == 1 then
		const leftoverExp = value.Exp - math.floor(value.Exp)

		if leftoverExp > 0 and leftoverExp < 1 then
			value.Mantissa *= math.pow(10, leftoverExp)
		end

		value.Exp = math.floor(value.Exp)
	end

	if value.Mantissa < 1 and value.Layer == 1 then
		if value.Mantissa == 0 then
			value.Mantissa = 1
		else
			repeat
				value.Mantissa *= 10
				value.Exp -= 1
			until value.Mantissa >= 1
		end
	end

	return value
end

const function tupleNum(Sign: number, Layer: number, Exp: number, Mantissa: number): AN
	const new: AN = setmetatable({
		Sign = Sign,
		Layer = Layer,
		Exp = Exp,
		Mantissa = Mantissa,
	}, AlephNum)

	return correct(new)
end

const function toMeta(value: ANConvertible): AN
	return setmetatable(value, AlephNum)
end

const function cmp(
	value1: ANConvertible,
	value2: ANConvertible,
	name: ANProperty,
	compareString: ComparisonOperator
): boolean
	local result: boolean = false

	local cmp1 = value1[name]
	local cmp2 = value2[name]

	if name ~= "Sign" then
		cmp1 *= value1.Sign
		cmp2 *= value2.Sign
	end

	if compareString == ">" or compareString == ">=" then
		result = (compareString == ">" and (cmp1 > cmp2) or (compareString == ">=" and (cmp1 >= cmp2)))
	elseif compareString == "<" or compareString == "<=" then
		result = (compareString == "<" and (cmp1 < cmp2) or (compareString == "<=" and (cmp1 <= cmp2)))
	end

	return result
end

const function tierSuffix(tier: number, smallTierSuffix: boolean, exp: number): string
	tier = math.abs(math.round(tier))

	if tier <= 3 and not smallTierSuffix then
		return suffixes.sets[tier]
	elseif tier < 1000 or smallTierSuffix then
		if not smallTierSuffix then
			tier -= 1
		elseif tier > 1000 then
			tier = math.fmod(tier, 1000)
		end

		const ones = tier % 10
		const tens = math.floor(tier / 10) % 10
		const hundreds = math.floor(tier / 100) % 10

		local endResult: string = ""

		if ones > 0 then
			endResult ..= suffixes.firstSuffixes[ones]
		end

		if tens > 0 then
			endResult ..= suffixes.secondSuffixes[tens]
		end

		if hundreds > 0 then
			endResult ..= suffixes.thirdSuffixes[hundreds]
		end

		return endResult
	else
		local endResult: string = ""

		local firstChunk: boolean = true
		const idxStart: number = math.floor(math.log10(exp))

		for index: number = idxStart, 0, -1 do
			if exp >= 10 ^ (index * 3) then
				local chunk: number = math.floor(tier / 10 ^ (index * 3))
				local suffix: string? = tierSuffix(chunk - 1, true)

				const multSuffix: string = suffixes.multSuffixes[index + 1] or ""

				if firstChunk then
					if chunk == 1 then
						suffix = ""
					else
						suffix = tierSuffix(chunk, true)
					end
				else
					suffix = tierSuffix(chunk - 1, true)
				end

				if firstChunk then
					firstChunk = false
					endResult ..= suffix
				else
					endResult ..= `{multSuffix}{suffix}`
				end

				exp = math.fmod(exp, 10 ^ (index * 3))
				tier = math.fmod(tier, 10 ^ (index * 3))
			end
		end

		return endResult
	end
end

const function layerUp(value: ANConvertible): ANTuple
	if value.Layer == 0 then
		return {
			Sign = value.Sign,
			Layer = 1,
			Exp = 0,
			Mantissa = value.Exp,
		}
	elseif value.Exp == 0 then
		return {
			Sign = value.Sign,
			Layer = value.Layer + 1,
			Exp = 0,
			Mantissa = value.Mantissa,
		}
	end

	const baseExp: number = math.log10(value.Exp)
	const newExp: number = math.floor(baseExp)

	const newMantissa: number = math.pow(10, baseExp - newExp)
	const newLayer: number = (value.Layer + 1)

	return {
		Sign = value.Sign,
		Layer = newLayer,
		Exp = newExp,
		Mantissa = newMantissa,
	}
end

-- // Main Functions \\ --

-- ~ AlephNum.new() ~
-- ------------------
-- [?] Creates a new AlephNum (AN) number.
-- [>] Input a (string), (number), or (Sign, Layer, Exp, Mantissa) to create a new AlephNum.
-- [<] Returns an AlephNum (AN) number.
--  *  [+] You can also use convert, fromNumber, fromString, or fromTuple instead depending on your use case.
function AlephNum.new(...): AN
	const tuple: { string | number } = { ... }
	const doConvert: boolean = not tuple[2]

	local result: AN = nil

	if doConvert then
		result = AlephNum.convert(tuple[1])
	else
		result = tupleNum(...)
	end

	const metaResult: AN = toMeta(result)

	return metaResult
end

-- ~ AlephNum.huge() ~
-- ------------------
-- [?] Returns the biggest possible AN number.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.huge(): AN
	return AlephNum.fromNumber(inf)
end

-- ~ AlephNum.fromTuple() ~
-- ------------------
-- [?] Creates a new AlephNum (AN) number.
-- [>] Input a (Sign, Layer, Exp, Mantissa) to create a new AlephNum.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.fromTuple(Sign: number, Layer: number, Exp: number, Mantissa: number): AN
	return AlephNum.fix(tupleNum(Sign, Layer, Exp, Mantissa))
end

-- ~ AlephNum.convert() ~
-- ------------------
-- [?] Converts many types into AlephNum (AN) numbers.
-- [>] Input a (string), (number) or (AN) value.
-- [<] Returns an AlephNum (AN) number.
--  *  [+] You can also use fromString or fromNumber instead depending on your use case.
function AlephNum.convert(value: ANConvertible): AN
	local newValue: AN = nil

	if not value then
		newValue = zero
	elseif typeof(value) == "number" then
		newValue = AlephNum.fromNumber(value)
	elseif typeof(value) == "string" then
		newValue = AlephNum.fromString(value)
	elseif typeof(value) == "table" then
		if isAN(value) then
			newValue = correct(value)
		else
			newValue = zero
		end
	end

	return toMeta(newValue)
end

-- ~ AlephNum.fix() ~
-- ------------------
-- [?] Used for development purposes to fix AlephNum numbers.
-- [>] Input any value type.
-- [<] Returns an AlephNum (AN) number.
--  * [+] Not reccomended to use really.
function AlephNum.fix(value: any): AN
	if isNIL(value) then
		const scriptName: string, line: string = debugWhere()

		warn(`┏ [AlephNum] A value is nil! Defaulting to zero.`)
		warn(`┗  ╸ Go to script: {scriptName} on line {line} to fix this.`)

		if AlephNum.Config.StrictMode then
			error(`Strict Mode enabled! Halting the script..`, 4)
		end

		return toMeta(zero)
	end

	if isAN(value) then
		value = correct(value)
	else
		value = AlephNum.convert(value)
	end

	return toMeta(value)
end

-- ~ AlephNum.clone() ~ -
-- [?] Used for development purposes to clone AlephNum numbers.
-- [>] Input any value type.
-- [<] Returns an AlephNum (AN) number.
--  * [+] Not reccomended to use really.
function AlephNum.clone(value: ANConvertible): AN
	if not isAN(value) then
		value = AlephNum.fix(value)
	end

	return table.clone(toMeta(tupleNum(value.Sign, value.Layer, value.Exp, value.Mantissa)))
end

-- ~ AlephNum.normalize() ~ -
-- [?] Used for development purposes to normalize.
-- [>] Input any value type.
-- [<] Returns an AlephNum (AN) number.
--  * [+] Not reccomended to use really.
function AlephNum.normalize(value: ANConvertible, layer: number | AN): AN
	if value.Layer ~= layer then
		local stop: boolean

		repeat
			if value.Exp <= 0 or getDepth(value.Layer) < getDepth(layer) then
				if getDepth(value.Layer) < getDepth(layer) then
					value.Exp = 0
					value.Mantissa = 0
					value.Sign = 0
				end

				break
			end

			if typeof(value.Layer) == "number" then
				stop = (value.Layer >= layer)
			else
				task.wait()
			end

			value = layerUp(value)
		until stop

		value.Layer = layer
	end

	return value
end

-- ~ AlephNum.normalizeTwo() ~ -
-- [?] Used for development purposes to normalize in bulk.
-- [>] Input any value types.
-- [<] Returns two AlephNum (AN) numbers.
--  * [+] Not reccomended to use really.
function AlephNum.normalizeTwo(value1: ANConvertible, value2: ANConvertible): (AN, AN)
	if value1.Layer ~= value2.Layer then
		local oneGreater: boolean

		if typeof(value1.Layer) == "number" and typeof(value2.Layer) == "number" then
			oneGreater = value1.Layer > value2.Layer
		else
			local depth = math.min(getDepth(value1.Layer), getDepth(value2.Layer))

			repeat
				local v1 = value1
				local v2 = value2

				for i = 1, depth do
					if typeof(v1) == "number" or typeof(v2) == "number" then
						continue
					end

					v1 = v1["Layer"]
					v2 = v2["Layer"]
				end

				if typeof(v1) == "number" and typeof(v2) == "number" then
					oneGreater = v1 > v2
				else
					oneGreater = (isAN(v1) and not isAN(v2))
				end

				if oneGreater then
					break
				end

				depth += 1
			until not isNIL(oneGreater)
		end

		if oneGreater then
			value2 = AlephNum.normalize(value2, value1.Layer)
		else
			value1 = AlephNum.normalize(value1, value2.Layer)
		end
	end

	return value1, value2
end

-- ~ AlephNum.fromNumber() ~
-- ------------------
-- [?] Converts numbers into AlephNum (AN) numbers.
-- [>] Input a (number) value.
-- [<] Returns an AlephNum (AN) number.
--  *  [+] You can also use AlephNum.convert() instead depending on your use case.
function AlephNum.fromNumber(value: number): AN
	value = tonumber(value)

	if typeof(value) ~= "number" then
		return AlephNum.convert(value)
	end

	if math.isinf(value) then
		return AlephNum.fromTuple(math.sign(value), 1, 308, 1)
	end

	const abs: number = math.abs(value)
	local newValue: AN = nil

	if abs >= 1e15 then
		const exp: number = math.floor(math.log10(abs))
		const mantissa: number = abs / math.pow(10, exp)

		newValue = AlephNum.fromTuple(math.sign(value), 1, exp, mantissa)
	else
		newValue = AlephNum.fromTuple(math.sign(value), 0, abs, 1)
	end

	return toMeta(newValue)
end

-- ~ AlephNum.toLeaderboard() ~
-- ------------------
-- [?] Compresses AN numbers into numbers that can be used in OrderedDataStores.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns a number.
--  *  [+] Due to leaderboard restrictions, the maximum and minimum amounts are about (-9e999 <-> 9e999)
function AlephNum.toLeaderboard(value: ANConvertible): number
	value = AlephNum.round(AlephNum.fix(value))
	value = AlephNum.clamp(value, "-9e999", "9e999")

	if isAN(value.Layer) then
		return -1
	elseif value.Sign == 0 then
		return 0
	elseif value.Layer == 0 then
		return value:toNumber()
	end

	local string: string = tostring(value.Sign)
	string ..= toLength(value.Layer, 3)
	string ..= toLength(value.Exp, 5)
	string ..= toLength(value.Mantissa, 9)

	return tonumber(string)
end

-- ~ AlephNum.fromLeaderboard() ~
-- ------------------
-- [?] Decompresses values from OrderedDataStores into AlephNum numbers.
-- [>] Input a number.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.fromLeaderboard(value: number): AN
	const text: string = tostring(value)

	if #text ~= 18 then
		return AlephNum.convert(value)
	end

	const sign: number = tonumber(text:sub(1, 1))
	const layer: number = tonumber(text:sub(2, 4)) / 100
	const exp: number = tonumber(text:sub(5, 9)) / 100
	const mantissa: number = tonumber(text:sub(10, 18)) / 100

	return AlephNum.fromTuple(sign, layer, exp, mantissa)
end

-- ~ AlephNum.setConfig() ~ -
-- ------------------
-- [?] Changes settings in the AlephNum config.
-- [>] Input a configName (string) and a (boolean) value.
function AlephNum.setConfig(configName: ConfigKey, value: any): ()
	const setting: any = AlephNum.Config[configName]

	if not isNIL(setting) then
		const baseType: string = typeof(AlephNum.Config[configName])
		const valueType: string = typeof(value)

		if baseType ~= value then
			const scriptName: string, line: string = debugWhere()

			warn(`┏ [AlephNum] Expected {baseType} for {configName}, got {valueType}. ({value})`)
			warn(`┗  ╸ Go to script: {scriptName} on line {line} to fix this.`)

			if AlephNum.Config.StrictMode then
				error(`Strict Mode enabled! Halting the script..`, 4)
			end

			return
		end

		AlephNum.Config[configName] = value
	else
		const scriptName: string, line: string = debugWhere()

		warn(`┏ [AlephNum] "{configName}" is not a valid configName!`)
		warn(`┃  ╸ Go to script: {scriptName} on line {line} to fix this.`)
		warn(`┗  ╸ See valid configNames at:`, AlephNum.Config)

		if AlephNum.Config.StrictMode then
			error(`Strict Mode enabled! Halting the script..`, 4)
		end
	end
end

-- ~ AlephNum.toNumber() ~
-- ------------------
-- [?] Converts AlephNum (AN) numbers into luau numbers.
-- [>] Input an AlephNum number.
-- [<] Returns a luau number.
--  *  [+] For AlephNumbers above Layer 1, they cannot be converted normally. (will return INF)
function AlephNum.toNumber(value: ANConvertible): number
	value = AlephNum.fix(value)

	if isAN(value.Layer) then
		return math.huge
	end

	local newNumber: number

	if value.Layer == 0 then
		newNumber = value.Exp * value.Sign
	else
		newNumber = value.Sign * value.Mantissa

		local exp: number = value.Exp

		for i = 1, value.Layer do
			if i >= value.Layer then
				exp = 10 ^ value.Exp
				break
			end

			exp = 10 ^ exp

			if math.isinf(exp) then
				return math.huge
			end
		end

		return newNumber * exp
	end

	return newNumber
end

-- ~ AlephNum.fromString() ~
-- ------------------
-- [?] Converts strings into AlephNum (AN) numbers.
-- [>] Input a (string) value.
-- [<] Returns an AlephNum (AN) number.
--  *  [+] You can also use AlephNum.convert() instead depending on your use case.
function AlephNum.fromString(value: string): AN
	local newValue: AN = zero
	value = tostring(value):lower()

	if not value then
		newValue = toMeta(zero)
	end

	const valueNum: number? = tonumber(value)
	const sciSlice: { string? } = value:split("e")
	const defSlice: { string? } = value:split(";")

	if not isNIL(valueNum) and not math.isinf(valueNum) and not value:find("e") and not value:find(";") then
		newValue = AlephNum.fromNumber(valueNum)
	elseif #sciSlice >= 2 then
		newValue = nil

		for index = #sciSlice, 1, -1 do
			local old: AN

			const current: string = sciSlice[index]
			const number: number = tonumber(current)

			if not number then
				continue
			end

			if not newValue then
				newValue = AlephNum.fromNumber(number)
				continue
			else
				old = AlephNum.clone(newValue)
			end

			newValue = AlephNum.mul(AlephNum.fromNumber(number), AlephNum.pow(10, old))
		end

		if string.sub(value, 1, 1) == "-" then
			newValue.Sign = -1
		end
	elseif #defSlice == 2 then
		const mantissa = tonumber(defSlice[1]) or 1
		const exponent = tonumber(defSlice[2]) or 0

		newValue = tupleNum(0, 0, exponent, mantissa)
	end

	return toMeta(newValue)
end

return AlephNum
