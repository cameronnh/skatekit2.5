local Instancer = {}
local IGNORED_KEYS = {"ClassName", "Children", "Callback"}

function Instancer:Create(data: {}): Instance
	local result: Instance = Instance.new(data.ClassName)

	for key: string, value: any in data do
		if table.find(IGNORED_KEYS, key) then continue end
		result[key] = value
	end

	if data.Children then
		for _, child in data.Children do
			local newInstance: Instance = Instancer:Create(child)
			newInstance.Parent = result
		end
	end

    if data.Callback then
        data.Callback(result)
    end

	return result
end

return Instancer