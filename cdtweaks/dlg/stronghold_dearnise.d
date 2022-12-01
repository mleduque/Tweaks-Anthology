REPLACE_TRIGGER_TEXT ~nalia~    ~Class(Player1,FIGHTER\(_[A-Z]+\)?)~ ~True()~
REPLACE_TRIGGER_TEXT ~nalia~    ~Kit(Player1,Blackguard)~ ~True()~ // bg2ee

REPLACE_TRIGGER_TEXT ~naliaj~   ~Class(Player1,FIGHTER\(_[A-Z]+\)*)~ ~True()~
REPLACE_TRIGGER_TEXT ~naliaj~   ~Kit(Player1,Blackguard)~ ~True()~ // bg2ee

ADD_TRANS_ACTION demson 
BEGIN 119 END
BEGIN END
~EraseJournalEntry(22917)~
