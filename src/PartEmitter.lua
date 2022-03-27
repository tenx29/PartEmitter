local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Utils = require(script.Parent.Utils)
local Particle = require(script.Parent.Particle)

local random = Random.new()

local Emitter = {}
Emitter.__index = Emitter


-- Dictionary of default values for a particle emitter, also used for easily iterating over ParticleEmitter properties
local EmitterDefaultProperties = {
    -- Appearance properties
    Brightness = 1,
    Color = ColorSequence.new(Color3.new(1,1,1)),
    LightEmission = 0,
    LightInfluence = 1,
    Orientation = Enum.ParticleOrientation.FacingCamera,
    Size = NumberSequence.new(1),
    Squash = NumberSequence.new(0),
    Texture = "rbxasset://textures/particles/sparkles_main.dds",
    Transparency = 0,
    ZOffset = 0,

    -- Emission properties
    EmissionDirection = Enum.NormalId.Top,
    Lifetime = NumberRange.new(5, 10),
    Rate = 20,
    Rotation = NumberRange.new(0,0),
    RotSpeed = NumberRange.new(0,0),
    Speed = NumberRange.new(5,5),
    -- SpreadAngle is not yet implemented

    -- Shape properties
    Shape = Enum.ParticleEmitterShape.Sphere,   -- Only Box is fully supported, Sphere just uses the smallest size coordinate as its radius.
    ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
    ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,

    -- Motion properties
    Acceleration = Vector3.new(0,0,0)

    -- Particle properties like Drag and LockedToPart will be implemented later when I figure out the best way to do it.
    -- That is, if I don't forget about it.
}


-- Constructor function.
function Emitter.new()
    local self = {}
    setmetatable(self, Emitter)

    -- Unique identifier for this particle emitter (makes deleting it faster, for example)
    self.UUID = HttpService:GenerateGUID(false)

    -- Bindable events for the user
    self.__events = {
        ParticleAdded = Instance.new("BindableEvent"),
        ParticleRemoving = Instance.new("BindableEvent"),
        Destroying = Instance.new("BindableEvent")
    }
    self.ParticleAdded = self.__events.ParticleAdded.Event
    self.ParticleRemoving = self.__events.ParticleRemoving.Event
    self.Destroying = self.__events.Destroying.Event

    -- Apply the default properties inherited from ParticleEmitter
    for propertyName, defaultValue in pairs(EmitterDefaultProperties) do
        self[propertyName] = defaultValue
    end
    self.Parent = nil
    self.ParticleContainer = nil
    self.Enabled = false

    -- Table to keep track of all currently existing particles
    self.Particles = {}

    -- Collision-related properties inherited from BasePart
    self.PartType = Enum.PartType.Block
    self.CanCollide = false
    self.CanTouch = false
    self.CanQuery = false

    -- Properties specific to a Physical Particle Emitter
    self.IsRigidBody = false            -- If enabled, particles will act like physical parts that are affected by gravity and can't go through walls if collision is enabled. Overrides Acceleration.
    self.CollisionGroup = nil           -- Collision group of the particles
    self.MaxEmissionsPerHeartbeat = 1   -- How many particles can be emitted in a single Heartbeat. Only increase if necessary. If the script attempts to emit more than this per Heartbeat, those that go over the limit are ignored.

    -- Emit particles
    self.LastEmission = tick()
    self.HeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if self.Enabled and tick()-self.LastEmission >= 1/self.Rate then
            local emitCount = math.floor(self.Rate*(tick()-self.LastEmission))
            if math.min(emitCount, self.MaxEmissionsPerHeartbeat) > 0 then
                self:Emit(math.min(emitCount, self.MaxEmissionsPerHeartbeat))
                self.LastEmission = tick()
            end
        end
    end)

    return self
end


-- Set the Physical Particle Emitter properties based on the properties of a ParticleEmitter instance.
function Emitter:LoadPropertiesFromParticleEmitter(ParticleEmitter: ParticleEmitter, SetParent: boolean?)
    for propertyName, _ in pairs(EmitterDefaultProperties) do
        self[propertyName] = ParticleEmitter[propertyName]
    end
    if SetParent then
        self.Parent = ParticleEmitter.Parent
    end
