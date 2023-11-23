LANGUAGE = 'en'

POLICE_REQUIRED = 0
ROBBERY_INTERVAL = 2*60*6000 -- 2 Hours

BREAK_ITEM = "grinder"  -- Required item to break into containers, Remove to allow anyone to break.

LOOT = {
    item = "gold_ingot",    -- Item Name
    stack = 25,              -- Amount of gold ingots grabbed per stack
    price = 300             -- Selling price
}

START_SCENE = {
    enable = true,
    ped = {
        model = "s_m_m_highsec_01",
        coords = vector3(-687.82, -2417.1, 12.9445),
        heading = 320.78
    }
}

GUARDS = {
    models = {
        "s_m_y_blackops_01"
    },
    amount = 15,
    spawn_range = 30.0,
    weapons = {
        "WEAPON_PISTOL"
    },
    armour = 50,
    accuracy = 50
}

TRAIN = {
    position = vector3(-3.21, 3441.62, 49.58),
    heading = 59.28,
    length = 5,
    angle = 1.0
}

TRAIN_PARTS = {"freightcar", "freightcont1", "freightcont2", "freightgrain", "tankercar"}