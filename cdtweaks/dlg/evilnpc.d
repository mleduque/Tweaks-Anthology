// regexps are a little loose in that both BG2 Edwin and Viconia dialogues are matched, but neither use reaction checks in BG2

REPLACE_TRIGGER_TEXT_REGEXP ~\(^_?EDWIN_?$\)\|\(^_?ELDOTH$\)\|\(^_?KAGAIN$\)\|\(^_?MONTAR$\)\|\(^_?SHARTE$\)\|\(^_?TIAX$\)\|\(^_?\(BG\)?VICONI_?$\)\|\(^_?XZAR$\)~
  ~ReactionGT(LastTalkedToBy\((Myself)\)?,NEUTRAL_UPPER)~  ~ReactionGT(LastTalkedToBy(Myself),9)~

REPLACE_TRIGGER_TEXT_REGEXP ~\(^_?EDWIN_?$\)\|\(^_?ELDOTH$\)\|\(^_?KAGAIN$\)\|\(^_?MONTAR$\)\|\(^_?SHARTE$\)\|\(^_?TIAX$\)\|\(^_?\(BG\)?VICONI_?$\)\|\(^_?XZAR$\)~
  ~ReactionLT(LastTalkedToBy\((Myself)\)?,FRIENDLY_LOWER)~ ~ReactionLT(LastTalkedToBy(Myself),10)~

REPLACE_TRIGGER_TEXT_REGEXP ~\(^_?EDWIN_?$\)\|\(^_?ELDOTH$\)\|\(^_?KAGAIN$\)\|\(^_?MONTAR$\)\|\(^_?SHARTE$\)\|\(^_?TIAX$\)\|\(^_?\(BG\)?VICONI_?$\)\|\(^_?XZAR$\)~
  ~ReactionGT(LastTalkedToBy\((Myself)\)?,HOSTILE_UPPER)~  ~ReactionGT(LastTalkedToBy(Myself),3)~

REPLACE_TRIGGER_TEXT_REGEXP ~\(^_?EDWIN_?$\)\|\(^_?ELDOTH$\)\|\(^_?KAGAIN$\)\|\(^_?MONTAR$\)\|\(^_?SHARTE$\)\|\(^_?TIAX$\)\|\(^_?\(BG\)?VICONI_?$\)\|\(^_?XZAR$\)~
  ~ReactionLT(LastTalkedToBy\((Myself)\)?,NEUTRAL_LOWER)~  ~ReactionLT(LastTalkedToBy(Myself),4)~