cd /media/Store/data/
gvim ~/local/code/find-duplicates.py
mkdir maintenance


~/local/code/find-duplicates.py >> maintenance/duplicates.txt


grep -i -e '.png' -e '^$' maintenance/duplicates.txt

grep -i -e '.png' -e '^$' -v GZ_ALL2 -v GZ_ALL maintenance/duplicates.txt

fslint
