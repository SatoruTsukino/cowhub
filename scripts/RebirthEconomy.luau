--!strict
--[[
	RebirthEconomy — calorie cost to go from rebirth r to r + 1.

	r <= PIVOT  : classic curve, BASE_REQUIREMENT * GROWTH_RATE^r (exact integers).
	r >  PIVOT  : Model 2 log-time. Target play-time per tier is
	                  T(r) = T0_HOURS + A_HOURS * ln(1 + (r - PIVOT))
	              and the requirement is T(r) * income(r). Income grows by
	              INCOME_GROWTH per rebirth, so anchored on the pivot tier:
	                  Req(r) = Req(PIVOT) * INCOME_GROWTH^(r - PIVOT) * T(r) / T0
	              This ratio form is continuous at the pivot by construction and
	              needs no hand-calibrated cal/sec constant (the old 1856.7 was
	              just Req(PIVOT) / (T0 * 3600 * 1.22^PIVOT)).

	Target hours (r -> r+1): R20 29.4, R21 37.7, R22 42.6, R23 46.0, R24 48.7.
]]

local RebirthEconomy = {}

local BASE_REQUIREMENT = 10_000
local GROWTH_RATE = 2
-- Must equal 1 + Config.Rebirth.CaloriesMultiplierPerRebirth; read from Config if available.
local INCOME_GROWTH = 1.22
local PIVOT = 20
local T0_HOURS = 29.4
local A_HOURS = 12
local SIGNIFICANT_DIGITS = 3
-- Keeps INCOME_GROWTH^dr finite (overflow ~r 3570) and inputs bounded.
local MAX_REBIRTH = 1_000

local PIVOT_REQUIREMENT = BASE_REQUIREMENT * GROWTH_RATE ^ PIVOT -- 10,485,760,000 (exact)
local LOG_GAIN = A_HOURS / T0_HOURS

-- Rounds a positive finite number to `digits` significant figures.
local function roundSignificant(x: number, digits: number): number
	local magnitude = 10 ^ (math.floor(math.log10(x)) - digits + 1)
	return math.round(x / magnitude) * magnitude
end

function RebirthEconomy.GetRebirthRequirement(rebirthCount: number): number
	-- NaN -> 0; ±inf, negative, fractional -> integer in [0, MAX_REBIRTH].
	if rebirthCount ~= rebirthCount then
		rebirthCount = 0
	end
	local r = math.clamp(math.floor(rebirthCount), 0, MAX_REBIRTH)

	if r <= PIVOT then
		return BASE_REQUIREMENT * GROWTH_RATE ^ r
	end

	local deltaR = r - PIVOT
	local timeScale = 1 + LOG_GAIN * math.log(1 + deltaR)
	return roundSignificant(PIVOT_REQUIREMENT * INCOME_GROWTH ^ deltaR * timeScale, SIGNIFICANT_DIGITS)
end

return RebirthEconomy
