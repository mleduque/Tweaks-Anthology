REPLACE_ACTION_TEXT ~neerap~   ~EscapeAreaMove("AR2301",755,390,SW)~  ~~
REPLACE_ACTION_TEXT ~rasaadp~  ~EscapeAreaMove("AR4800",1100,782,S)~  ~~
REPLACE_ACTION_TEXT ~dornp~    ~EscapeAreaMove("AR2301",1132,727,S)~  ~~
ALTER_TRANS DORNP BEGIN 2 END BEGIN 0 END BEGIN ~JOURNAL~ ~~ END // remove journal entry about going to FAI

// baeloth needs custom code since he's being sent to inn-adjacent areas

// first, turn baeloth's existing departure to a simple 'stay here'; move already handled above
ALTER_TRANS baelothp BEGIN 3 END BEGIN 0 END BEGIN ~REPLY~ ~@20850~ END 
REPLACE_ACTION_TEXT ~baelothp~ ~EscapeAreaMove("AR2300",4721,3045,S)~ ~~

// more or less copied from depart.d, but using custom replies since he's not quite going to the same places
EXTEND_BOTTOM baelothp 0
IF ~Global("EnteredArmInn","GLOBAL",1)
    !Global("IslandTravel","GLOBAL",1) // not on Werewolf Isle
    !Global("teth","GLOBAL",1) // not trapped under Candlekeep AR2613, 2615, 2619, 5506
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("AR2300")~                            // not in the area where the NPC will be sent
THEN REPLY #31931 GOTO dmww_fai

IF ~Global("EnteredBeregost","GLOBAL",1)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("AR3300")~                            // not in the area where the NPC will be sent
THEN REPLY @20848  GOTO dmww_beregost

IF ~GlobalGT("Chapter","GLOBAL",1)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("AR4800")~                            // not in the area where the NPC will be sent
THEN REPLY @20847  GOTO dmww_nash

IF ~OR(2)
      !Global("Chapter","GLOBAL",7)     // you're not wanted in the Gate for murder
      GlobalGT("DukeThanks","GLOBAL",0) // or you've been cleared by the Duke
    Global("EnteredBaldursGate","GLOBAL",1)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("AR0800")~                            // not in the area where the NPC will be sent
THEN REPLY @20849  GOTO dmww_elfsong
END

APPEND baelothp
IF ~~ THEN BEGIN dmww_fai
  SAY @20851
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("AR2300","baeloth",[4721.3045])~
EXIT
END

IF
  ~~ THEN BEGIN dmww_beregost
  SAY @20851
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("ar3300","baeloth",[829.2427])~
EXIT
END

IF
  ~~ THEN BEGIN dmww_nash
  SAY @20851
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("ar4800","baeloth",[432.1288])~
EXIT
END

IF
  ~~ THEN BEGIN dmww_elfsong
  SAY @20851
  IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120)
  Face(0) MoveGlobal("ar0800","baeloth",[353.1623])~
EXIT
END

END
