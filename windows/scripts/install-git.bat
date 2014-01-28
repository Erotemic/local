if exist {local} (
echo 'in ~/local'
cd  %HOME%\local
) else (
mkdir %HOME%\local 
cd %HOME%\local
)


if exist ca-bundle.crt (
echo 'have ca-bundle.crt'
) else (
echo "downloading ca-bundle.crt"
call install_certdata.bat
echo "downloaded ca-bundle.crt"
)

set TODOWNLOAD="https://msysgit.googlecode.com/files/PortableGit-1.8.4-preview20130916.7z"

if exist PortableGit-1.8.4-preview20130916.7z (
echo "already downloaded"
)
else(
echo "downloading: %TODOWNLOAD%"
wget --no-check-certificate %TODOWNLOAD%
:: wget --ca-certificate=ca-bundle.crt %TODOWNLOAD%
:: wget --certificate=ca-bundle.crt %TODOWNLOAD%
:: wget --certificate=certdata.txt %TODOWNLOAD%
:: wget --ca-directory=%HOME%/local %TODOWNLOAD%
:: wget --no-check-certificate --ca-certificate=ca-bundle.crt %TODOWNLOAD%
echo "downloaded %filename%"
)

mkdir git
cd git
7z x ..\PortableGit-1.8.4-preview20130916.7z

