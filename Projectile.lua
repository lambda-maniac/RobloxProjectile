local Projectile = {
    Tools = {}
}

function Projectile.Tools.GetHRP(player)
    return (
        player.Character or player.CharacterAdded:Wait()
    ):WaitForChild("HumanoidRootPart")
end

function Projectile.Tools.SetMass(part, mass, name)
    local name    = name or "__vf_mass"
    local at_name = name .. "_attachment"

    local vectorForce  = part:FindFirstChild(name)
                      or Instance.new("VectorForce", part)

    local __attachment = part:FindFirstChild(at_name)
                      or Instance.new("Attachment" , part)

    __attachment.Name
        = at_name
    vectorForce.Name
        = name
    vectorForce.Attachment0
        = __attachment
    vectorForce.ApplyAtCenterOfMass
        = true
    vectorForce.RelativeTo
        = Enum.ActuatorRelativeTo.World
    vectorForce.Force
        = Vector3.new(0, (game.Workspace.Gravity * part:GetMass()) - (game.Workspace.Gravity * mass), 0)
    vectorForce.Enabled
        = true
end

function Projectile.Tools.SetUpLinearVelocity(part, name)
    local name    = name or "__lv_linear_velocity"
    local at_name = name .. "_attachment"

    local linearVelocity = part:FindFirstChild(name)
                        or Instance.new("LinearVelocity", part)

    local __attachment   = part:FindFirstChild(at_name)
                        or Instance.new("Attachment"    , part)

    __attachment.Name
        = at_name
    linearVelocity.Name
        = name
    linearVelocity.Attachment0
        = __attachment
    linearVelocity.RelativeTo
        = Enum.ActuatorRelativeTo.World
    linearVelocity.MaxForce
        = math.huge
    linearVelocity.VectorVelocity
        = Vector3.zero
    linearVelocity.Enabled
        = true

    return linearVelocity
end

function Projectile.Tools.SetUpAngularVelocity(part, name)
    local name    = name or "__av_angular_velocity"
    local at_name = name .. "_attachment"

    local angularVelocity = part:FindFirstChild(name)
                         or Instance.new("AngularVelocity", part)

    local __attachment    = part:FindFirstChild(at_name)
                         or Instance.new("Attachment"     , part)

    __attachment.Name
        = at_name
    angularVelocity.Name
        = name
    angularVelocity.Attachment0
        = __attachment
    angularVelocity.RelativeTo
        = Enum.ActuatorRelativeTo.World
    angularVelocity.MaxTorque
        = math.huge
    angularVelocity.AngularVelocity
        = Vector3.zero
    angularVelocity.Enabled
        = true

    return angularVelocity
end

function Projectile.new( part
                       , origin
                       , originOffset
                       , orientation
                       , orientationOffset
                       , forwardOffset
                       , velocity
                       , deadline
                       , mass
                       , targeter
                       , rotationForce
                       , acceleration
                       , singularity )
    local self = {}

    self.Part              = part
    self.Origin            = origin
    self.OriginOffset      = originOffset
    self.Orientation       = orientation
    self.OrientationOffset = orientationOffset
    self.ForwardOffset     = forwardOffset
    self.Velocity          = velocity
    self.Deadline          = deadline
    self.Mass              = mass or 0
    self.Targeter          = targeter
    self.RotationForce     = rotationForce
    self.Acceleration      = acceleration or 0
    self.Singularity       = singularity or 0

    Projectile.Tools.SetMass(self.Part, self.Mass, nil)

    self.LVController = Projectile.Tools.SetUpLinearVelocity (self.Part, nil)
    self.AVController = Projectile.Tools.SetUpAngularVelocity(self.Part, nil)

    function self.Spawn(self)
        self.Part.Parent
            = workspace

        self.Part.Position
            = self.Origin
            + self.OriginOffset

        self.Part.Orientation
            = self.Orientation
            + self.OrientationOffset

        self.Part:SetNetworkOwner(nil)
    end

    function self.Act(self, b_UCollide)
        local      OnUpdate = game:GetService("RunService").Stepped;
        local   OnCollision = self.Part.Touched;
        local    updateHook = nil
        local collisionHook = nil

        self:Spawn()

        local function Update(_, deltaTime)

            local target = self.Targeter and self.Targeter() or nil

            if target then
                local targetDirection
                    = (target.Position - self.Part.Position).Unit

                local toRotate
                    = (self.Part.CFrame * self.ForwardOffset).LookVector:Cross(targetDirection).Unit

                self.AVController.AngularVelocity
                    = toRotate
                    * self.RotationForce

                self.RotationForce += self.Singularity * deltaTime
            else
                self.AVController.AngularVelocity = Vector3.zero
            end

            self.LVController.VectorVelocity
                = (self.Part.CFrame * self.ForwardOffset).LookVector
                * self.Velocity

            self.Velocity += self.Acceleration * deltaTime
        end

        local function Collide(infractor)
            if b_UCollide(infractor, self.Part) then

                updateHook:Disconnect()
                collisionHook:Disconnect()
                self.Part:Destroy()

            end
        end

        collisionHook = OnCollision:Connect(Collide)
        updateHook    = OnUpdate:Connect(Update)

        task.wait(self.Deadline)

        updateHook:Disconnect()
        collisionHook:Disconnect()

        self.Part:Destroy()
    end

    return self
end

return Projectile
