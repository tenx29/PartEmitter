local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Utils = require(script.Parent.Utils)
local Random = Random.new()
local Particle = {}
Particle.__index = Particle


-- Constructor function.
function Particle.new(ParticleProperties: {}, PhysicalProperties: {}, Position: Vector3, Velocity: Vector3, IsRigidBody: boolean?, Parent: Instance?)
    local self = {}
    setmetatable(self, Particle)

    -- UUID to identify the particle
    self.UUID = HttpService:GenerateGUID(false)

    -- BindableEvents for the user to use
    self.__events = {
        Destroying = Instance.new("BindableEvent")
    }
    self.Destroying = self.__events.Destroying.Event

    -- Parse NumberSequence envelopes.
    ParticleProperties.Size = Utils.parseNSEnvelopes(ParticleProperties.Size)
    ParticleProperties.Squash = Utils.parseNSEnvelopes(ParticleProperties.Squash)
    ParticleProperties.Transparency = Utils.parseNSEnvelopes(ParticleProperties.Transparency)

    -- Create the ParticleEmitter used to show the particle and apply the given properties.
    self.ParticleEmitter = Instance.new("ParticleEmitter")
    for name, value in pairs(ParticleProperties) do
        if name == "Lifetime" then  -- Decide the particle's lifetime at this point
            value = Random:NextNumber(value.Min, value.Max)
        end
        self[name] = value
        self.ParticleEmitter[name] = value
    end

    -- Set some properties of the emitter to values that should not be changed.
    self.ParticleEmitter.Enabled = false
    self.ParticleEmitter.Speed = 0
    self.ParticleEmitter.Acceleration = Vector3.new(0,0,0)
    self.ParticleEmitter.LockedToPart = true
    
    -- Create a Part that acts as the collision box for the particle
    self.Part = Instance.new("Part")
    self.Part.Name = "__PARTICLE_"..self.UUID
    self.Part.CFrame = CFrame.new(Position)
    self.Part.Size = Vector3.new(1,1,1) * Utils.evalNS(self.Size, 0)
    self.Part.Transparency = 1
    self.Part.Shape = PhysicalProperties.PartType
    self.Part.CanCollide = PhysicalProperties.CanCollide
    self.Part.CanTouch = PhysicalProperties.CanTouch
    self.Part.CanQuery = PhysicalProperties.CanQuery
    self.Part.Anchored = not IsRigidBody

    -- Set the Part's collision group if it exists
    if PhysicalProperties.CollisionGroup then
        PhysicsService:SetPartCollisionGroup(self.Part, PhysicalProperties.CollisionGroup)
    end

    -- Create an attachment in the centre of the Part which will define the ParticleEmitter's position.
    self.Attachment = Instance.new("Attachment")
    self.Attachment.Parent = self.Part
    self.ParticleEmitter.Parent = self.Attachment
    self.Part.Parent = Parent

    self.Velocity = Velocity

    -- Simulate the particle
    self.CreationTime = tick()
    self.ParticleEmitter:Emit(1)
    if IsRigidBody then
        self.Part.AssemblyAngularVelocity = Velocity
    end
    self.HeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        local age = tick()-self.CreationTime
        self.Part.Size = Utils.evalNS(self.Size, age/self.Lifetime)
        if not IsRigidBody then
            -- Move the part in the direction of Velocity and make it look in the direction it's going, then apply Acceleration
            self.Part.CFrame = CFrame.new(self.Part.Position + self.Velocity*deltaTime, self.Part.Position + self.Velocity*deltaTime*2)
            self.Velocity += deltaTime*self.Acceleration
        end
        if age >= self.Lifetime then
            self:Destroy()
        end
    end)

    return self
end


-- Destroy the particle.
function Particle:Destroy()
    self.__events.Destroying:Fire()
    if self.HeartbeatConnection then
        self.HeartbeatConnection:Disconnect()
    end
    -- Destroy all instances used by the object separately in case the user has changed their ancestry.
    self.ParticleEmitter:Destroy()
    self.Attachment:Destroy()
    self.Part:Destroy()
    self = nil
end

return Particle