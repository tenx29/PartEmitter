local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Utils = require(script.Parent.Utils)
local Particle = require(script.Parent.Particle)
local Emitter = {}
Emitter.__index = Emitter

-- Store all existing emitters in a table in case the user needs to access all emitters at once
local Emitters = {}

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

    -- Data properties
    Parent = nil,

    -- Emission properties (Note that enabling must be done with a method, setting Enabled = true is not enough!)
    EmissionDirection = Enum.NormalId.Top,
    Enabled = false,
    Lifetime = NumberRange.new(5, 10),
    Rate = 20,
    Rotation = NumberRange.new(0,0),
    RotSpeed = NumberRange.new(0,0),
    Speed = NumberRange.new(5,5),
    -- SpreadAngle is not yet implemented

    -- Shape properties
    Shape = Enum.ParticleEmitterShape.Sphere,
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
        
    }

    -- Apply the default properties inherited from ParticleEmitter
    self.Properties = {}
    for propertyName, defaultValue in pairs(EmitterDefaultProperties) do
        self.Properties[propertyName] = defaultValue
    end

    -- Table to keep track of all currently existing particles
    self.Particles = {}

    -- Collision-related properties inherited from BasePart
    self.PhysicalProperties = {}
    self.PhysicalProperties.PartType = Enum.PartType.Block
    self.PhysicalProperties.CanCollide = false
    self.PhysicalProperties.CanTouch = false
    self.PhysicalProperties.CanQuery = false

    -- Properties specific to a Physical Particle Emitter
    self.UseWorkspaceGravity = false    -- If enabled, particles will act like physical parts that are affected by gravity and can't go through walls. Overrides Acceleration.
    self.CollisionGroup = nil           -- Collision group of the particles
    self.MaxEmissionsPerHeartbeat = 1   -- How many particles can be emitted in a single Heartbeat. Only increase if necessary.

    -- Emit particles
    self.LastEmission = tick()
    self.HeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if self.LastEmission >= 1/self.Rate then
            local emitCount = self.Rate/(self.LastEmission-tick())
            self:Emit(math.min(emitCount, self.MaxEmissionsPerHeartbeat))
        end
    end)

    Emitters[self.UUID] = self
    return self
end


-- Set the Physical Particle Emitter properties based on the properties of a ParticleEmitter instance.
-- Note that the value of the Enabled property is ignored!
function Emitter:LoadPropertiesFromParticleEmitter(ParticleEmitter: ParticleEmitter)
    for propertyName, _ in pairs(EmitterDefaultProperties) do
        if not propertyName == "Enabled" then
            self.Properties[propertyName] = ParticleEmitter[propertyName]
        end
    end
end


-- Emit a number of particles from the emitter
function Emitter:Emit(ParticleCount: number?)
    ParticleCount = ParticleCount or 1
    assert(ParticleCount >= 0, "Particle count can not be negative")

end


-- Destroy the Physical Particle Emitter
function Emitter:Destroy()
    
end

return Emitter