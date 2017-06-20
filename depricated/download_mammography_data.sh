mkdir "/data/mammorgraphy"
# http://marathon.csee.usf.edu/Mammography/Database.html
# DDSM Dataset
cd "/data/mammorgraphy"
mkdir "mamm_DDSM"
cd "mamm_DDSM"
wget -r -np -A * "ftp://figment.csee.usf.edu/pub/DDSM/cases"
# Lawrence Livermore Nat Labs + Uni of Cali at San Fran
# LLNL / UCSF Dataset
cd "/data/mammorgraphy"
mkdir "mamm_LLNL_UCSF"
cd "mamm_LLNL_UCSF"
wget -r -np -A * "ftp://gdo-biomed.ucllnl.org/pub/mammo-db/bundled/zip/"
mkdir zip
mv gdo-biomed.ucllnl.org/pub/mammo-db/bundled/zip/* zip
rm -rf gdo-biomed.ucllnl.org
# Unzip the files (the quotes are necessary for some reason)
7z x "zip/*.zip"
