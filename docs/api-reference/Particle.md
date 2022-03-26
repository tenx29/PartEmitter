# Particle
A Particle is an object that represents a single Particle, usually created by a PartEmitter.

<br><br>

## Creating a new Particle
---
### [Particle](Particle.md) Particle.new([table](https://developer.roblox.com/en-us/api-reference/lua-docs/table) *<span style="color: grey">particleProperties</span>*, [table](https://developer.roblox.com/en-us/api-reference/lua-docs/table) *<span style="color: grey">physicalProperties</span>*, [Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3) *<span style="color: grey">position</span>*, [Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3) *<span style="color: grey">velocity</span>*, [boolean](https://developer.roblox.com/en-us/articles/Boolean) *<span style="color: grey">isRigidBody?</span>*, [Instance](https://developer.roblox.com/en-us/api-reference/class/Instance) *<span style="color: grey">parent?</span>*)
Creates a new Particle object. ParticleProperties includes information on how the Particle should look and act, physicalProperties contains information on collisions, position is the position where the Particle will spawn, velocity is the Particle's intial velocity, isRigidBody determines if the Particle will act like a rigid body object and parent determines the Particle's parent.
!!! warning "Important"
    This is a constructor function mainly used by the **[PartEmitter](PartEmitter.md)** class. Generally speaking there is no need for the user to use this function.

<br><br>

## Properties
---
### [string](https://developer.roblox.com/en-us/articles/String) UUID
A unique identifier for this Particle.

---
### [ParticleEmitter](https://developer.roblox.com/en-us/api-reference/class/ParticleEmitter) ParticleEmitter
The ParticleEmitter used to emit a single particle, which will then stay locked to the Particle's Part.

---
### [BasePart](https://developer.roblox.com/en-us/api-reference/class/BasePart) Part
This Part acts as the collider for this Particle.

---
### [Attachment](https://developer.roblox.com/en-us/api-reference/class/Attachment) Attachment
Attachment in the centre of the Part, acting as the Parent for the ParticleEmitter. This ensures the visible particle is exactly where it's collider is.

---
### [Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3) Velocity
Velocity vector of the Particle.
!!! note
    If **[IsRigidBody](#boolean-isrigidbody-false)** is true, Velocity will only be applied initally when the Particle is created. After that the Particle's movement will be entirely controlled by the physics engine.

---
### [Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3) Acceleration
Constant acceleration applied to the Particle.
!!! warning
    This property is overridden if **[IsRigidBody](#boolean-isrigidbody-false)** is true.

---
### [float](https://developer.roblox.com/en-us/articles/Numbers) CreationTime
Time when the Particle was created.

---
### [RBXScriptConnection](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptConnection) HeartbeatConnection
This Particle's connection to the [Heartbeat](https://developer.roblox.com/en-us/api-reference/event/RunService/Heartbeat) event. Used for updating the Particle's position and Part size, as well as removing the Particle once it reaches its assigned lifetime.

<br><br>

## Methods
---
### [void](#methods) Destroy()
Destroys all instances associated with the Particle and the Particle object itself. This method is also called automatically when the Particle's age reaches its lifetime.

<br><br>

## Events
---
### [RBXScriptSignal](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptSignal) Destroying()
This event fires when the Particle's [Destroy](#void-destroy) method is called.