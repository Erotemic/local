
#http://www.wildme.org/wildbook/doku.php?id=manual:2.0.x:2_installation

# http://www.liquidweb.com/kb/how-to-install-apache-tomcat-8-on-ubuntu-14-04/


# multiline-python

sudo apt-get install openjdk-7-jdk

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

code 
git clone https://github.com/holmbergius/Wildbook.git
cd Wildbook/
git checkout ibeis

tomcat_wildbook_freshstart()
{
# --- FRESHSTART ---
# Make sure that tomcat vars are set
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

export WILDBOOK_TESTDIR=$CODE_DIR/Wildbook/tmp
export TOMCAT_DIR=$WILDBOOK_TESTDIR/apache-tomcat-8.0.24
export TOMCAT_HOME=$TOMCAT_DIR
export CATALINA_HOME=$TOMCAT_DIR

export WB_TARGET=ibeis

# ensure everything is shutdown before we start
$CATALINA_HOME/bin/shutdown.sh

# Clean up old tomcat
rm -rf $WILDBOOK_TESTDIR/apache-tomcat-8.0.24
# REMOVE EVERYTHING. 
rm -rf $WILDBOOK_TESTDIR
mkdir $WILDBOOK_TESTDIR
cd $WILDBOOK_TESTDIR

# Download and unzip tomcat
#cd $WILDBOOK_TESTDIR/..
#utzget http://www.gtlib.gatech.edu/pub/apache/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.zip

cd $WILDBOOK_TESTDIR
unzip -q $WILDBOOK_TESTDIR/../apache-tomcat-8.0.24.zip -d $WILDBOOK_TESTDIR

# make catalina runnable
chmod +x $CATALINA_HOME/bin/catalina.sh
chmod +x $CATALINA_HOME/bin/startup.sh
chmod +x $CATALINA_HOME/bin/shutdown.sh

# Install a wildbook .war file into tomcat webapps
# assumes we've already downloaded the war file
cp ~/Downloads/$WB_TARGET.war $CATALINA_HOME/webapps/

# RUN TOMCAT SERVER (WE MUST BE IN THE TESTDIR ON STARTUP)
$CATALINA_HOME/bin/startup.sh
#$CATALINA_HOME/bin/catalina.sh start

# Open wildbook in browser
sleep .5

# Either manually do the login
#google-chrome --new-window http://localhost:8080/$WB_TARGET
# firefox seems to do the trick
#firefox http://localhost:8080/$WB_TARGET

# OR Run selenium script to login
exec 42<<'__PYSCRIPT__'
# STARTBLOCK
import os
from selenium import webdriver
driver = webdriver.Firefox()
driver.get('http://localhost:8080/' + os.environ.get('WB_TARGET', 'ibeis'))

login_button = driver.find_element_by_partial_link_text('Log in')
login_button.click()

username_field = driver.find_element_by_name('username')
password_field = driver.find_element_by_name('password')
username_field.send_keys('tomcat')
password_field.send_keys('tomcat123')

submit_login_button = driver.find_element_by_name('submit')
submit_login_button.click()
# ENDBLOCK
__PYSCRIPT__
python /dev/fd/42 $@

# View logs
gvim $CATALINA_HOME/logs/catalina.out

# CLOSE TOMCAT SERVER
$CATALINA_HOME/bin/shutdown.sh
}


#utzget()
#{
#python -c "import utool as ut; ut.grab_zipped_url(\"$1\", download_dir=\".\")"
#}


#python -c 'import utool as ut; ut.grab_zipped_url("http://www.gtlib.gatech.edu/pub/apache/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.zip", download_dir=".")'



#python -c 'import utool as ut; ut.grab_zipped_url("http://dev.wildme.org/fluke/images/ibeis.war", download_dir=".")'


<<<<<<< HEAD
#apache-tomcat-8.0.24
=======

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
>>>>>>> 5a12af43085164c2a93975fa0ecca7a6340ad5b3

#utzget http://dev.wildme.org/fluke/images/ibeis.war
#utget http://dev.wildme.org/fluke/images/ibeis.war



# =============


#deploy_wildbook_war()
#{

#    # Download tomcat
#    utzget http://www.gtlib.gatech.edu/pub/apache/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.zip
#    export TOMCAT_DIR=$CODE_DIR/Wildbook/tmp/apache-tomcat-8.0.24
#    export TOMCAT_HOME=$TOMCAT_DIR
#    export CATALINA_HOME=$TOMCAT_DIR
#    cd $TOMCAT_DIR

#    # not sure if this is what is supposed to be removeed
#    #rm $TOMCAT_DIR/lib/websocket-api.jar

#    # Download ibeis.war into the webapps directory
#    cd $TOMCAT_DIR/webapps
#    #wget http://dev.wildme.org/fluke/images/ibeis.war
#    cp ~/Downloads/wildbook-5.3.0-RELEASE.war .

#    #wget http://www.wildme.org/wildbook/lib/exe/wildbook-5.3.0-RELEASE.war
#    #http://www.wildme.org/wildbook/lib/exe/fetch.php?hash=17bd9a&media=http%3A%2F%2Fwww.wildme.org%2Fwildbook%2Fdata%2Fmedia%2Fwildbook-5.3.0-RELEASE.war
#    # make catalina runnable
#    chmod +x $TOMCAT_DIR/bin/catalina.sh
#    chmod +x $CATALINA_HOME/bin/startup.sh
#chmod +x $CATALINA_HOME/bin/catalina.sh
#chmod +x $CATALINA_HOME/bin/startup.sh
#chmod +x $CATALINA_HOME/bin/shutdown.sh

#    gvim $TOMCAT_DIR/logs/catalina.out

#    # Launch tomcat
#    cd $TOMCAT_DIR/bin
#    $TOMCAT_DIR/bin/catalina.sh start

#    $CATALINA_HOME/bin/startup.sh
#    chmod +x $CATALINA_HOME/bin/startup.sh

#    ./catalina.sh start
#    sleep .5
#    google-chrome --new-window http://localhost:8080
#    google-chrome --new-window http://localhost:8080/ibeis
#    google-chrome --new-window http://localhost:8080/wildbook-5.3.0-RELEASE
#    wildbook-5.3.0-RELEASE.war

#    ./catalina.sh stop
#    $TOMCAT_DIR/bin/catalina.sh stop

#    http://localhost:8080/ibeis
#    tomcat
#    tomcat123
#    sh catalina.sh
#    sh catalina.sh start

#    google-chrome --new-window http://localhost:8080/ibeis
#    #sh catalina.sh stop

#    #  SELENIMUM SCRIPTS
#    pip install selenium

#    utzget http://chromedriver.storage.googleapis.com/2.16/chromedriver_linux64.zip
#    chmod +x chromedriver

#    export PATH=$PATH:$(pwd)

#    # TODO VIM SYNTAX EXTENSION
#    exec 42<<'__PYSCRIPT__'
#import utool as ut
#import os
#chromedriver = ut.truepath('chromedriver')
#ut.assert_exists(chromedriver)
#os.environ['webdriver.chrome.driver'] = chromedriver
#from selenium import webdriver
#driver = webdriver.Chrome()
#driver.get('http://localhost:8080/ibeis')

#login_button = driver.find_element_by_partial_link_text('Log in')
#login_button.click()

#username_field = driver.find_element_by_name('username')
#password_field = driver.find_element_by_name('password')
#username_field.send_keys('tomcat')
#password_field.send_keys('tomcat123')

#submit_login_button = driver.find_element_by_name('submit')
#submit_login_button.click()

#__PYSCRIPT__
#python /dev/fd/42 $@
#}

