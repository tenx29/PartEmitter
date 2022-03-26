local RunService = game:GetService("RunService")
local Emitter = {}
Emitter.__index = Emitter

-- Store all existing emitters in a table in case the user needs to access all emitters at once
local Emitters = {}

-- Dictionary of default values for a particle emitter, also used for easily iterating over ParticleEmitter properties
local EmitterDefaultProperties = {
    -- Appearance properties
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

    -- Apply the default properties inherited from ParticleEmitter
    for propertyName, defaultValue in pairs(EmitterDefaultProperties) do
        self[propertyName] = defaultValue
    end

    -- Table to keep track of all currently existing particles
    self.Particles = {}
    
    -- Particle emission thread
    self.Thread = coroutine.create(function()
        local heartbeatConnection   -- Silence unknown global warning inside the coroutine
        heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not self.Enabled then
                heartbeatConnection:Disconnect()
            end
            
        end)
    end)

    -- Collision-related properties inherited from BasePart
    self.CanCollide = false
    self.CanTouch = false
    self.CanQuery = false

    -- Properties specific to a Physical Particle Emitter
    self.UseWorkspaceGravity = false    -- If enabled, Workspace gravity is added to Acceleration
    self.IgnoreSkippedParticles = true  -- If disabled, the emitter will try to catch up by emitting several particles at once if it emitted too few particles during last Heartbeat

    return self
end

-- Set the Physical Particle Emitter properties based on the properties of a ParticleEmitter instance.
-- Note that the value of the Enabled property is ignored!
function Emitter:LoadPropertiesFromParticleEmitter(ParticleEmitter: ParticleEmitter)
    for propertyName, _ in pairs(EmitterDefaultProperties) do
        if not propertyName == "Enabled" then
            self[propertyName] = ParticleEmitter[propertyName]
        end
    end
end

-- Emit a number of particles from the emitter
function Emitter:Emit(ParticleCount: number?)
    ParticleCount = ParticleCount or 1
    assert(ParticleCount >= 0, "Particle count can not be negative")

end

return Emitter