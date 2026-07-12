--!nocheck
--!optimize 2

--hi

--[[
	Creator: @archadiumm
	Name: AlephNum
	Description: A library to handle numbers PAST 10↑↑2^1024 (https://googology.fandom.com/wiki/Arrow_notation)
	
	Inspired By:
	 * @FoundForces - EternityNum2 Developer
	 * @KdudeDev - InfiniteMath Developer
	 
	 * Everything Upgrade Tree (and other incrementals)
]]
--

-- // Constants \\ --

const AlephNum = {}
const AN = {}

AlephNum.__index = AN
AlephNum.Config = {
	["StrictMode"] = false,

	["Notation"] = "Scientific",
	["SciNotation"] = "None",
	--["SciParenthesis"] = true,
	["Threshold"] = 1e3,
	["Digits"] = 2,
}

const zero: AN = {
	Sign = 0 :: number,
	Layer = 0 :: number,
	Exp = 0 :: number,
	Mantissa = 0 :: number,
}

const expLimit = 1e10
const inf = 1e308

const compareStrings = { "==", ">=", "<=", ">", "<", "!=", "~=" }

const suffixes = {
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

const scriptLocation: string = script:GetFullName()

-- // Types \\ --

export type AN = typeof(setmetatable(
	{} :: {
		Sign: number,
		Layer: number,
		Exp: number,
		Mantissa: number,
	},
	AlephNum
))

-- // Functions \\ --

const function reverse<T>(tbl: { T }): { T }
	local result = table.create(#tbl)

	for i = 1, #tbl do
		result[i] = tbl[#tbl - i + 1]
	end

	return result
end

const function isNIL(value: any): boolean
	return (value == nil)
end

const function isAN(value: AN | any): boolean
	return (
		typeof(value) == "table"
		and (not isNIL(value["Sign"]) and not isNIL(value["Layer"]) and not isNIL(value["Exp"]))
	)
end

const function toNumber(value: AN): number
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

const function getDepth(value: AN?): number
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

const function correct(value: AN): AN
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
		print("layerback")
		value.Layer = toNumber(value.Layer)
	end

	if not isAN(value.Layer) and (not isNIL(value.Layer) and value.Layer >= inf) then
		print("layeragain", value.Layer)
		value.Layer = AlephNum.fromNumber(value.Layer)
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

	-- ~ Layer 2+ ~ --
	-- layer 2+ cleanups later

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

const function toMeta(value: AN): AN
	return setmetatable(value, AlephNum)
end

const function cmp(
	value1: AN,
	value2: AN,
	name: "Sign" | "Exp" | "Layer" | "Mantissa",
	compareString: "==" | ">=" | "<=" | ">" | "<" | "!=" | "~="
): boolean
	local result: boolean = false

	local cmp1 = value1[name]
	local cmp2 = value2[name]

	if name == "Exp" then
		cmp1 = (value1.Exp * value1.Sign * value1.Mantissa)
		cmp2 = (value2.Exp * value2.Sign * value2.Mantissa)
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

const function layerUp(value: AN): AN
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
function AlephNum.convert(value: string | number | AN): AN
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
function AlephNum.fix(value: any)
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
function AlephNum.clone(value: AN): AN
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
function AlephNum.normalize(value: AN, layer: number | AN): AN
	if value.Layer ~= layer then
		local stop: boolean

		repeat
			if value.Exp <= 0 or getDepth(value.Layer) < getDepth(layer) then
				if getDepth(value.Layer) < getDepth(layer) then
					print("briueh")
					value.Exp = 0
					value.Mantissa = 0
					value.Sign = 0
				end

				break
			end

			if typeof(value.Layer) == "number" then
				stop = (value.Layer >= layer)
			else
				print(isAN(value.Layer), isAN(layer), typeof(value.Layer) == "number")
				task.wait()
			end

			value = layerUp(value)
		until stop

		value.Layer = layer
		print(value.Layer)
	end

	return value
end

-- ~ AlephNum.normalizeTwo() ~ -
-- [?] Used for development purposes to normalize in bulk.
-- [>] Input any value types.
-- [<] Returns two AlephNum (AN) numbers.
--  * [+] Not reccomended to use really.
function AlephNum.normalizeTwo(value1: AN, value2: AN): (AN, AN)
	if value1.Layer ~= value2.Layer then
		local oneGreater: boolean

		print("bef", oneGreater)

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

		print(oneGreater)

		if oneGreater then
			value2 = AlephNum.normalize(value2, value1.Layer)
		else
			value1 = AlephNum.normalize(value1, value2.Layer)
		end
	else
		print("what")
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

-- ~ AlephNum.setConfig() ~ -
-- ------------------
-- [?] Changes settings in the AlephNum config.
-- [>] Input a configName (string) and a (boolean) value.
function AlephNum.setConfig(
	configName: "StrictMode" | "Notation" | "Digits" | "Threshold" | "SciNotation",
	value: any
): ()
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
function AlephNum.toNumber(value: AN): number
	value = AlephNum.fix(value)

	if value.Layer > 1 then
		return math.huge
	end

	if value.Layer == 0 then
		return value.Sign * value.Mantissa * value.Exp
	else
		return value.Sign * value.Mantissa * (10 ^ value.Exp)
	end
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
		newValue = tupleNum(math.sign(valueNum), 0, math.abs(valueNum), 1)
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
	elseif #defSlice == 2 then
		const mantissa = tonumber(defSlice[1]) or 1
		const exponent = tonumber(defSlice[2]) or 0

		newValue = tupleNum(0, 0, exponent, mantissa)
	end

	return toMeta(newValue)
end

-- ~ AlephNum.toString() ~
-- ------------------
-- [?] Converts an AlephNum (AN) number into a string.
-- [>] Input an AlephNum number and a table of options (optional).
-- [<] Returns a string.
--  *  [+] You can also change the default config using setConfig() instead of typing the options every time!
function AlephNum.toString(
	value: AN,
	options: { Notation: "None" | "Scientific" | "Suffix", Threshold: number, Digits: number }
): string
	value = AlephNum.fix(value)

	options = options or {}
	options.Notation = options.Notation or AlephNum.Config.Notation
	options.Digits = math.abs(options.Digits or AlephNum.Config.Digits)
	options.Threshold = math.abs(options.Threshold or AlephNum.Config.Threshold)

	const notation: string = options.Notation
	const digits: number = options.Digits
	const threshold: number = math.clamp(options.Threshold, 1e3, math.huge)

	const digitPower: number = math.pow(10, digits)

	const abs = AlephNum.abs(value)

	if notation == "None" or AlephNum.cmp(abs, threshold, "<") then
		return tostring(value:toNumber())
	end

	if notation == "Scientific" then
		if value.Layer == 0 then
			local exp: number = math.floor(math.log10(value.Exp))

			const baseMantissa: number = value.Exp / (10 ^ exp)
			const formattedMantissa: number = math.round(baseMantissa * digitPower) / digitPower

			if AlephNum.Config.SciNotation == "Suffix" and exp >= threshold then
				return `{formattedMantissa}e{AlephNum.toSuffix(exp, digits, threshold)}`
			else
				return `{formattedMantissa}e{exp}`
			end
		elseif value.Layer == 1 then
			local exp: number = math.floor(value.Exp)

			const baseMantissa: number = value.Mantissa
			const formattedMantissa: number = math.round(baseMantissa * digitPower) / digitPower

			if AlephNum.Config.SciNotation == "Suffix" and exp >= threshold then
				return `{formattedMantissa}e{AlephNum.toSuffix(exp, digits, threshold)}`
			else
				return `{formattedMantissa}e{exp}`
			end
		else
			if AlephNum.Config.SciNotation == "Suffix" then
				const mantissa = value.Mantissa
				const formattedMantissa = math.round(mantissa * digitPower) / digitPower

				local newExp: AN = AlephNum.fromNumber(value.Exp)

				for index: number = 1, value.Layer - 1 do
					newExp = AlephNum.pow10(newExp)
				end

				return `{formattedMantissa}e{AlephNum.toSuffix(newExp, digits, threshold)}`
			end

			const clone: AN = AlephNum.clone(value)
			local numbers: { number } = {}

			while clone.Layer >= 0 do
				if clone.Layer == value.Layer then
					table.insert(numbers, math.floor(clone.Exp))
				elseif clone.Layer == 0 then
					table.insert(numbers, value.Mantissa)
				elseif clone.Layer == value.Layer - 1 then
					const floor = math.floor(clone.Exp)
					const extra = clone.Exp - floor

					table.insert(numbers, 1 * (10 ^ extra))
				else
					table.insert(numbers, 1)
				end

				clone.Layer -= 1
			end

			numbers = reverse(numbers)

			local result: string = ""

			for index: number, value: number in ipairs(numbers) do
				const formattedValue = math.round(value * digitPower) / digitPower

				result ..= formattedValue

				if not isNIL(numbers[index + 1]) then
					result ..= "e"
				end
			end

			return result
		end
	elseif notation == "Suffix" then -- unfinished
		local baseTier: number

		local log10: number = AlephNum.log10(value):toNumber()
		local div3: number = log10 / 3

		if value.Layer == 0 then
			baseTier = math.floor(div3)
		elseif value.Layer == 1 then
			log10 = value.Exp
			div3 = log10 / 3

			baseTier = math.floor(div3)
		else
			return AlephNum.toScientific(value, digits, threshold)
		end

		const tier = math.floor(baseTier)
		const extra = div3 - math.floor(div3)

		local mantissa: number

		if value.Layer == 0 then
			const exp: number = math.floor(math.log10(value.Exp))

			const baseMantissa: number = value.Exp / (10 ^ exp)
			mantissa = math.round(baseMantissa * digitPower) / digitPower
		elseif value.Layer == 1 then
			const baseMantissa: number = value.Mantissa
			mantissa = math.round(baseMantissa * digitPower) / digitPower
		end

		if mantissa >= 10 then
			repeat
				mantissa /= 10
			until mantissa < 10
		end

		if extra > 0 then
			if extra >= 0.5 then
				mantissa *= 10
			end

			if extra >= 0.8 then
				mantissa *= 10
			end
		end

		return `{mantissa}{tierSuffix(tier, false, value.Exp)}`
	else
		const scriptName: string, line: string = debugWhere()

		warn(`┏ [AlephNum] "{notation}" is not a valid Notation!`)
		warn(`┃  ╸ Go to script: {scriptName} on line {line} to fix this.`)
		warn(`┗  ╸ See valid notations here:`, { "None", "Scientific", "Suffix" })

		return tostring(value:toNumber())
	end
end

-- ~ AlephNum.toSuffix() ~
-- ------------------
-- [?] Converts AlephNum (AN) numbers into strings.
-- [>] Input an AlephNum number and some options (optional).
-- [<] Returns a string. (10000 -> 10k for example)
function AlephNum.toSuffix(value: AN, digits: number?, threshold: number?)
	return AlephNum.toString(value, { Digits = digits, Notation = "Suffix", Threshold = threshold })
end

-- ~ AlephNum.toScientific() ~
-- ------------------
-- [?] Converts AlephNum (AN) numbers into strings.
-- [>] Input an AlephNum number and some options (optional).
-- [<] Returns a string. (10000 -> 1e4 for example)
function AlephNum.toScientific(value: AN, digits: number?, threshold: number?)
	return AlephNum.toString(value, { Digits = digits, Notation = "Scientific", Threshold = threshold })
end

-- // Operations \\ --

-- ~ AlephNum.cmp() ~
-- ------------------
-- [?] Compares two AlephNum (AN) numbers.
-- [>] Input two (AN) values and a (string) [">=" for example].
-- [<] Returns a boolean value.
function AlephNum.cmp(value1: AN, value2: AN, compareString: "==" | ">=" | "<=" | ">" | "<" | "!=" | "~="): boolean
	if not compareString then
		compareString = "nil"
	end

	if compareString ~= "==" then
		compareString = compareString:gsub("==", "=")
	end

	local result: boolean = false

	if not table.find(compareStrings, compareString) then
		const scriptName: string, line: string = debugWhere()

		warn(`┏ [AlephNum] "{compareString}" is not a valid compareString! Defaulting to false.`)
		warn(`┃  ╸ Go to script: {scriptName} on line {line} to fix this.`)
		warn(`┗  ╸ See valid compareStrings at:`, compareStrings)

		if AlephNum.Config.StrictMode then
			error(`Strict Mode enabled! Halting the script..`, 4)
		end

		return false
	end

	value1 = AlephNum.clone(AlephNum.fix(value1))
	value2 = AlephNum.clone(AlephNum.fix(value2))

	value1, value2 = AlephNum.normalizeTwo(value1, value2)

	if compareString == "!=" or compareString == "~=" then
		result = ((value1.Layer ~= value2.Layer) or (value1.Exp ~= value2.Exp) or (value1.Sign ~= value2.Sign))
		return result
	elseif compareString == "==" then
		result = ((value1.Layer == value2.Layer) and (value1.Exp == value2.Exp) and (value1.Sign == value2.Sign))

		return result
	end

	if value1.Sign == value2.Sign then
		if value1.Layer == value2.Layer then
			result = cmp(value1, value2, "Exp", compareString)
		end
	else
		result = cmp(value1, value2, "Sign", compareString)
	end

	return result
end

-- ~ AlephNum.add() ~
-- ------------------
-- [?] Adds two AlephNum (AN) numbers.
-- [>] Input two (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.add(value1: AN, value2: AN): AN
	if typeof(value1) == "number" and typeof(value2) == "number" then
		return AlephNum.fromNumber(value1 + value2)
	end

	local newValue: AN = zero

	value1 = AlephNum.clone(AlephNum.fix(value1))
	value2 = AlephNum.clone(AlephNum.fix(value2))

	if value1.Sign == 0 then
		return toMeta(value2)
	elseif value2.Sign == 0 then
		return toMeta(value1)
	elseif value1.Layer == 0 and value2.Layer == 0 then
		return toMeta(
			tupleNum(0, 0, (value1.Exp * value1.Sign) + (value2.Exp * value2.Sign), (value1.Mantissa * value2.Mantissa))
		)
	end

	print("add", value1.Layer == value2.Layer)
	value1, value2 = AlephNum.normalizeTwo(value1, value2)

	if value1.Exp ~= value2.Exp then
		const expDifference: number = math.abs(value1.Exp - value2.Exp)

		if value1.Exp > value2.Exp then
			value2.Mantissa *= math.pow(10, -expDifference)
			value2.Exp = value1.Exp
		else
			value1.Mantissa *= math.pow(10, -expDifference)
			value1.Exp = value2.Exp
		end
	end

	value1.Mantissa *= value1.Sign
	value2.Mantissa *= value2.Sign

	const newMantissa: number = value1.Mantissa + value2.Mantissa

	const newSign = math.sign(newMantissa)

	newValue = tupleNum(newSign, value1.Layer, value1.Exp, math.abs(newMantissa))

	return toMeta(newValue)
end

-- ~ AlephNum.sub() ~
-- ------------------
-- [?] Subtracts two AlephNum (AN) numbers.
-- [>] Input two (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.sub(value1: AN, value2: AN): AN
	value1 = AlephNum.fix(value1)
	value2 = AlephNum.fix(value2)

	if AlephNum.cmp(value1, value2, "==") then
		return toMeta(zero)
	end

	const valueClone = AlephNum.clone(value2)

	return AlephNum.add(value1, valueClone:neg())
end

-- ~ AlephNum.mul() ~
-- ------------------
-- [?] Multiplies two AlephNum (AN) numbers.
-- [>] Input two (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.mul(value1: AN, value2: AN): AN
	value1 = AlephNum.fix(value1)
	value2 = AlephNum.fix(value2)

	if value1.Sign == 0 or value2.Sign == 0 then
		return toMeta(zero)
	elseif value1.Layer == 0 and value1.Exp == 1 then
		return toMeta(value2)
	elseif value2.Layer == 0 and value2.Exp == 1 then
		return toMeta(value1)
	end

	value1, value2 = AlephNum.normalizeTwo(value1, value2)

	const newSign = value1.Sign * value2.Sign

	if value1.Layer == 0 then
		return toMeta(tupleNum(newSign, 0, value1.Exp * value2.Exp, 1))
	end

	const newExp = value1.Exp + value2.Exp
	const newMantissa = value1.Mantissa * value2.Mantissa
	return toMeta(tupleNum(newSign, value1.Layer, newExp, newMantissa))
end

-- ~ AlephNum.div() ~
-- ------------------
-- [?] Divides two AlephNum (AN) numbers.
-- [>] Input two (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.div(value1: AN, value2: AN): AN
	value1 = AlephNum.fix(value1)
	value2 = AlephNum.fix(value2)

	if value1.Sign == 0 or value2.Sign == 0 then
		if value2.Sign == 0 then
			const scriptName: string, line: string = debugWhere()

			warn(`┏ [AlephNum] Division by zero! Defaulting to zero.`)
			warn(`┗  ╸ Go to script: {scriptName} on line {line} to fix this.`)

			if AlephNum.Config.StrictMode then
				error(`Strict Mode enabled! Halting the script..`, 4)
			end
		end

		return toMeta(zero)
	end

	const newSign = value1.Sign * value2.Sign

	if value1.Layer == 0 and value2.Layer == 0 then
		return toMeta(tupleNum(newSign, 0, value1.Exp / value2.Exp, 1))
	elseif value1.Layer ~= value2.Layer then
		value1, value2 = AlephNum.normalizeTwo(value1, value2)
	end

	const newExp = value1.Exp - value2.Exp
	const newMantissa = value1.Mantissa / value2.Mantissa

	const newValue = tupleNum(newSign, value1.Layer, newExp, newMantissa)

	return toMeta(newValue)
end

-- ~ AlephNum.mod() ~
-- ------------------
-- [?] Gets the modulo of two AlephNum (AN) numbers.
-- [>] Input two (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.mod(value1: AN, value2: AN): AN
	value1 = AlephNum.fix(value1)
	value2 = AlephNum.fix(value2)

	if value2.Sign == 0 then
		const scriptName: string, line: string = debugWhere()

		warn(`┏ [AlephNum] Modulo by zero! Defaulting to zero.`)
		warn(`┗  ╸ Go to script: {scriptName} on line {line} to fix this.`)
		if AlephNum.Config.StrictMode then
			error(`Strict Mode enabled! Halting the script..`, 4)
		end
		return toMeta(zero)
	end

	const div = AlephNum.div(value1, value2):floor()
	const mul = AlephNum.mul(div, value2)

	const result = AlephNum.sub(value1, mul)

	return result
end

-- ~ AlephNum.log10() ~
-- ------------------
-- [?] Gets the log10 of an AN number.
-- [>] Input an AlephNum (AN) value.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.log10(value: AN): AN
	value = AlephNum.fix(value)

	if value.Layer == 0 then
		return AlephNum.fromNumber(math.log10(value.Exp))
	elseif value.Layer == 1 then
		return AlephNum.fromNumber(value.Exp + math.log10(value.Mantissa))
	else
		return toMeta(tupleNum(value.Sign, value.Layer - 1, value.Exp, value.Mantissa))
	end
end

-- ~ AlephNum.log() ~
-- ------------------
-- [?] Gets the log of an AN number.
-- [>] Input two AlephNum (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.log(value: AN, base: AN): AN
	return AlephNum.div(AlephNum.log10(value), AlephNum.log10(base))
end

-- ~ AlephNum.ln() ~
-- ------------------
-- [?] Gets the natural log of an AN number.
-- [>] Input an AlephNum (AN) value.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.ln(value: AN): AN
	return AlephNum.log(value, AlephNum.e)
end

-- ~ AlephNum.exp() ~
-- ------------------
-- [?] Gets the e^x of an AN number.
-- [>] Input an AlephNum (AN) value.
-- [<] Returns an AlephNum (AN) number.
--  * [+] Keep in mind that this isn't precise at higher layers.
function AlephNum.exp(value: AN): AN
	value = AlephNum.fix(value)

	if value.Layer == 0 and value.Exp <= 709.782712893383996843822 then
		return AlephNum.fromNumber(math.exp(value.Sign * value.Exp))
	end

	if value.Layer == 0 then
		return AlephNum.fromTuple(1, 1, value.Sign * math.log10(math.e) * value.Exp, value.Mantissa)
	elseif value.Layer == 1 then
		return AlephNum.fromTuple(1, 2, (value.Sign * math.log10(math.log10(math.e))) + value.Exp, value.Mantissa)
	else
		return AlephNum.fromTuple(1, value.Layer + 1, value.Sign * value.Exp, value.Mantissa)
	end
end

-- ~ AlephNum.pow10() ~
-- ------------------
-- [?] Gets the 10^x of an AN number.
-- [>] Input an AlephNum (AN) value.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.pow10(value: AN): AN
	value = AlephNum.fix(value)

	if value.Layer == 0 then
		if value:is(0) then
			return toMeta(zero)
		end

		if AlephNum.cmp(value, 308, "<") then
			return AlephNum.fromNumber(value.Sign * (10 ^ value.Exp))
		else
			return AlephNum.fromTuple(value.Sign, 1, value.Exp, value.Mantissa)
		end
	else
		return AlephNum.fromTuple(value.Sign, value.Layer + 1, value.Exp + math.log10(value.Mantissa), 1)
	end
end

-- ~ AlephNum.pow() ~
-- ------------------
-- [?] Puts an (AN) to the power of another (AN).
-- [>] Input two (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.pow(base: AN, power: AN): AN
	power = AlephNum.fix(power)
	base = AlephNum.fix(base)

	if power:is(0) then
		return AlephNum.fromNumber(1)
	elseif base:is(0) then
		return toMeta(zero)
	elseif power:is(1) then
		return base
	elseif base:is(10) then
		return AlephNum.pow10(power)
	end

	const abslog10 = AlephNum.abs(AlephNum.log10(base))
	const mul = AlephNum.mul(abslog10, power)

	const pow10 = AlephNum.pow10(mul)

	return pow10
end

-- ~ AlephNum.root() ~
-- ------------------
-- [?] Gets a root of an AN number.
-- [>] Input two (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.root(value: AN, root: AN): AN
	value = AlephNum.fix(value)
	root = AlephNum.fix(root)

	if root:is(0) then
		const scriptName: string, line: string = debugWhere()

		warn(`┏ [AlephNum] Root is zero! Defaulting to zero.`)
		warn(`┗  ╸ Go to script: {scriptName} on line {line} to fix this.`)

		if AlephNum.Config.StrictMode then
			error(`Strict Mode enabled! Halting the script..`, 4)
		end

		return toMeta(zero)
	elseif root:is(1) then
		return value
	else
		return AlephNum.pow(value, AlephNum.div(1, root))
	end
end

-- ~ AlephNum.sqrt() ~
-- ------------------
-- [?] Gets the square root of an AN number.
-- [>] Input an AlephNum (AN) value.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.sqrt(value: AN): AN
	return AlephNum.root(value, 2)
end

-- ~ AlephNum.cbrt() ~
-- ------------------
-- [?] Gets the cube root of an AN number.
-- [>] Input an AlephNum (AN) value.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.cbrt(value: AN): AN
	return AlephNum.root(value, 3)
end

-- ~ AlephNum.fact() ~
-- ------------------
-- [?] Gets the factorial of an AlephNum (AN) number.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
-- * [+] "precise" mode is a lot more precise, but it uses a lot more computation.
function AlephNum.fact(value: AN, precise: boolean?): AN
	value = AlephNum.fix(value)
	precise = (precise or false)

	const two = AlephNum.fromNumber(2)

	if precise then
		const one = AlephNum.fromNumber(1)
		const three = AlephNum.fromNumber(3)
		const four = AlephNum.fromNumber(4)
		const six = AlephNum.fromNumber(6)
		const eight = AlephNum.fromNumber(8)
		const thirty = AlephNum.fromNumber(30)

		return (
			AlephNum.sqrt(AlephNum.pi)
			* ((value / AlephNum.e) ^ value)
			* ((eight * value ^ three + four * value ^ two + value + one / thirty) ^ (one / six))
		)
	end

	const sqrt = AlephNum.sqrt(AlephNum.mul(two, AlephNum.pi) * value)
	const pow = AlephNum.pow(AlephNum.div(value, AlephNum.e), value)

	return AlephNum.mul(sqrt, pow)
end

-- ~ AlephNum.neg() ~
-- ------------------
-- [?] Gets the inverse of an AlephNum (AN) number.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
-- * [+] For the nerds out there you can also use AlephNum.unm
function AlephNum.neg(value: AN)
	value = AlephNum.fix(value)
	value.Sign *= -1

	return value
end

-- ~ AlephNum.unm() ~
-- ------------------
-- [?] Gets the inverse of an AlephNum (AN) number.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
-- * [+] Nerd. Just use AlephNum.neg like a normal person.
function AlephNum.unm(value: AN)
	value = AlephNum.fix(value)
	value.Sign *= -1

	return value
end

-- ~ AlephNum.abs() ~
-- ------------------
-- [?] Gets the absolute value of an AlephNum (AN) number.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.abs(value: AN)
	value = AlephNum.fix(value)

	const clone = AlephNum.clone(value)
	clone.Sign = 1

	if clone:is(0) then
		clone.Sign = 0
	end

	return clone
end

-- ~ AlephNum.clamp() ~
-- ------------------
-- [?] Clamps an (AN) in between two other values.
-- [>] Input three (AN) values.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.clamp(value: AN, lowerLimit: AN, upperLimit: AN): AN
	value = AlephNum.fix(value)
	lowerLimit = AlephNum.fix(lowerLimit)
	upperLimit = AlephNum.fix(upperLimit)

	if value < lowerLimit then
		return lowerLimit
	elseif value > upperLimit then
		return upperLimit
	end

	return value
end

-- ~ AlephNum.floor() ~
-- ------------------
-- [?] Gets the floor of an AlephNum (AN) number.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.floor(value: AN)
	value = AlephNum.fix(value)

	if value.Layer >= 1 then
		return value
	else
		const clone = AlephNum.clone(value)
		clone.Exp = math.floor(clone.Exp)

		return clone
	end
end

-- ~ AlephNum.ceil() ~
-- ------------------
-- [?] Gets the ceil of an AlephNum (AN) number.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.ceil(value: AN)
	value = AlephNum.fix(value)

	if value.Layer >= 1 then
		return value
	else
		const clone = AlephNum.clone(value)
		clone.Exp = math.ceil(clone.Exp)

		return clone
	end
end

-- ~ AlephNum.round() ~
-- ------------------
-- [?] Gets a rounded version of an AlephNum (AN) number.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
function AlephNum.round(value: AN)
	value = AlephNum.fix(value)

	if value.Layer >= 1 then
		return value
	else
		const clone = AlephNum.clone(value)
		clone.Exp = math.round(clone.Exp)

		return clone
	end
end

-- // Aleph Functions \\ --

-- ~ AN:update() ~
-- ------------------
-- [?] Used for development purposes to keep an AN metatable in sync.
-- [>] Input an AlephNum (AN) number.
-- [<] Returns an AlephNum (AN) number.
--  * [+] Not reccomended to use.
function AN:update(result: AN): AN
	self = self :: AN
	self.Mantissa = result.Mantissa
	self.Exp = result.Exp
	self.Layer = result.Layer
	self.Sign = result.Sign

	return self
end

function AN:add(value: AN): AN
	const result = AlephNum.add(self, AlephNum.clone(value))
	self:update(result)

	return self
end

function AN:sub(value: AN): AN
	const result = AlephNum.sub(self, AlephNum.clone(value))
	self:update(result)

	return self
end

function AN:mul(value: AN): AN
	const result = AlephNum.mul(self, AlephNum.clone(value))
	self:update(result)

	return self
end

function AN:div(value: AN): AN
	const result = AlephNum.div(self, AlephNum.clone(value))
	self:update(result)

	return self
end

function AN:pow(power: AN): AN
	const result = AlephNum.pow(self, AlephNum.clone(power))
	self:update(result)

	return self
end

function AN:fact(precise: boolean?): AN
	const result = AlephNum.fact(self, precise)
	self:update(result)

	return self
end

function AN:mod(power: AN): AN
	const result = AlephNum.mod(self, AlephNum.clone(power))
	self:update(result)

	return self
end

function AN:log(base: AN): AN
	const result = AlephNum.log(self, AlephNum.clone(base))
	self:update(result)

	return self
end

function AN:log10(): AN
	const result = AlephNum.log10(self)
	self:update(result)

	return self
end

function AN:root(root: AN): AN
	const result = AlephNum.root(self, AlephNum.clone(root))
	self:update(result)

	return self
end

function AN:sqrt(): AN
	const result = AlephNum.sqrt(self)
	self:update(result)

	return self
end

function AN:cbrt(): AN
	const result = AlephNum.cbrt(self)
	self:update(result)

	return self
end

function AN:neg(): AN
	const result = AlephNum.neg(self)
	self:update(result)

	return self
end

function AN:unm(): AN
	const result = AlephNum.unm(self)
	self:update(result)

	return self
end

function AN:abs(): AN
	const result = AlephNum.abs(self)
	self:update(result)

	return self
end

function AN:floor(): AN
	const result = AlephNum.floor(self)
	self:update(result)

	return self
end

function AN:ceil(): AN
	const result = AlephNum.ceil(self)
	self:update(result)

	return self
end

function AN:clamp(lowerLimit: AN, upperLimit: AN): AN
	const result = AlephNum.clamp(self, AlephNum.clone(lowerLimit), AlephNum.clone(upperLimit))
	self:update(result)

	return self
end

function AN:round(): AN
	const result = AlephNum.round(self)
	self:update(result)

	return self
end

function AN:toNumber(): number
	return AlephNum.toNumber(self)
end

function AN:toString(
	options: { Notation: "None" | "Scientific" | "Suffix", Threshold: number, Digits: number }?
): string
	return AlephNum.toString(self, options)
end

function AN:toSuffix(digits: number?): string
	return AlephNum.toSuffix(self, digits)
end

function AN:toScientific(digits: number?): string
	return AlephNum.toScientific(self, digits)
end

function AN:is(value: any): boolean
	return AlephNum.cmp(self, value, "==")
end

-- ~ Metamethods ~ --

function AlephNum.__add(self: AN, other: AN): AN
	return AlephNum.add(self, other)
end

function AlephNum.__sub(self: AN, other: AN): AN
	return AlephNum.sub(self, other)
end

function AlephNum.__mul(self: AN, other: AN): AN
	return AlephNum.mul(self, other)
end

function AlephNum.__div(self: AN, other: AN): AN
	return AlephNum.div(self, other)
end

function AlephNum.__pow(self: AN, other: AN): AN
	return AlephNum.pow(self, other)
end

function AlephNum.__mod(self: AN, other: AN): AN
	return AlephNum.mod(self, other)
end

function AlephNum.__unm(self: AN): AN
	return AlephNum.unm(self)
end

function AlephNum.__eq(self: AN, other: AN): boolean
	return AlephNum.cmp(self, other, "==")
end

function AlephNum.__lt(self: AN, other: AN): boolean
	return AlephNum.cmp(self, other, "<")
end

function AlephNum.__le(self: AN, other: AN): boolean
	return AlephNum.cmp(self, other, "<=")
end

function AlephNum.__gt(self: AN, other: AN): boolean
	return AlephNum.cmp(self, other, ">")
end

function AlephNum.__ge(self: AN, other: AN): boolean
	return AlephNum.cmp(self, other, ">=")
end

function AlephNum.__neq(self: AN, other: AN): boolean
	return AlephNum.cmp(self, other, "~=")
end

-- ~ Math Constants ~ --

AlephNum.pi = AlephNum.fromNumber(math.pi)
AlephNum.e = AlephNum.fromNumber(math.e)

return AlephNum :: {
	new: typeof(AlephNum.new),
	convert: typeof(AlephNum.convert),

	fromNumber: typeof(AlephNum.fromNumber),
	fromString: typeof(AlephNum.fromString),

	toNumber: typeof(AlephNum.toNumber),
	toString: typeof(AlephNum.toString),
	toSuffix: typeof(AlephNum.toSuffix),
	toScientific: typeof(AlephNum.toScientific),

	add: typeof(AlephNum.add),
	sub: typeof(AlephNum.sub),
	mul: typeof(AlephNum.mul),
	div: typeof(AlephNum.div),
	pow: typeof(AlephNum.pow),
	mod: typeof(AlephNum.mod),

	fact: typeof(AlephNum.fact),

	root: typeof(AlephNum.root),
	sqrt: typeof(AlephNum.sqrt),
	cbrt: typeof(AlephNum.cbrt),

	clamp: typeof(AlephNum.clamp),

	floor: typeof(AlephNum.floor),
	round: typeof(AlephNum.round),
	ceil: typeof(AlephNum.ceil),

	log10: typeof(AlephNum.log10),
	log: typeof(AlephNum.log),

	neg: typeof(AlephNum.neg),
	unm: typeof(AlephNum.unm),

	clone: typeof(AlephNum.clone),
	fix: typeof(AlephNum.fix),

	cmp: typeof(AlephNum.cmp),

	setConfig: typeof(AlephNum.setConfig),
	Config: typeof(AlephNum.Config),

	pi: typeof(AlephNum.pi),
	e: typeof(AlephNum.e),
}
