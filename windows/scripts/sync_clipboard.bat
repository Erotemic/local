:: Syncs clipboard from windows to linux machine
:: rob send_clipboard_to joncrall@hyrule.cs.rpi.edu 
rm clipboard.txt
call rob dump_clipboard "clipboard.txt"
cat "clipboard.txt"
echo "scping"
scp clipboard.txt joncrall@hyrule.cs.rpi.edu:clipboard.txt
:: ssh -X joncrall@hyrule.cs.rpi.edu "DISPLAY=:10.0 xsel --clipboard < ~/clipboard.txt"
:: ssh -X joncrall@hyrule.cs.rpi.edu "xsel --clipboard < ~/clipboard.txt"
echo "sshing"
:: ssh -X joncrall@hyrule.cs.rpi.edu DISPLAY=:10.0 xsel --clipboard < clipboard.txt
echo "synced"
:: ssh -X joncrall@hyrule.cs.rpi.edu cat clipboard.txt
echo "done"
