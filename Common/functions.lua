function generateVehicleId(model, licensePlate)
    return string.lower(string.gsub(licensePlate, "%s+", "")) .. "_" .. string.gsub(model, "-", "")
end