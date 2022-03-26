# Utils
A simple utility module with some required functions.

## Functions
---
### [float](https://developer.roblox.com/en-us/articles/Numbers) evalNS([NumberSequence](https://developer.roblox.com/en-us/api-reference/datatype/NumberSequence) *<span style="color: grey">numberSequence</span>*, [float](https://developer.roblox.com/en-us/articles/Numbers) *<span style="color: grey">time</span>*)
Evaluate a NumberSequence's value at the given time.

---
### [Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3) getRandomPointInSphere([float](https://developer.roblox.com/en-us/articles/Numbers) *<span style="color: grey">minRadius</span>*, [float](https://developer.roblox.com/en-us/articles/Numbers) *<span style="color: grey">maxRadius</span>*)
Get a random point inside a sphere that is more than minRadius and less than maxRadius units away from the sphere origin.

---
### [Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3) getRandomPointInBox([Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3): size, [CFrame](https://developer.roblox.com/en-us/api-reference/datatype/CFrame) CFrame?)
Get a ranom point inside a box with the given dimensions. If CFrame is given, take the box orientation into account.

---
### [CFrame](https://developer.roblox.com/en-us/api-reference/datatype/CFrame), [Vector2](https://developer.roblox.com/en-us/api-reference/datatype/Vector2) getWorldOrientedSurface([BasePart](https://developer.roblox.com/en-us/api-reference/class/BasePart) *<span style="color: grey">part</span>*, [NormalId](https://developer.roblox.com/en-us/api-reference/enum/NormalId) *<span style="color: grey">normalId</span>*)
Get the CFrame and dimensions of a surface on a BasePart.

---
### [Vector3](https://developer.roblox.com/en-us/api-reference/datatype/Vector3) getRandomPointOnSurface([BasePart](https://developer.roblox.com/en-us/api-reference/class/BasePart) *<span style="color: grey">part</span>*, [NormalId](https://developer.roblox.com/en-us/api-reference/enum/NormalId) *<span style="color: grey">normalId</span>*)
Get a random point on a BasePart's surface.