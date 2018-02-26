if exist {local} (
echo 'in ~/local'
cd  %HOME%\local
) else (
mkdir %HOME%\local 
cd %HOME%\local
)

