
entity DamageTracker_CreateKeeper(entity own) {
    entity k = spawn();
    k.owner = own;
    k.classname = "dtrack_keeper";
    return k;
}

float DamageTracker_GetEntryId(entity keeper, float dtype) {
    float i;
    
    for(i = 0; i < DTRACK_ENTRIES; ++i) {
        if(!keeper.(dtrack_type[i]) || keeper.(dtrack_type[i]) == dtype)
            return i;
    }
    
    return -1;
}

void DamageTracker_Sort_Swap(float i, float j, entity keeper) {
    float tmp_t1, tmp_d1;
    float tmp_t2, tmp_d2;
    
    tmp_t1 = keeper.(dtrack_type[i]);
    tmp_d1 = keeper.(dtrack_damage[i]);
    tmp_t2 = keeper.(dtrack_type[j]);
    tmp_d2 = keeper.(dtrack_damage[j]);
    
    keeper.(dtrack_type[i]) = tmp_t2;
    keeper.(dtrack_damage[i]) = tmp_d2;
    keeper.(dtrack_type[j]) = tmp_t1;
    keeper.(dtrack_damage[j]) = tmp_d1;
}

float DamageTracker_Sort_Compare(float i, float j, entity keeper) {
    return keeper.(dtrack_damage[j]) - keeper.(dtrack_damage[i]);
}

float DamageTracker_Sort(entity keeper) {
    float ecnt, i;
    
    FOR_DTRACK_ENTRIES(keeper, i)
        ++ecnt;
        
    heapsort(ecnt, DamageTracker_Sort_Swap, DamageTracker_Sort_Compare, keeper);
    return ecnt;
}

void DamageTracker_Record(entity keeper, float dtype, float damage) {
    dtype = DamageTracker_TransformDamageSource(dtype);
    float i = DamageTracker_GetEntryId(keeper, dtype);
    keeper.(dtrack_type[i]) = dtype;
    keeper.(dtrack_damage[i]) += damage;
    keeper.dtrack_totaldamage += damage;
    
    if(keeper.(dtrack_damage[i]) > keeper.dtrack_highestdamage)
        keeper.dtrack_highestdamage = keeper.(dtrack_damage[i]);
}

void DamageTracker_Wipe(entity keeper) {
    float i;
    
    FOR_DTRACK_ENTRIES(keeper, i) {
        keeper.(dtrack_type[i]) = 0;
        keeper.(dtrack_damage[i]) = 0;
    }
    
    keeper.dtrack_type = 0;
    keeper.dtrack_damage = 0;
    keeper.dtrack_highestdamage = 0;
    keeper.dtrack_totaldamage = 0;
}

string DamageTracker_DamageSourceName(float dtype, float extended) {
    string r;
    
    if(DEATH_ISHG(dtype))
        return HG_TypeToExpandedName(dtype);
    else if(dtype == DEATH_ARC)
        return "Arc Buff";
    else if(dtype == DEATH_IGNITE)
        return "Ignite Buff";
    else if(dtype == DEATH_MEODP)
        return "Mystic Eyes of Death Perception";
    else { 
        r = get_weaponinfo(DEATH_WEAPONOF(dtype)).message;
        
        //if(extended) {
            if(r == "") {
                if(extended)
                    return strcat("Unknown damage source (", ftos(dtype), ")");
                else
                    return r;
            }
            
            #define ADDMOD(m) mods = ((mods == "")? m : strcat(mods, ", ", m))
            string mods;

            if(dtype & HITTYPE_SECONDARY)   ADDMOD("alt");
            if(dtype & HITTYPE_HEADSHOT)    ADDMOD("head");
            if(dtype & HITTYPE_SPLASH)      ADDMOD("splash");

            if(dtype & HITTYPE_BOUNCE) {
                if(DEATH_ISWEAPON(dtype, WEP_ZAPPER))
                    ADDMOD("arc");
                else if(DEATH_ISWEAPON(dtype, WEP_ELECTRO))
                    ADDMOD("combo");
                else if(DEATH_ISWEAPON(dtype, WEP_ROCKET_LAUNCHER))
                    ADDMOD("remote");
                else
                    ADDMOD("bounce");
            }

            #undef ADDMOD
            
            if(mods != "")
                return strcat(r, " (", mods, ")");
        //}
        
        return r;
    }
}

float DamageTracker_TransformDamageSource(float dtype) {
    if(dtype == DEATH_HG_PLASMA_SHARD)
        return DEATH_HG_PLASMA;
    
    if(!DEATH_ISHG(dtype) && !DEATH_ISSPECIAL(dtype)) {
        dtype &~= HITTYPE_SPLASH;

        if(!DEATH_ISWEAPON(dtype, WEP_ZAPPER)           &&   // secondary arc
           !DEATH_ISWEAPON(dtype, WEP_ELECTRO)          &&   // combo
           !DEATH_ISWEAPON(dtype, WEP_ROCKET_LAUNCHER))      // remote detonation
            dtype &~= HITTYPE_BOUNCE;

        if(!DEATH_ISWEAPON(dtype, WEP_CAMPINGRIFLE))
            dtype &~= HITTYPE_HEADSHOT; // only the rifle actually uses headshots
    }
    
    return dtype;
}
