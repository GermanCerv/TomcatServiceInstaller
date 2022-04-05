#!/bin/bash

clear

##VARIABLES
filesLocation=$(pwd)
answer="n"

while [[ "$answer" == "n" ]]
do
	echo "================================================="
	echo "TOMCAT INSTALLATION VARIABLES"
	echo "================================================="
	echo ""
	read -p "Tomcat new installation path: " tomcatPath
	read -p "tomcatmgr password: " tomcatmgrPass
	read -p "Manager Max File Size (MB): " mgrMaxFileSize
	read -p "Parameter XMS value to JVM (MB): " xmsJVM
	read -p "Parameter XMX value to JVM (MB): " xmxJVM
	echo ""
	echo "================================================="
	echo "Summary:"
	echo " - Tomcat installation path:" $tomcatPath
	echo " - tomcatmgr password:" $tomcatmgrPass
	echo " - Manager Max File Size:" $mgrMaxFileSize"MB -> ("$((mgrMaxFileSize*1024*1024))")"
	echo " - Parameter XMS value to JVM:" $xmsJVM"MB"
	echo " - Parameter XMX value to JVM:" $xmxJVM"MB"
	echo "================================================="
	
	read -p "Is this configuration OK? (y, n, q): " answer
	
	if [[ "$answer" == "q" ]]
	then
		echo "Bye :)"
		exit 1
	fi

	echo ""
	echo ""


	#Last variable preparation
	mgrMaxFileSize=$((mgrMaxFileSize*1024*1024))

done

echo ""
echo "================================================="
echo "TOMCAT INSTALLATION"
echo "================================================="
echo ""

#Installing JDK and auxiliar commands
apt update -y
apt install default-jdk tar wget -y

#TomcatUser No shell access
mkdir -p $tomcatPath
groupadd tomcat
useradd tomcat -s /bin/false -g tomcat -m -d $tomcatPath

#Download and untar Tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.20/bin/apache-tomcat-10.0.20.tar.gz
tar xzvf apache-tomcat-10*tar.gz -C $tomcatPath
ln -s $tomcatPath/apache-tomcat-10* $tomcatPath/tomcat
chown -R tomcat: $tomcatPath
find ${tomcatPath}/tomcat/bin/ -name "*.sh" -exec chmod +x {} \;

#Configuration file copying
cp -f $filesLocation/tomcat-users.xml ${tomcatPath}/tomcat/conf/

#Configuration file edition
sed -i "s/temporalPass/$tomcatmgrPass/g" ${tomcatPath}/tomcat/conf/tomcat-users.xml
sed -i "s/52428800/$mgrMaxFileSize/g" ${tomcatPath}/tomcat/webapps/manager/WEB-INF/web.xml

sedtomcatPath=""
aux=0
while [[ $aux -le ${#tomcatPath} ]]
do
	if [[ ${tomcatPath:aux:1} == "/" ]]
	then
		sedtomcatPath="$sedtomcatPath\\"
	fi
	sedtomcatPath="$sedtomcatPath${tomcatPath:aux:1}"
	aux=$((aux+1))
done

sed -i "s/TOMCATPATH/$sedtomcatPath/g" ${filesLocation}/tomcat.service
sed -i "s/XMSVALUE/$xmsJVM/g" $filesLocation/tomcat.service
sed -i "s/XMXVALUE/$xmxJVM/g" $filesLocation/tomcat.service

#Service
cp -f $filesLocation/tomcat.service /etc/systemd/system/
systemctl enable tomcat
systemctl start tomcat
