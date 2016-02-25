#!/bin/bash#  buildApplicationServer.sh#  This script installs Apache and PHP, brings the components up, and then populates a sample web application at /var/www/html/index.php
#  It is intended for use with RHEL guests
#  When executing via the IBM Wave Script Manager, be sure to execute as root#  Version 1.1#  Sean Patrick McBride. May 21, 2014# Function buildWebSite() uses cat to write out a simple web applicationfunction buildWebSite(){cat << _EOF_<!DOCTYPE html><html lang='en'><head>	<title>US Census Web App </title></head><body>        <?php		if( \$_POST["ipaddress"] ) {        		// Create connection        		\$ipaddress = \$_POST["ipaddress"];        		echo "<h1>Connecting to MySQL on \$ipaddress </h1>";        		\$con=mysqli_connect(\$ipaddress,"root","census","itm411db");        		// Check connection        		if (mysqli_connect_errno()) {                		echo "Failed to connect to MySQL: " . mysqli_connect_error();        		} else {				\$result = mysqli_query(\$con,"SELECT NAME, CENSUS2010POP, BIRTHS2010, DEATHS2010, NETMIG2010 FROM itm411db.populationrecords WHERE SUMLEV=40;");        		echo "<table border='1'>                	<tr>                        	<th>State</th>                        	<th>Population</th>                        	<th>Births</th>                        	<th>Deaths</th>                        	<th>Net Migration</th>                	</tr>";				while(\$row = mysqli_fetch_array(\$result)) {                		echo "<tr>";                  		echo "<td>" . \$row['NAME'] . "</td>";                  		echo "<td>" . \$row['CENSUS2010POP'] . "</td>";                  		echo "<td>" . \$row['BIRTHS2010'] . "</td>";                  		echo "<td>" . \$row['DEATHS2010'] . "</td>";                  		echo "<td>" . \$row['NETMIG2010'] . "</td>";                  		echo "</tr>";                	}        		echo "</table>";				mysqli_close(\$con);				}		} else {                        echo "Enter the IP Address of your MySQL Server:";                        echo "<form action='\$_PHP_SELF' method='post'>";                        echo "  <input type='text' name='ipaddress' size='20' />";                        echo "  <input type='submit' name='submit' />";                        echo "</form>";                }	?></body></html>_EOF_}

# Part One: Install Apache Web Server and PHP# Check if rootif [ $(whoami) != root ]; then   echo " Must be root to use."   exitfi# Quit if not RHEL or SLESif [ $(grep -c -m 1 -i "Red Hat Enterprise Linux Server" /etc/issue) != 1 ]; then   if [ $(grep -c -m 1 -i "suse" /etc/issue) != 1 ]; then      echo "This is not a RHEL or SLES guest. Quitting."      exit   fifi#Part One: Perform Distro-specific procedures to Apache Web Server and PHP#If RHEL, install MySQL using yum, instruct chkconfig to start mysqld at boot, and start mysqld now   if [ $(grep -c -m 1 -i "Red Hat Enterprise Linux Server" /etc/issue) = 1 ]; then   echo "Red Hat Enterprise Linux Detected."   echo "Installing Apache Web Server and PHP"   yum -y install httpd php php-*

   # Part Two: Set Apache to start at boot and start Apache services   echo "Starting Apache Web Server"   chkconfig httpd on   /etc/init.d/httpd start

   # Part Three: Invoke the buildWebSite() function to write the web app to index.php in the default Apache html directory   echo "Populating Sample Web App"   buildWebSite > /var/www/html/index.php  fi#If SLES, install MySQL using zypper, instruct chkconfig to start mysql at boot, and start mysql nowif [ $(grep -c -m 1 -i "suse" /etc/issue) = 1 ]; then   echo "Suse Linux Enterprise Sever Detected."   echo "Installing Apache Web Server and PHP"   zypper -n in apache2 apache2-mod_php53 php53*   # Part Two: Set Apache to start at boot and start Apache services   echo "Starting Apache Web Server"   chkconfig apache2 on   /etc/init.d/apache2 start   # Part Three: Invoke the buildWebSite() function to write the web app to index.php in the default Apache html directory

   echo "Populating Sample Web App"   buildWebSite > /srv/www/htdocs/index.php  fi