end


-- Emit a number of particles from the emitter
function Emitter:Emit(EmissionCount: number?)
    -- Don't emit particles if the parent isn't a BasePart
    if not self.Parent then return nil end
    if not self.Parent:IsA("BasePart") then return nil end

    EmissionCount = EmissionCount or 1
    assert(EmissionCount >= 0, "Particle count can not be negative")

    local style = self.ShapeStyle
    local shape = self.Shape
    local origin = self.Parent.Position
    local size = self.Parent.Size
    local radius = math.min(size.X, size.Y, size.Z)

    -- Collect relevant properties into tables that will be sent to the Particle constructor
    local ParticleProperties = {}
    for name, _ in pairs(EmitterDefaultProperties) do
        ParticleProperties[name] = self[name]
    end
    local PhysicalProperties = {
        PartType = self.PartType,
        CanCollide = self.CanCollide,
        CanTouch = self.CanTouch,
        CanQuery = self.CanQuery,
        CollisionGroup = self.CollisionGroup
    }

    -- Emit the amount of particles equal to EmissionCount
    for i=1, EmissionCount do
        local speed = random:NextNumber(self.Speed.Min, self.Speed.Max)

        local emissionPoint

        -- Determine emission point
        if style == Enum.ParticleEmitterShapeStyle.Surface then
            if shape == Enum.ParticleEmitterShape.Box then
                emissionPoint = Utils.getRandomPointOnSurface(self.Parent, self.EmissionDirection).Position
            elseif shape == Enum.ParticleEmitterShape.Sphere then
                emissionPoint = origin + Utils.getRandomPointInSphere(radius, radius)
            end
        elseif shape == Enum.ParticleEmitterShape.Box then
            emissionPoint = origin + Utils.getRandomPointInBox(size, self.Parent.CFrame)
        elseif shape == Enum.ParticleEmitterShape.Sphere then
            emissionPoint = origin + Utils.getRandomPointInSphere(0, radius)
        end

        assert(emissionPoint, tostring(shape).." is not a supported ParticleEmitterShape")   -- Throw an error if no emission point could be resolved

        -- Determine emission velocity
        local velocity
        local normal = self.Parent.CFrame * Vector3.FromNormalId(self.EmissionDirection) - self.Parent.Position
        if shape == Enum.ParticleEmitterShape.Box then
            velocity = speed*normal
        elseif shape == Enum.ParticleEmitterShape.Sphere then
            velocity = (emissionPoint - origin).Unit*speed
        end

        assert(emissionPoint, tostring(shape).." is not a supported ParticleEmitterShape")  -- This should not happen at this point but it never hurts to make sure

        if self.ShapeInOut == Enum.ParticleEmitterShapeInOut.Inward then     -- Emission should happen inward only, so flip the velocity direction
            velocity *= -1
        elseif self.ShapeInOut == Enum.ParticleEmitterShapeInOut.InAndOut and random:NextNumber() >= 0.5 then    -- Emission should happen both inward and out, so flip the velocity direction with a 50% chance.
            velocity *= -1
        end

        local particle = Particle.new(ParticleProperties, PhysicalProperties, emissionPoint, velocity, self.IsRigidBody, self.ParticleContainer or self.Parent)
        self.Particles[particle.UUID] = particle
        self.__events.ParticleAdded:Fire(particle)
        particle.Destroying:Connect(function()
            self.__events.ParticleRemoving:Fire(particle)
            self.Particles[particle.UUID] = nil
        end)
    end
end


-- Clear all particles currently owned by this emitter
function Emitter:Clear()
    for _, p in pairs(self.Particles) do
        p:Destroy()
    end
end


-- Destroy the Physical Particle Emitter
function Emitter:Destroy()
    self:Clear()
    self.__events.Destroying:Fire()
    setmetatable(self, nil)
    self = nil
end

return Emitter