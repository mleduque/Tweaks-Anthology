REPLACE_TRIGGER_TEXT ~cechalle~ ~Class(Player1,DRUID\(_[A-Z]+\)?)~ ~True()~
REPLACE_TRIGGER_TEXT ~cechalle~ ~LevelLT(Player1,14)~ ~~
REPLACE_ACTION_TEXT  ~cechalle~ ~ReallyForceSpell(LastTalkedToBy,GREAT_DRUID_TITLE)~ ~~

REPLACE_TRIGGER_TEXT ~cefaldor~ ~Class(Player1,DRUID\(_[A-Z]+\)?)~ ~True()~

REPLACE_TRIGGER_TEXT ~druidad~  ~Class(Player1,DRUID\(_[A-Z]+\)?)~ ~True()~

// ee fixes
REPLACE_TRIGGER_TEXT ~cechalle~ ~Class(Player1,SHAMAN)~ ~False()~
REPLACE_TRIGGER_TEXT ~cefaldor~ ~Class(Player1,SHAMAN)~ ~False()~
REPLACE_TRIGGER_TEXT ~druidad~  ~Class(Player1,SHAMAN)~ ~False()~
