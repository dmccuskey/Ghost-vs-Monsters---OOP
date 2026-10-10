--
-- drawn by tools/default-art.py: one rounded rectangle, cut into nine frames
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {

        {
            -- 01-TL
            x=2,
            y=2,
            width=8,
            height=8,

        },
        {
            -- 02-TM
            x=10,
            y=2,
            width=4,
            height=8,

        },
        {
            -- 03-TR
            x=14,
            y=2,
            width=8,
            height=8,

        },
        {
            -- 04-ML
            x=2,
            y=10,
            width=8,
            height=4,

        },
        {
            -- 05-MM
            x=10,
            y=10,
            width=4,
            height=4,

        },
        {
            -- 06-MR
            x=14,
            y=10,
            width=8,
            height=4,

        },
        {
            -- 07-BL
            x=2,
            y=14,
            width=8,
            height=8,

        },
        {
            -- 08-BM
            x=10,
            y=14,
            width=4,
            height=8,

        },
        {
            -- 09-BR
            x=14,
            y=14,
            width=8,
            height=8,

        },
    },

    sheetContentWidth = 32,
    sheetContentHeight = 32
}

SheetInfo.frameIndex =
{

    ["01-TL"] = 1,
    ["02-TM"] = 2,
    ["03-TR"] = 3,
    ["04-ML"] = 4,
    ["05-MM"] = 5,
    ["06-MR"] = 6,
    ["07-BL"] = 7,
    ["08-BM"] = 8,
    ["09-BR"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
