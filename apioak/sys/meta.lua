local version = setmetatable({
    major = 0,
    minor = 4,
    patch = 0,
}, {
    __tostring = function(v)
        return string.format("%d.%d.%d", v.major, v.minor, v.patch)
    end
})

return {
    __NAME = "APIOAK",
    __VERSION = tostring(version),
    __VERSION_NUM = tonumber(string.format("%d%.2d%.2d",
            version.minor * 100,
            version.minor * 10,
            version.patch
    ))
}
