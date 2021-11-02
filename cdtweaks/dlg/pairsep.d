EXTEND_BOTTOM ~%JAHEIRA_POST%~ ~%jaheira_loc%~

IF ~!StateCheck("khalid",CD_STATE_NOTVALID) InMyArea("khalid")~ THEN REPLY @20700   EXTERN ~%KHALID_POST%~ dmww_khalidnotwanted
END

CHAIN 
IF ~~ THEN %KHALID_POST% dmww_khalidnotwanted
@20701 == %JAHEIRA_POST%
@20702
DO ~ SetGlobal("%kicked_out_variable%","LOCALS",0)JoinParty()~ EXIT

EXTEND_BOTTOM ~%KHALID_POST%~ %khalid_loc%

IF ~!StateCheck("jaheira",CD_STATE_NOTVALID) InMyArea("jaheira")~ THEN REPLY @20703 GOTO dmww_jaheiranotwanted
END

CHAIN
IF ~~ THEN %KHALID_POST% dmww_jaheiranotwanted
@20704 == %JAHEIRA_POST%
@20705
DO ~ActionOverride("khalid",JoinParty())~ EXIT

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EXTEND_BOTTOM ~%MINSC_POST%~ %minsc_loc%

IF ~!StateCheck("dynaheir",CD_STATE_NOTVALID) InMyArea("dynaheir")~ THEN REPLY @20706 GOTO dmww_dynaheirnotwanted
END

CHAIN
IF ~~ THEN %MINSC_POST% dmww_dynaheirnotwanted
@20707 == %DYNAHEIR_POST%
@20708
DO ~ActionOverride("minsc",JoinParty())~ 
EXIT

EXTEND_BOTTOM ~%DYNAHEIR_POST%~ %dynaheir_loc%

IF ~!StateCheck("minsc",CD_STATE_NOTVALID) InMyArea("minsc")~ THEN REPLY @20709 EXTERN ~%MINSC_POST%~ dmww_minscnotwanted
END

CHAIN 
IF ~~ THEN %MINSC_POST% dmww_minscnotwanted
@20710 == %DYNAHEIR_POST%
@20711
DO ~SetGlobal("%kicked_out_variable%","LOCALS",0) JoinParty() ~ EXIT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


EXTEND_BOTTOM ~%MONTARON_POST%~ %montaron_loc%

IF ~!StateCheck("xzar",CD_STATE_NOTVALID) InMyArea("xzar")~ THEN REPLY @20712 EXTERN ~%XZAR_POST%~ dmww_xzarnotwanted
END

CHAIN
IF ~~ THEN %XZAR_POST% dmww_xzarnotwanted
@20713 == %MONTARON_POST%
@20714 
DO ~SetGlobal("%kicked_out_variable%","LOCALS",0) JoinParty() ~ EXIT

EXTEND_BOTTOM ~%XZAR_POST%~ %xzar_loc%

IF ~!StateCheck("montaron",CD_STATE_NOTVALID) InMyArea("montaron")~ THEN REPLY @20715 GOTO dmww_montaronnotwanted
END

CHAIN
IF ~~ THEN %XZAR_POST% dmww_montaronnotwanted
@20716 == %MONTARON_POST%
@20717
DO ~ActionOverride("xzar",JoinParty())~ EXIT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EXTEND_BOTTOM ~%ELDOTH_POST%~ %eldoth_loc%

IF ~!StateCheck("skie",CD_STATE_NOTVALID) InMyArea("skie")~ THEN REPLY @20726 GOTO dmww_skienotwanted
END

CHAIN
IF ~~ THEN %ELDOTH_POST% dmww_skienotwanted
@20718 = @20719 == %SKIE_POST%
@20720 = @20721
DO ~ActionOverride("eldoth",JoinParty())~
EXIT

EXTEND_BOTTOM ~%SKIE_POST%~ %skie_loc%

IF ~!StateCheck("eldoth",CD_STATE_NOTVALID) InMyArea("eldoth")~ THEN REPLY @20725 GOTO dmww_eldothnotwanted
END

CHAIN
IF ~~ THEN %SKIE_POST% dmww_eldothnotwanted
@20722 == %ELDOTH_POST%
@20723=@20724
DO ~ActionOverride("skie",JoinParty())~
EXIT


