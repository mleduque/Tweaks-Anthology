EXTEND_BOTTOM ~dmwwscriptname~ dmwwstatenumber
IF ~Global("EnteredArmInn","GLOBAL",1)
    Global("cd_no_travel_fai_all","GLOBAL",0)
    Global("cd_no_travel_fai_z!deathvariable","GLOBAL",0)
    !Global("IslandTravel","GLOBAL",1) // not on Werewolf Isle
    !Global("teth","GLOBAL",1) // not trapped under Candlekeep AR2613, 2615, 2619, 5506
    !Global("teth","GLOBAL",2)
    !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
    !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
    !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
    !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
    !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
    !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
    !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
    !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
    !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
    !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
    !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
    !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
    !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
    !Global("Z!EmulAreaCheck","GLOBAL","2301")~ // not in the area where the NPC will be sent
THEN REPLY @107501 GOTO dmww_fai

IF ~Global("EnteredBeregost","GLOBAL",1)
    Global("cd_no_travel_jugg_all","GLOBAL",0)
    Global("cd_no_travel_jugg_z!deathvariable","GLOBAL",0)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
    !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
    !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
    !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
    !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
    !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
    !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
    !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
    !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
    !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
    !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
    !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
    !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
    !Global("Z!EmulAreaCheck","GLOBAL","3304")~ // not in the area where the NPC will be sent
THEN REPLY @107502  GOTO dmww_beregost

IF ~GlobalGT("Chapter","GLOBAL",1)
    Global("cd_no_travel_nashi_all","GLOBAL",0)
    Global("cd_no_travel_nashi_z!deathvariable","GLOBAL",0)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
    !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
    !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
    !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
    !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
    !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
    !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
    !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
    !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
    !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
    !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
    !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
    !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
    !Global("Z!EmulAreaCheck","GLOBAL","4801")~ // not in the area where the NPC will be sent
THEN REPLY @107503  GOTO dmww_nash

IF ~!Global("Chapter","GLOBAL",7)   // you're not wanted in the Gate for murder
    Global("cd_no_travel_esong_all","GLOBAL",0)
    Global("cd_no_travel_esong_z!deathvariable","GLOBAL",0)
    Global("EnteredBaldursGate","GLOBAL",1)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
    !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
    !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
    !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
    !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
    !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
    !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
    !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
    !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
    !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
    !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
    !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
    !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
    !Global("Z!EmulAreaCheck","GLOBAL","0705")~ // not in the area where the NPC will be sent
THEN REPLY @107504  GOTO dmww_elfsong
END

APPEND ~dmwwscriptname~
IF ~~ THEN BEGIN dmww_fai
  SAY @dmwwresponse
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("AR2301","z!deathvariable",dmwwfailoc)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_beregost
  SAY @dmwwresponse
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("AR3304","z!deathvariable",dmwwbereloc)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_nash
  SAY @dmwwresponse
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("AR4801","z!deathvariable",dmwwnashloc)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_elfsong
  SAY @dmwwresponse
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("AR0705","z!deathvariable",dmwwelfloc)~
EXIT
END

END
