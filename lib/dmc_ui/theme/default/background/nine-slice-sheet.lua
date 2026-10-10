--
-- drawn by tools/default-art.py: one rounded rectangle, cut into nine frames
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {

        {
            -- topLeft
            x=2,
            y=2,
            width=10,
            height=10,

        },
        {
            -- topMiddle
            x=12,
            y=2,
            width=4,
            height=10,

        },
        {
            -- topRight
            x=16,
            y=2,
            width=10,
            height=10,

        },
        {
            -- middleLeft
            x=2,
            y=12,
            width=10,
            height=40,

        },
        {
            -- middleMiddle
            x=12,
            y=12,
            width=4,
            height=40,

        },
        {
            -- middleRight
            x=16,
            y=12,
            width=10,
            height=40,

        },
        {
            -- bottomLeft
            x=2,
            y=52,
            width=10,
            height=10,

        },
        {
            -- bottomMiddle
            x=12,
            y=52,
            width=4,
            height=10,

        },
        {
            -- bottomRight
            x=16,
            y=52,
            width=10,
            height=10,

        },
    },

    sheetContentWidth = 32,
    sheetContentHeight = 64
}

SheetInfo.frameIndex =
{

    ["topLeft"] = 1,
    ["topMiddle"] = 2,
    ["topRight"] = 3,
    ["middleLeft"] = 4,
    ["middleMiddle"] = 5,
    ["middleRight"] = 6,
    ["bottomLeft"] = 7,
    ["bottomMiddle"] = 8,
    ["bottomRight"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
