Config = {}
Config.SoundBar = {
    MaxLevel = 100,
    IncreaseRate = 1,
    DecreaseRate = 0.5,
    CrouchRate = 0,
    NPC = {
        Model = 'a_m_m_hillbilly_01',
        Weapon = 'WEAPON_BAT'
    }
}
Config.Interiors = {
    House1 = {
        Door = vec3(-174.7202, 502.5304, 137.4204),
        Interior = vec3(-174.3378, 497.484, 137.6535),
        Bucket = math.random(1, 999999),
        Objects = {
            'apa_mp_h_str_avunits_04',
            'apa_mp_h_str_sideboradl_11',
            'apa_mp_h_bed_with_table_02',
            'apa_mp_h_str_shelfwallm_01'
        }
    },
    House2 = {
        Door = vec3(85.1617, 561.7064, 182.7731),
        Interior = vec3(-174.3378, 497.484, 137.6535),
        Bucket = math.random(1, 999999),
        Objects = {
            'apa_mp_h_str_avunits_04',
            'apa_mp_h_str_sideboradl_11',
            'apa_mp_h_bed_with_table_02',
            'apa_mp_h_str_shelfwallm_01'
        }
    }
}