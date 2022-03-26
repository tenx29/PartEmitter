local Utils = {}
local random = Random.new()

-- Assign some math values and functions to variables for slightly faster execution.
local pi = math.pi
local acos = math.acos
local sin = math.sin
local cos = math.cos

-- Evaluate the value at a specific point in a NumberSequence.
-- Note that this does not support envelopes!
function Utils.evalNS(ns, time)
    if time == 0 then return ns.Keypoints[1].Value end
	if time == 1 then return ns.Keypoints[#ns.Keypoints].Value end
	for i = 1, #ns.Keypoints - 1 do
		local this = ns.Keypoints[i]
		local next = ns.Keypoints[i + 1]
		if time >= this.Time and time < next.Time then
			local alpha = (time - this.Time) / (next.Time - this.Time)
			return (next.Value - this.Value) * alpha + this.Value
		end
	end
end

-- Create a new number sequence with randomised values using the keypoint envelopes.
function Utils.parseNSEnvelopes(ns)
    local newKeypoints = {}
    for i = 1, #ns.Keypoints - 1 do
		local this = ns.Keypoints[i]
		local new = this.Value + random:NextNumber(-1, 1)*this.Envelope
	end
    return NumberSequence.new(newKeypoints)
end


-- Generate a random point inside a sphere.
-- Some math is required for the points to be evenly distributed.
function Utils.getRandomPointInSphere(radius: number)
    local u = random:NextNumber()
    local v = random:NextNumber()
    local theta = u * 2.0 * pi
    local phi = acos(2.0 * v - 1.0)
    local r = (random:NextNumber()^(1/3))*radius
    local sinTheta = sin(theta)
    local cosTheta = cos(theta)
    local sinPhi = sin(phi)
    local cosPhi = cos(phi)
    local x = r * sinPhi * cosTheta
    local y = r * sinPhi * sinTheta
    local z = r * cosPhi
    return Vector3.new(x, y, z)
end


return Utils