Config = {}

Config.JobName = 'animalcontrol' --job name to have acces to the job, found in sql file

Config.ClockOnLocation = vector3(-1224.46, -1331.06, 4.22) --where the job starts/stops

Config.Blip = {
    Sprite = 141, -- Dog blip
    Color = 5, 
    Scale = 1.0,
    Name = 'Animal Control'
}

Config.Clothes = {
    male = {
        tshirt_1 = 15, tshirt_2 = 0, --configure to your desired work uniform
        torso_1 = 65, torso_2 = 0,
        decals_1 = 0, decals_2 = 0,
        arms = 1,
        pants_1 = 9, pants_2 = 7,
        shoes_1 = 7, shoes_2 = 0,
        chain_1 = 0, chain_2 = 0,
        helmet_1 = -1, helmet_2 = 0,
        glasses_1 = 0, glasses_2 = 0,
        bags_1 = 0, bags_2 = 0
    },
    female = {
        tshirt_1 = 15, tshirt_2 = 0,
        torso_1 = 65, torso_2 = 0,
        decals_1 = 0, decals_2 = 0,
        arms = 1,
        pants_1 = 9, pants_2 = 7,
        shoes_1 = 7, shoes_2 = 0,
        chain_1 = 0, chain_2 = 0,
        helmet_1 = -1, helmet_2 = 0,
        glasses_1 = 0, glasses_2 = 0,
        bags_1 = 0, bags_2 = 0
    }
}

Config.VehicleModel = 'boxville3' -- work vehicle change if desired -- https://docs.fivem.net/docs/game-references/vehicle-references/vehicle-models/
Config.VehicleSpawn = vector4(-1207.41, -1333.96, 4.78, 201.26) -- Spawn coords for the work vehicle

Config.DogModels = {
    'a_c_rottweiler',
    'a_c_pug',
    'a_c_retriever',
    'a_c_shepherd',
    -- Add more dog models as needed -- https://docs.fivem.net/docs/game-references/ped-models/
}

Config.CallLocations = {
    vector3(-1124.07, -1606.02, 4.39),
    vector3(61.29, -1888.52, 21.63),
    vector3(1206.04, -1753.20, 39.17),
    vector3(-194.14, -1630.04, 33.46),
    vector3(9.09, -1353.81, 29.31),
    vector3(414.86, -791.26, 29.33),
    vector3(164.56, -912.15, 30.24),
    -- Locations where the dogs spawn, add as many as you want
}

Config.PayoutPerDog = 200 -- How much you get per dog caught, paid after clock out

Config.DispatchInterval = 180000 -- Dispatch interval in milliseconds (3 minutes)