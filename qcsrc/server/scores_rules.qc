float c1, c2, c3, c4;
void CheckAllowedTeams (entity for_whom);

// NOTE: SP_ constants may not be >= MAX_SCORE; ST_constants may not be >= MAX_TEAMSCORE
// scores that should be in all modes:
float ScoreRules_teams;
void ScoreRules_basics(float teams, float sprio, float stprio, float score_enabled)
{
	float i;
	for(i = 0; i < MAX_SCORE; ++i)
		ScoreInfo_SetLabel_PlayerScore(i, "", 0);
	for(i = 0; i < MAX_TEAMSCORE; ++i)
		ScoreInfo_SetLabel_TeamScore(i, "", 0);

	ScoreRules_teams = teams;

	if(score_enabled)
		ScoreInfo_SetLabel_TeamScore  (ST_SCORE,        "score",     stprio);

	if not(independent_players)
		ScoreInfo_SetLabel_PlayerScore(SP_KILLS,        "kills",     (g_clanarena? SFL_SORT_PRIO_SECONDARY : 0));

	ScoreInfo_SetLabel_PlayerScore(SP_DEATHS,           "dths",    SFL_LOWER_IS_BETTER);

	if not(independent_players)
		ScoreInfo_SetLabel_PlayerScore(SP_SUICIDES,     "scds",  SFL_LOWER_IS_BETTER);
    
    if(g_freeze && !g_freezetag)
        ScoreInfo_SetLabel_PlayerScore(SP_REVIVALS,     "revs",    0);
        
	if(score_enabled)
		ScoreInfo_SetLabel_PlayerScore(SP_SCORE,        "score",     sprio);
	
    ScoreInfo_SetLabel_PlayerScore(SP_HOOKFRAGS,        "hfs",     0);
    ScoreInfo_SetLabel_PlayerScore(SP_NADEFRAGS,        "nfs",     0);
    ScoreInfo_SetLabel_PlayerScore(SP_DAMAGE,           "dmg",     0);
    ScoreInfo_SetLabel_PlayerScore(SP_HEALING,          "heal",    0);
}
void ScoreRules_basics_end()
{
	ScoreInfo_Init(ScoreRules_teams);
}
void ScoreRules_generic()
{
	CheckAllowedTeams(world);
	if(teams_matter)
	{
		CheckAllowedTeams(world);
		ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE);
	}
	else
		ScoreRules_basics(0, SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE);
	ScoreRules_basics_end();
}

// g_ctf
#define ST_CTF_CAPS 1
#define SP_CTF_CAPS 4
#define SP_CTF_PICKUPS 5
#define SP_CTF_DROPS 6
#define SP_CTF_FCKILLS 7
#define SP_CTF_RETURNS 8
void ScoreRules_ctf()
{
	float sp_score, sp_caps;
	sp_score = sp_caps = 0;
	switch(g_ctf_win_mode)
	{
		case 0: // caps only
			sp_caps = SFL_SORT_PRIO_PRIMARY;
			break;
		case 1: // caps, then score
			sp_caps = SFL_SORT_PRIO_PRIMARY;
			sp_score = SFL_SORT_PRIO_SECONDARY;
			break;
		case 2: // score only
		default:
			sp_caps = SFL_SORT_PRIO_SECONDARY; // looks better ;)
			sp_score = SFL_SORT_PRIO_PRIMARY;
			break;
	}

	CheckAllowedTeams(world);
	ScoreRules_basics(2 + (c3>=0), SFL_SORT_PRIO_PRIMARY, sp_score, TRUE); // NOTE this assumes that the rogue team is team 3
	ScoreInfo_SetLabel_TeamScore  (ST_CTF_CAPS,     "caps",      sp_caps);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_CAPS,     "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_PICKUPS,  "pckps",     0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_FCKILLS,  "fcks",      0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_RETURNS,  "rtrns",     0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_DROPS,    "drops",     SFL_LOWER_IS_BETTER);
	ScoreInfo_SetLabel_PlayerScore(SP_CARRYING,     "fc",        0);
	ScoreRules_basics_end();
}

// g_domination
#define ST_DOM_TICKS 1
#define SP_DOM_TICKS 4
#define SP_DOM_TAKES 5
#define ST_TDOM_CAPS 6
void ScoreRules_tdom()
{
	float sp_domticks, sp_score;
	sp_score = sp_domticks = 0;
	
	/*CheckAllowedTeams(world);
	ScoreRules_basics(2 + (c3>=0), SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE); // NOTE this assumes that the rogue team is team 3
	ScoreInfo_SetLabel_TeamScore  (ST_TDOM_CAPS,    "caps",      SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_TeamScore  (ST_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TAKES,    "takes",     0);
	ScoreRules_basics_end();
	*/
	
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TICKS,    "ticks",     0);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TAKES,    "takes",     0);
	ScoreRules_basics_end();
}

