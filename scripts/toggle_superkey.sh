#!/bin/bash 
__heredoc__='
Changes the superkey between Alt_R and Super_L so I can play starcraft without
hitting the superkey and messing everything up.
'
CURRENT_=$(gsettings get org.gnome.mutter overlay-key)
if [[ "${CURRENT_}" = "'Super_L'" ]]; then
    NEXT_="Alt_R"
else
    NEXT_="Super_L"
fi
echo "CURRENT_ = $CURRENT_"
echo "NEXT_ = $NEXT_"
gsettings set org.gnome.mutter overlay-key "$NEXT_"
gsettings get org.gnome.mutter overlay-key
