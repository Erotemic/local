#!/bin/sh

set PORTNUM=5902
ssh -t -C -N -f -i %HOME%\.ssh\id_rsa joncrall@longerdog.com -L %PORTNUM%:localhost:5900
:: vncdisconnect()
:: {
    :: kill -9 $(lsof -i:$PORTNUM -t)
:: }

:: remmina
:: #vinagre --vnc-scale localhost:5902


