/////                                                  \\\\\
///// Minsc & Dynaheir                                 \\\\\
/////                                                  \\\\\

EXTEND_BOTTOM BDMINSC 67
  IF ~!StateCheck("dynaheir",CD_STATE_NOTVALID) InMyArea("dynaheir")~ THEN REPLY @20706 GOTO dmww_dynaheirnotwanted
END

EXTEND_BOTTOM BDMINSC 76
  IF ~!StateCheck("dynaheir",CD_STATE_NOTVALID) InMyArea("dynaheir")~ THEN REPLY @20706 GOTO dmww_dynaheirnotwanted
END

EXTEND_BOTTOM BDDYNAHE 61
  IF ~!StateCheck("minsc",CD_STATE_NOTVALID) InMyArea("minsc")~ THEN REPLY @20709 EXTERN BDMINSC dmww_minscnotwanted
END

EXTEND_BOTTOM BDDYNAHE 69
  IF ~!StateCheck("minsc",CD_STATE_NOTVALID) InMyArea("minsc")~ THEN REPLY @20709 EXTERN BDMINSC dmww_minscnotwanted
END

CHAIN
IF ~~ THEN BDMINSC dmww_dynaheirnotwanted
@20707 == BDDYNAHE
@20708
DO ~SetGlobal("bd_minsc_join","global",1)ActionOverride("minsc",JoinParty())~ 
EXIT

CHAIN 
IF ~~ THEN BDMINSC dmww_minscnotwanted
@20710 == BDDYNAHE
@20711
DO ~ JoinParty() ~ EXIT

/////                                                  \\\\\
///// Khalid & Jaheira                                 \\\\\
/////                                                  \\\\\

EXTEND_BOTTOM BDKHALID 121
  IF ~!StateCheck("jaheira",CD_STATE_NOTVALID) InMyArea("jaheira")~ THEN REPLY @20703 GOTO dmww_jaheiranotwanted
END

ADD_TRANS_TRIGGER BDJAHEIR 93 ~False()~ DO 2 
EXTEND_BOTTOM BDJAHEIR 93
  IF ~!StateCheck("khalid",CD_STATE_NOTVALID) InMyArea("khalid")~ THEN REPLY @20700 EXTERN BDKHALID dmww_khalidnotwanted
END

CHAIN 
IF ~~ THEN BDKHALID dmww_khalidnotwanted
@20701 == BDJAHEIR
@20702
DO ~ JoinParty()~ EXIT

CHAIN
IF ~~ THEN BDKHALID dmww_jaheiranotwanted
@20704 == BDJAHEIR
@20705
DO ~ActionOverride("khalid",JoinParty())~ EXIT