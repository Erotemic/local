
#http://www.wildme.org/wildbook/doku.php?id=manual:2.0.x:2_installation

code 
git clone https://github.com/holmbergius/Wildbook.git

utzget()
{
python -c "import utool as ut; ut.grab_zipped_url(\"$1\", download_dir=".")"
}


python -c 'import utool as ut; ut.grab_zipped_url("http://www.gtlib.gatech.edu/pub/apache/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.zip", download_dir=".")'



python -c 'import utool as ut; ut.grab_zipped_url("http://dev.wildme.org/fluke/images/ibeis.war", download_dir=".")'

utzget http://dev.wildme.org/fluke/images/ibeis.war
