EXTEND_BOTTOM ~%postdialogue%~ %state1% %state2%
IF ~Global("EnteredArmInn","GLOBAL",1)
    Global("cd_no_travel_fai_all","GLOBAL",0)
    Global("cd_no_travel_fai_%npc%","GLOBAL",0)
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
    !AreaCheck("%FriendlyArmInn_L1%")~               // not in the area where the NPC will be sent
THEN REPLY @107501 GOTO dmww_fai

IF ~Global("EnteredBeregost","GLOBAL",1)
    Global("cd_no_travel_jugg_all","GLOBAL",0)
    Global("cd_no_travel_jugg_%npc%","GLOBAL",0)
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
    !AreaCheck("%Beregost_JovialJuggler_L1%")~       // not in the area where the NPC will be sent
THEN REPLY @107502  GOTO dmww_beregost

IF ~GlobalGT("Chapter","GLOBAL",1)
    Global("cd_no_travel_nashi_all","GLOBAL",0)
    Global("cd_no_travel_nashi_%npc%","GLOBAL",0)
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
    !AreaCheck("%Nashkel_Inn%")~                     // not in the area where the NPC will be sent
THEN REPLY @107503  GOTO dmww_nash

IF ~OR(2)
      !Global("Chapter","GLOBAL",7)     // you're not wanted in the Gate for murder
      GlobalGT("DukeThanks","GLOBAL",0) // or you've been cleared by the Duke
    Global("cd_no_travel_esong_all","GLOBAL",0)
    Global("cd_no_travel_esong_%npc%","GLOBAL",0)
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
    !AreaCheck("%EBaldursGate_ElfsongTavern_L1%")~       // not in the area where the NPC will be sent
THEN REPLY @107504  GOTO dmww_elfsong
END

APPEND ~%postdialogue%~
IF ~~ THEN BEGIN dmww_fai
  SAY @%dmwwresponse%
  IF ~~ THEN DO ~EscapeAreaMove("%FriendlyArmInn_L1%",%friendly_xloc%,%friendly_yloc%,0)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_beregost
  SAY @%dmwwresponse%
  IF ~~ THEN DO ~EscapeAreaMove("%Beregost_JovialJuggler_L1%",%beregost_xloc%,%beregost_yloc%,0)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_nash
  SAY @%dmwwresponse%
  IF ~~ THEN DO ~EscapeAreaMove("%Nashkel_Inn%",%nashkel_xloc%,%nashkel_yloc%,0)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_elfsong
  SAY @%dmwwresponse%
  IF ~~ THEN DO ~EscapeAreaMove("%EBaldursGate_ElfsongTavern_L1%",%elfsong_xloc%,%elfsong_yloc%,0)~
EXIT
END

END
