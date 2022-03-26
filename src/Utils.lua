local Utils = {}
local random = Random.new()

-- Assign some math values and functions to variables for slightly faster execution.
local pi = math.pi
local acos = math.acos
local sin = math.sin
local cos = math.cos

-- Evaluate the value at a specific point in a NumberSequence.
-- Note that this does not support envelopes!
function Utils.evalNS(ns, time): number
    if time <= 0 then return ns.Keypoints[1].Value end
	if time >= 1 then return ns.Keypoints[#ns.Keypoints].Value end
	for i = 1, #ns.Keypoints - 1 do
		local this = ns.Keypoints[i]
		local next = ns.Keypoints[i + 1]
		if time >= this.Time and time < next.Time then
			local alpha = (time - this.Time) / (next.Time - this.Time)
			return (next.Value - this.Value) * alpha + this.Value
		end
	end
end


-- Generate a random point inside a sphere.
-- Some math is required for the points to be evenly distributed.
function Utils.getRandomPointInSphere(minRadius: number, maxRadius: number): Vector3
    local radius = random:NextNumber(minRadius, maxRadius)
    local u = random:NextNumber()
    local v = random:NextNumber()
    local theta = u * 2.0 * pi
    local phi = acos(2.0 * v - 1.0)
    local r

	if minRadius == maxRadius then
		r = radius
	else
		r  = (random:NextNumber(minRadius/maxRadius, 1)^(1/3))*radius
	end

    local sinTheta = sin(theta)
    local cosTheta = cos(theta)
    local sinPhi = sin(phi)
    local cosPhi = cos(phi)
    local x = r * sinPhi * cosTheta
    local y = r * sinPhi * sinTheta
    local z = r * cosPhi
    return Vector3.new(x, y, z)
end

-- Generate a random point inside a box.
function Utils.getRandomPointInBox(Size: Vector3, BoxCFrame: CFrame?): Vector3
    local offset = Vector3.new(Size.X*random:NextNumber(-0.5,0.5), Size.Y*random:NextNumber(-0.5,0.5), Size.Z*random:NextNumber(-0.5,0.5))
    if BoxCFrame then
        return (BoxCFrame.RightVector*offset.X + BoxCFrame.UpVector*offset.Y + BoxCFrame.LookVector*offset.Z)
    else
        return offset
    end
end


-- Function by nicemike40 on the DevForum
-- Get a surface's CFrame and size
function Utils.getWorldOrientedSurface(part: BasePart, normalId: Enum.NormalId): (CFrame, Vector2)
	local cf = part.CFrame
	local rot = cf - cf.Position
	
	local nObject = Vector3.fromNormalId(normalId)
	local nWorld = rot * nObject
	
	-- get orthogonal vector by utilizing the order of NormalId enums
	-- i.e. Front.Value is 5 -> (5+1)%6 = 0 -> Right.Value
	local xWorld = rot * Vector3.fromNormalId((normalId.Value + 1) % 6)
	
	-- get other orthogonal vector
	local zWorld = nWorld:Cross(xWorld)
	
	-- make them both point "generally down"
	if xWorld.Y > 0 then xWorld = -xWorld end
	if zWorld.Y > 0 then zWorld = -zWorld end
	
	-- choose the one pointing "more down" one as the z axis for the surface
	if xWorld.Y < zWorld.Y then zWorld = xWorld end
	
	-- redefine x axis based on that
	xWorld = nWorld:Cross(zWorld)
	
	local surfaceRot = CFrame.fromMatrix(Vector3.new(), xWorld, nWorld, zWorld)

	-- get width of part in direction of x and y
	local sizeInWorldSpace = rot * part.Size
	local sizeInSurfaceSpace = surfaceRot:Inverse() * sizeInWorldSpace
	
	-- get position on surface
	local surfaceCFrame = surfaceRot + cf.Position + nWorld * math.abs(sizeInSurfaceSpace.Y) / 2

	return surfaceCFrame, Vector2.new(math.abs(sizeInSurfaceSpace.X), math.abs(sizeInSurfaceSpace.Z))
end


-- Get a random point on a Part surface.
function Utils.getRandomPointOnSurface(Part: BasePart, NormalId: Enum.NormalId): Vector3
    local SurfaceCFrame, SurfaceSize = Utils.getWorldOrientedSurface(Part, NormalId)
    local SurfaceXOffset = SurfaceCFrame.RightVector * SurfaceSize.X*random:NextNumber(-0.5, 0.5)
    local SurfaceYOffset = SurfaceCFrame.LookVector * SurfaceSize.Y*random:NextNumber(-0.5, 0.5)
    return SurfaceCFrame + SurfaceXOffset + SurfaceYOffset
end


return Utils