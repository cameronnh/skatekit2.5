local WHEEL_PHYSICAL_PROPS = PhysicalProperties.new(.7, 0, 1, 0.2, 1)
local WHEEL_OFFSET_C0 = Vector3.new(0.5, 0, 0)
local WHEEL_OFFSET_C1 = Vector3.new(1, 0.3, 2.5)

return {
    ClassName = "Model",
    Name = script.Name,
    Children = {
        {
            ClassName = "SkateboardPlatform",
            Name = "SkateboardPlatform",
            Size = Vector3.new(2, 0.4, 6),
            CustomPhysicalProperties = PhysicalProperties.new(1.75, 0, 1, 0, 1),
            Anchored = false,
            StickyWheels = true,
            Transparency = 1,
            Children = {
                {
                    ClassName = "Attachment",
                    Name = "Attachment"
                },
                {
                    ClassName = "Attachment",
                    Name = "BackAttachment",
                    CFrame = CFrame.new(0, 0, 2.7)
                },
                {
                    ClassName = "Attachment",
                    Name = "FrontAttachment",
                    CFrame = CFrame.new(0, 0, -2.7)
                },
                {
                    ClassName = "Weld",
                    Name = "tw"
                }
            },
        },
        {
            ClassName = "Part",
            Name = "TrickBoard",
            Size = Vector3.new(2, 0.4, 6),
            CanCollide = false,
            Anchored = false,
            Children = {
                {
                    ClassName = "SpecialMesh",
                    Name = "TrickBoard",
                    MeshType = Enum.MeshType.FileMesh,
                    MeshId = "rbxassetid://5008760007",
                    TextureId = "rbxassetid://138140575314498",
                    Offset = Vector3.new(0, -0.34, 0),
                    Scale = Vector3.new(1.15, 1.35, 1.15),
                },
            }
        },
        {
            ClassName = "Part",
            Name = "LeftFront",
            Anchored = false,
            Transparency = 1,
            Size = Vector3.one,
            CustomPhysicalProperties = WHEEL_PHYSICAL_PROPS,
            Shape = Enum.PartType.Ball,
            Children = {
                {
                    ClassName = "Rotate",
                    C0 = CFrame.new(-WHEEL_OFFSET_C0.X, 0, 0) * CFrame.Angles(0, math.rad(-90), 0),
                    C1 = CFrame.new(WHEEL_OFFSET_C1.X, -WHEEL_OFFSET_C1.Y, -WHEEL_OFFSET_C1.Z) * CFrame.Angles(0, math.rad(-90), 0)
                },
            }
        },
        {
            ClassName = "Part",
            Name = "LeftRear",
            Anchored = false,
            Transparency = 1,
            Size = Vector3.one,
            CustomPhysicalProperties = WHEEL_PHYSICAL_PROPS,
            Shape = Enum.PartType.Ball,
            Children = {
                {
                    ClassName = "Rotate",
                    C0 = CFrame.new(-WHEEL_OFFSET_C0.X, 0, 0) * CFrame.Angles(0, math.rad(-90), 0),
                    C1 = CFrame.new(WHEEL_OFFSET_C1.X, -WHEEL_OFFSET_C1.Y, WHEEL_OFFSET_C1.Z) * CFrame.Angles(0, math.rad(-90), 0)
                },
            }
        },
        {
            ClassName = "Part",
            Name = "RightFront",
            Anchored = false,
            Transparency = 1,
            Size = Vector3.one,
            CustomPhysicalProperties = WHEEL_PHYSICAL_PROPS,
            Shape = Enum.PartType.Ball,
            Children = {
                {
                    ClassName = "Rotate",
                    C0 = CFrame.new(WHEEL_OFFSET_C0.X, 0, 0) * CFrame.Angles(0, 90, 0),
                    C1 = CFrame.new(-WHEEL_OFFSET_C1.X, -WHEEL_OFFSET_C1.Y, -WHEEL_OFFSET_C1.Z) * CFrame.Angles(0, math.rad(90), 0)
                },
            }
        },
        {
            ClassName = "Part",
            Name = "RightRear",
            Anchored = false,
            Transparency = 1,
            Size = Vector3.one,
            CustomPhysicalProperties = WHEEL_PHYSICAL_PROPS,
            Shape = Enum.PartType.Ball,
            Children = {
                {
                    ClassName = "Rotate",
                    C0 = CFrame.new(WHEEL_OFFSET_C0.X, 0, 0) * CFrame.Angles(0, math.rad(90), 0),
                    C1 = CFrame.new(-WHEEL_OFFSET_C1.X, -WHEEL_OFFSET_C1.Y, WHEEL_OFFSET_C1.Z) * CFrame.Angles(0, math.rad(90), 0)
                },
            }
        },
    },
    Callback = function(result: Instance): ()
        result.LeftFront.Rotate.Part0 = result.LeftFront
        result.LeftFront.Rotate.Part1 = result.SkateboardPlatform

        result.LeftRear.Rotate.Part0 = result.LeftRear
        result.LeftRear.Rotate.Part1 = result.SkateboardPlatform

        result.RightFront.Rotate.Part0 = result.RightFront
        result.RightFront.Rotate.Part1 = result.SkateboardPlatform

        result.RightRear.Rotate.Part0 = result.RightRear
        result.RightRear.Rotate.Part1 = result.SkateboardPlatform

        result.SkateboardPlatform.tw.Part0 = result.TrickBoard
        result.SkateboardPlatform.tw.Part1 = result.SkateboardPlatform

        result.PrimaryPart = result.TrickBoard
    end
}