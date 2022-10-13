REPLACE_ACTION_TEXT ~%NEERA_POST%~   ~EscapeAreaMove("%FriendlyArmInn_L1%",[0-9]+,[0-9]+,[0-9A-Z]+)~  ~~
REPLACE_ACTION_TEXT ~%NEERA_POST%~   ~MoveToPoint(\[[0-9]+\.[0-9]+\])~  ~~
REPLACE_ACTION_TEXT ~%RASAAD_POST%~  ~EscapeAreaMove("%Nashkel%",[0-9]+,[0-9]+,[0-9A-Z]+)~  ~~
REPLACE_ACTION_TEXT ~%RASAAD_POST%~  ~SetGlobal("RASAADKicked","%Nashkel%",1)~  ~~
REPLACE_ACTION_TEXT ~%DORN_POST%~    ~EscapeAreaMove("%FriendlyArmInn_L1%",[0-9]+,[0-9]+,[0-9A-Z]+)~  ~~
ALTER_TRANS ~%DORN_POST%~ BEGIN 2 END BEGIN 0 END BEGIN ~JOURNAL~ ~~ END // remove journal entry about going to FAI