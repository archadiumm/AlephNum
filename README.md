<div align="center">
	<h1><img src="https://github.com/archadiumm/AlephNum/blob/master/assets/alephnum-title.png" width="380" style="display: block; margin: 0 auto; padding: 0;"></h1>
	<p><i>Calculate numbers up to </i><code>10 ↑↑↑ 16</code><a href="https://github.com/archadiumm/AlephNum#alephnums-limit">*</a></p>
</div>

> [!CAUTION]
> AlephNum is having issues with suffixes and certain math functions right now. Please wait until 1.6.0 to use again.

# About
AlephNum is a luau number library inspired from other libraries like **EternityNum**, **InfiniteMath**, and **Hypercalc**. To put it simply, AlephNum is a luau library that can handle very VERY big numbers. It is mainly intended for incremental games, but can also be used in any luau project that needs to go past the number limits.

As of right now, AlephNum currently supports many math functions, high precision, customizable config, leaderboard encoding/decoding, metamethods (and methods), and more.

# Installation
To download the library in the form of a [**wally dependency**](https://wally.run/package/archadiumm/alephnum), please copy and paste the text below into the dependencies list.
```md
AlephNum = "archadiumm/alephnum@1.5.3"
```

For other installation methods, please go to the [latest release](https://github.com/archadiumm/AlephNum/releases/latest).

## Support
If you encounter any bugs, please send them to my [discord](https://discord.com/users/584603465431515156), message me on [GitHub](https://github.com/archadiumm), whatever you do I will try to fix it asap.

## Quick Start
After installing AlephNum, you can create, compare, and do operations on numbers like shown in the example:
```luau
-- ~ Number Creation ~ --
const new = AlephNum.new(100) -- Returns an AN equivalent to 100
const fromNumber = AlephNum.fromNumber(1e100) -- Returns an AN equivalent to 10^100
const fromString = AlephNum.fromString("1e1e100") -- Returns an AN equivalent to 10^(10^100)

-- ~ Comparisons ~ --
const greater = AlephNum.cmp("1e100", "2e100", ">") -- Does "1e100" > "2e100". Returns false.
const equal = AlephNum.cmp(3e100, AlephNum.fromString("3e100"), "==") -- Does "3e100" == "3e100". Returns true.
const quicker = new < fromNumber -- Works if both values are an AN (AlephNum). Returns true here.

-- ~ Operations ~ --
new:pow(100) -- Sets new to new^100. This is mutable (changes the original variable's value).
const new2 = new * 100 -- Multiplies new by 100. This is immutable. new remains unchanged.
const addition = AlephNum.add(1, 2) -- Does 1 + 2. Self-explanatory.

-- ~ Conversions ~ --
print(AlephNum.fromNumber(1e8):toSuffix()) -- Prints "100M"
print(AlephNum.toScientific(100000000000000000000)) -- Prints "1e20"
```
> AlephNum handles many math functions, and in the next update will be able to handle slogs, tetration and (maybe) pentation.

By the way, there is a config (`AlephNum.setConfig`/`AlephNum.Config`) that you can use to set default notation, threshold, etc.
# Number Format
AlephNum's number format was heavily inspired by EternityNum's. Each AN (AlephNum number) is a table of 4 values.
```luau
{ Sign: number, Layer: number, Exp: number, Mantissa: number }
```
* **Sign** - The sign of the number. Can be 1, -1, or 0.
* **Layer** - How many times 10 is exponentiated in the tower above E. Look at the Number Values section below for more info.
* **Exp** - Short for "Exponent". In layer 0 numbers, Exp is basically the number's value, but in layer 1 numbers for example, it grows. (10^Exp)
* **Mantissa** - Used for layer 1+ numbers. In a number like 1.8e10 for example, 1.8 would be the mantissa, and 10 would be the exp.

## Number Values
* **Layer _N_**: Value = S * M * (a tower of N tens with E at the top)

* **Layer 0**:    Value = `S * M * E`
* **Layer 1**:    Value = `S * M * 10^E`
* **Layer 2**:    Value = `S * M * 10^(10^E)`
* _it keeps going.._

## AlephNum's Limit
> [!CAUTION]
> Certain numbers above <code>10 ↑↑ (1e308)</code> have been shown to have overflow bugs. Be patient while I try to fix this.

The reason why **EternityNum** and other libraries max out at about <code>10↑↑(1e308)</code> is because `1e308` is the highest number roblox can handle.

AlephNum solves this problem by making the layer an AN every time it gets to inf. This keeps going until the set depth limit, which in AlephNum's case is **16** by default.

Numbers can go higher than this if you change the depth limit, but there's no use for numbers past `10 ↑↑↑ 3` even, let alone `10 ↑↑↑ 16`. Along with that, numbers kind of get a bit buggy at that point, and leaderboard encoding becomes impossible.

## Why?
Look, I will be honest. AlephNum being able to go past other previous limits like `1e308`, <code>10 ↑↑ (1e308)</code>, and all the way up to `10 ↑↑↑ 16` was not my main priority at all. It wasn't even the thing I worked hardest on.

The thing I worked hardest on was making the user experience as enjoyable as possible. I've used **EternityNum**, **Quicknum**, **QubitNum**, **InfiniteMath**, etc. and I have just had problems with them. Some were too slow, too clunky, had messy source code, terrible number limits, all of the above sometimes. I wanted to make this for you guys, as my first genuine project.

* If an error happens in any of those libraries, they wont tell you why and how to fix it. **AlephNum does.**
* They are too clunky to write with, **AlephNum isn't.**
* Some have bad suffix systems, bad formatting, terrible types, etc.. **AlephNum fixes that.**

I know AlephNum isn't perfect, but I am trying to make it that way for you guys.

Nobody may ever have a game that even gets close to `10 ↑↑↑ 16`, and thats okay. All I wanted was for developers like me to be able to produce games I like _(incrementals, simulators, etc.)_ a lot better.
