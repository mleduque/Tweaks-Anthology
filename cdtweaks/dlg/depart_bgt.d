// bgt adds actions to send J&K back to the FAI, something tutu/bgee/eet don't have
REPLACE_ACTION_TEXT ~%JAHEIRA_POST%~ ~ActionOverride("Khalid",EscapeAreaMove("%FriendlyArmInn_L1%",328,656,14))~ ~~
REPLACE_ACTION_TEXT ~%JAHEIRA_POST%~ ~EscapeAreaMove("%FriendlyArmInn_L1%",315,711,13)~  ~~

REPLACE_ACTION_TEXT ~%KHALID_POST%~ ~ActionOverride("Jaheira",EscapeAreaMove("%FriendlyArmInn_L1%",315,711,13))~ ~~
REPLACE_ACTION_TEXT ~%KHALID_POST%~ ~EscapeAreaMove("%FriendlyArmInn_L1%",328,656,14)~  ~~