#!/bin/sh
/bin/rm -rf ~/.local/share/Trash/files/*
python -c "import utool; print(utool.get_freespace_str())"