void ScoreRules_dom()
{
	if(g_totaldomination)
	{
		ScoreRules_tdom();
		return;
	}
	
	float sp_domticks, sp_score;
	sp_score = sp_domticks = 0;
	
	if(cvar("g_domination_disable_frags"))
		sp_domticks = SFL_SORT_PRIO_PRIMARY;
	else
		sp_score = SFL_SORT_PRIO_PRIMARY;
	
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), sp_score, sp_score, TRUE);
	ScoreInfo_SetLabel_TeamScore  (ST_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TAKES,    "takes",     0);
	ScoreRules_basics_end();
}

// LMS stuff
#define SP_LMS_LIVES 4
#define SP_LMS_RANK 5
void ScoreRules_lms()
{
	ScoreRules_basics(0, 0, 0, FALSE);
	ScoreInfo_SetLabel_PlayerScore(SP_LMS_LIVES,    "lives",     SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_LMS_RANK,     "rank",      SFL_LOWER_IS_BETTER | SFL_RANK | SFL_SORT_PRIO_PRIMARY | SFL_ALLOW_HIDE);
	ScoreRules_basics_end();
}

// Key hunt stuff
#define ST_KH_CAPS 1
#define SP_KH_CAPS 4
#define SP_KH_PUSHES 5
#define SP_KH_DESTROYS 6
#define SP_KH_PICKUPS 7
#define SP_KH_KCKILLS 8
#define SP_KH_LOSSES 9
void ScoreRules_kh(float teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE);
	//ScoreInfo_SetLabel_TeamScore  (ST_KH_CAPS,      "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_TeamScore  (ST_KH_CAPS,      "caps",      SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_CAPS,      "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_PUSHES,    "push",      0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_DESTROYS,  "dstrd",     SFL_LOWER_IS_BETTER);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_PICKUPS,   "pckps",     0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_KCKILLS,   "kcks",      0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_LOSSES,    "loss",      SFL_LOWER_IS_BETTER);
//	ScoreInfo_SetLabel_PlayerScore (SP_CARRYING,    "keys",      0); // fuck CSQC
	ScoreRules_basics_end();
}

// Race stuff
#define ST_RACE_LAPS 1
#define SP_RACE_LAPS 4
#define SP_RACE_FASTEST 5
#define SP_RACE_TIME 5
void ScoreRules_race()
{
	ScoreRules_basics(race_teams, 0, 0, FALSE);
	if(race_teams)
	{
		ScoreInfo_SetLabel_TeamScore(  ST_RACE_LAPS,    "laps",      SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_LAPS,    "laps",      SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_TIME,    "time",      SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	else if(g_race_qualifying)
	{
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_FASTEST, "fastest",   SFL_SORT_PRIO_PRIMARY | SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	else
	{
		//ScoreInfo_SetLabel_TeamScore(  ST_RACE_LAPS,    "laps",      0);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_LAPS,    "laps",      SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_TIME,    "time",      SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	ScoreRules_basics_end();
}

// Assault stuff
#define ST_ASSAULT_OBJECTIVES 1
#define SP_ASSAULT_OBJECTIVES 4
void ScoreRules_assault()
{
	ScoreRules_basics(2, SFL_SORT_PRIO_SECONDARY, SFL_SORT_PRIO_SECONDARY, TRUE);
	ScoreInfo_SetLabel_TeamScore(  ST_ASSAULT_OBJECTIVES,    "objectives",      SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_ASSAULT_OBJECTIVES,    "objectives",      SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();
}

// Nexball stuff
#define ST_NEXBALL_GOALS 1
#define SP_NEXBALL_GOALS 4
#define SP_NEXBALL_FAULTS 5
void ScoreRules_nexball(float teams)
{
	ScoreRules_basics(teams, 0, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(   ST_NEXBALL_GOALS,  "goals", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore( SP_NEXBALL_GOALS,  "goals", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_NEXBALL_FAULTS, "faults", SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER);
	ScoreRules_basics_end();
}

// FreezeTag stuff
void ScoreRules_freezetag()
{
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_PlayerScore(SP_REVIVALS,		"revs",		SFL_SORT_PRIO_SECONDARY);
	ScoreRules_basics_end();
}

// VIP stuff
#define SP_VIP_VIPKILLS 4
#define SP_VIP_SURVIVALS 5
void ScoreRules_vip()
{
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_PlayerScore(SP_VIP_VIPKILLS,		"vks",		SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_VIP_SURVIVALS,	"surv",	0);
	ScoreRules_basics_end();
}

// Jailbreak stuff
#define SP_JB_JBREAKS 4
#define SP_JB_FREED 5
#define SP_JB_DEFENSE 6
void ScoreRules_JB()
{
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_PlayerScore(SP_JB_JBREAKS,		"jbs",		0);
    ScoreInfo_SetLabel_PlayerScore(SP_JB_FREED,		    "freed",		SFL_SORT_PRIO_SECONDARY);
    ScoreInfo_SetLabel_PlayerScore(SP_JB_DEFENSE,		"def",		0);
	ScoreRules_basics_end();
}

// Precious stuff
#define SP_PREC_CARRIERKILLS 4
#define SP_PREC_PICKUPS 5
void ScoreRules_Prec()
{
	ScoreRules_basics(0, SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_PlayerScore(SP_PREC_CARRIERKILLS,	"rcks",		SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_PREC_PICKUPS,			"pckps",		0);
	ScoreRules_basics_end();
}
