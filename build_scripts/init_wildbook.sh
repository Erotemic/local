
#http://www.wildme.org/wildbook/doku.php?id=manual:2.0.x:2_installation

code 
git clone https://github.com/holmbergius/Wildbook.git
cd Wildbook/

utzget()
{
python -c "import utool as ut; ut.grab_zipped_url(\"$1\", download_dir=\".\")"
}


python -c 'import utool as ut; ut.grab_zipped_url("http://www.gtlib.gatech.edu/pub/apache/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.zip", download_dir=".")'



python -c 'import utool as ut; ut.grab_zipped_url("http://dev.wildme.org/fluke/images/ibeis.war", download_dir=".")'


apache-tomcat-8.0.24

utzget http://dev.wildme.org/fluke/images/ibeis.war
utget http://dev.wildme.org/fluke/images/ibeis.war


grab_ibeis_war()                                                           
{                                                                                     
    # From patchy
    scp jonc@pachy.cs.uic.edu:/var/lib/tomcat/webapps/ibeis.war ~/Downloads/pachy_ibeis.war
    # From Lewa
    scp jonathan@ibeis.cs.uic.edu:/var/lib/tomcat/webapps/ibeis.war ~/Downloads/lewa_ibeis.war
    # Slightly less volitile location
    http://dev.wildme.org/ibeis_data_dir/ibeis.war
} 

deploy_wildbook_war()
{
    cd $CODE_DIR/Wildbook/apache-tomcat-8.0.24/webapps
    wget http://dev.wildme.org/fluke/images/ibeis.war

    chmod +x catalina.sh
    ./catalina.sh start
    sleep .5
    google-chrome --new-window http://localhost:8080/ibeis

    ./catalina.sh stop

    http://localhost:8080/ibeis
    tomcat
    tomcat123
    sh catalina.sh
    sh catalina.sh start

    google-chrome --new-window http://localhost:8080/ibeis
    #sh catalina.sh stop

    #  SELENIMUM SCRIPTS
    pip install selenium

    utzget http://chromedriver.storage.googleapis.com/2.16/chromedriver_linux64.zip
    chmod +x chromedriver

    export PATH=$PATH:$(pwd)

    # TODO VIM SYNTAX EXTENSION
    exec 42<<'__PYSCRIPT__'
import utool as ut
import os
chromedriver = ut.truepath('chromedriver')
ut.assert_exists(chromedriver)
os.environ['webdriver.chrome.driver'] = chromedriver
from selenium import webdriver
driver = webdriver.Chrome()
driver.get('http://localhost:8080/ibeis')

login_button = driver.find_element_by_partial_link_text('Log in')
login_button.click()

username_field = driver.find_element_by_name('username')
password_field = driver.find_element_by_name('password')
username_field.send_keys('tomcat')
password_field.send_keys('tomcat123')

submit_login_button = driver.find_element_by_name('submit')
submit_login_button.click()

__PYSCRIPT__
python /dev/fd/42 $@
}

