#!/bin/bash


###############################################################################
#                             install_root script                             #
#  This script is designed for faster installation of ARIADNA MIS on Linux    #
#  systems.                                                                   #
###############################################################################

###############################################################################
# Variables                                                                   #
###############################################################################

username='username'
ip_mount='192.168.0.0'
username_share='share'
password_share=''
domain=''

#Варианты AltLinux8,AltLinux9,RedOS,AstraLinux,RosaLinux,Ubuntu,Centos8
distr=''
url_java=""

###############################################################################
# Functions                                                                   #
###############################################################################

function Get_Base_Info(){

    read -r -p "Введите имя пользователя: " response
    username=$response

    read -r -p "Введите IP-адрес сервера данных: " response
    ip_mount=$response

    read -r -p "Введите имя пользователя БД: " response
    username_share=$response

    read -r -p "Введите пароль БД: " response
    password_share=$response

    read -r -p "Введите доменное имя [при наличии]: " response
    domain=$response

}

function Select_Distro(){
    echo "Полуавтоматическая установка доступна для дистрибутивов:"
    echo "1. Alt Linux 8"
    echo "2. Alt Linux 9"
    echo "3. RedOS"
    echo "4. Astra Linux"
    echo "5. ROSA Linux"
    echo "6. Ubuntu"
    echo "7. CentOS 8"

    while [[ $distr = "" ]]
    do
        read -r -p "Введите порядковый номер используемого дистрибутива: " response
        if [[ $response -eq 1 ]];
        then
            distr='AltLinux8'
        elif [[ $response -eq 2 ]];
        then
            distr='AltLinux9'
        elif [[ $response -eq 3 ]];
        then
            distr='RedOS'
        elif [[ $response -eq 4 ]];
        then
            distr='AstraLinux'
        elif [[ $response -eq 5 ]];
        then
            distr='RosaLinux'
        elif [[ $response -eq 6 ]];
        then
            distr='Ubuntu'
        elif [[ $response -eq 7 ]];
        then
            distr='Centos8'
        else
            echo "Некорректный ввод."
        fi
    done

}

function Select_Java_Version(){

    if [[ $(getconf LONG_BIT) -eq 64 ]];
    then

        echo "Доступны следующие дистрибутивы Java:"
        echo "1. Java Runtime Environment 8 x64"
        echo "2. Java Runtime Environment 6 x64"

        while [[ $url_java = "" ]]
        do
            read -r -p "Выберите версию дистрибутива Java: " response
            if [[ $response -eq 1 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-8u301-linux-x64.tar.gz"
            elif [[ $response -eq 2 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-6u45-linux-x64.bin"
            else
                echo "Некорректный ввод."
            fi
        done

    else

        echo "Доступны следующие дистрибутивы Java:"
        echo "1. Java Runtime Environment 8 i586"
        echo "2. Java Runtime Environment 6 i586"

        while [[ $url_java = "" ]]
        do
            read -r -p "Выберите версию дистрибутива Java: " response
            if [[ $response -eq 1 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-8u301-linux-i586.tar.gz"
            elif [[ $response -eq 2 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-6u45-linux-i586.bin"
            else
                echo "Некорректный ввод."
            fi
        done

    fi

}


function Mount_ARM(){

cd /home/$username/linux_installer

if [ -d /mnt/ARM ];
then
    echo 'Каталог /mnt/ARM уже существует' >> /home/$username/linux_installer/install_log.log
else
		echo 'Создание каталога /mnt/ARM' >> /home/$username/linux_installer/install_log.log
		mkdir /mnt/ARM
		if [$? -eq 0];
    then
        echo 'Каталог /mnt/ARM создан' >> /home/$username/linux_installer/install_log.log
    else
        echo 'Невозможно создать каталог /mnt/ARM' >> /home/$username/linux_installer/install_log.log
    fi
fi

if [ -d /mnt/ARM/APP ];
then
    echo 'Каталог /mnt/ARM/APP уже монтирован' >> /home/$username/linux_installer/install_log.log
else
    if [ $distr = 'AstraLinux' ];
    then
        echo 'Монтирование каталога' >> /home/$username/linux_installer/install_log.log
				if [ $domain = '' ];
        then
            sudo mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share
				else
            sudo mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share,domain=$domain
				fi
    else
        echo 'Монтирование каталога' >> /home/$username/linux_installer/install_log.log
				if [ $domain = '' ];
        then
            mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share
				else
            mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share,domain=$domain
				fi
			  echo 'Каталог с АРМами монтирован в каталог /mnt/ARM' >> /home/$username/linux_installer/install_log.log
    fi
fi

if [ -f updater.sh ];
then
    echo 'updater.sh уже существует' >> /home/$username/linux_installer/install_log.log
else
		cd /home/$username
		echo 'Создание updater.sh' >> /home/$username/linux_installer/install_log.log
		touch updater.sh
		echo 'Sh скрипт updater.sh создан' >> /home/$username/linux_installer/install_log.log
fi

if [[ $distr = 'AltLinux8' || $distr = 'AltLinux9' || $distr = 'Centos8' ]];
then
    {
      echo 'sleep 30'
      echo 'mount -t cifs //'$ip_mount'/ARIADNA/ /mnt/ARM -o username='$username_share',rw,password='$password_share''
      echo 'sleep 10'
      echo 'cp -a -u -f /mnt/ARM/APP/. /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chown -R '$username':'$username' /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chmod -R 777 /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo -e '\n'
    } > 'updater.sh'
fi


if [[ $distr = 'RedOS' || $distr = 'AstraLinux' || $distr = 'RosaLinux' || $distr = 'Ubuntu' ]];
then
    {
      echo 'sleep 30'
      echo 'sudo mount -t cifs //'$ip_mount'/ARIADNA/ /mnt/ARM -o username='$username_share',rw,password='$password_share''
      echo 'sleep 10'
      echo 'sudo cp -a -u -f /mnt/ARM/APP/. /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chown -R '$username':'$username' /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chmod -R 777 /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo -e '\n'
    } > 'updater.sh'
fi



if [[ $distr = 'AstraLinux' || $distr = 'Ubuntu' ]]; then
	sudo echo '@reboot sh /home/'$username'/updater.sh' > /var/spool/cron/root
	else
	echo '@reboot sh /home/'$username'/updater.sh' > /var/spool/cron/root
	fi

}


function Install_Java(){

cd /home/$username/linux_installer


#Java 6 Version x32
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-6u45-linux-i586.bin' ]];
then

    if [ -d /opt/java/jre1.6.0_45 ];
    then
        echo 'Каталог /opt/java/jre1.6.0_45 уже создан, JAVA установлена' >> /home/$username/linux_installer/install_log.log
		else
        echo 'Создание каталога /opt/java' >> /home/$username/linux_installer/install_log.log
        mkdir /opt/java
    fi

    if [ -f jre-6u45-linux-i586.bin ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> /home/$username/linux_installer/install_log.log
		else
				echo 'Дистрибутива JAVA нет' >> /home/$username/linux_installer/install_log.log
				echo 'Скачивание дистрибутива java' >> /home/$username/linux_installer/install_log.log
				wget $url_java
    fi

    if [ -d /home/$username/jre1.6.0_45 ];
    then
		    echo 'JAVA Распакована'  >> /home/$username/linux_installer/install_log.log
		else
        echo 'Разархивация JAVA'  >> /home/$username/linux_installer/install_log.log
        chmod a+x /home/$username/linux_installer/jre-6u45-linux-i586.bin
        /home/$username/linux_installer/jre-6u45-linux-i586.bin
        echo 'Удаление jre-6u45-linux-i586.bin' >> /home/$username/linux_installer/install_log.log
        rm -f jre-6u45-linux-i586.bin
    fi

    if [ -d /opt/java/jre1.6.0_45 ];
    then
		    echo 'Найдена JAVA в каталоге /opt/java/jre1.6.0_45' >> /home/$username/linux_installer/install_log.log
		else
        echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.6.0_45 в /opt/java/jre1.6.0_45' >> /home/$username/linux_installer/install_log.log
        mv /home/$username/linux_installer/jre1.6.0_45 /opt/java/jre1.6.0_45
        echo 'Каталог перемещен'  >> /home/$username/linux_installer/install_log.log
        echo 'Регистрация JAVA в PATH' >> /home/$username/linux_installer/install_log.log
        export PATH=$PATH:/opt/java/jre1.6.0_45/bin/
        echo 'PATH зарегистрирован' >> /home/$username/linux_installer/install_log.log
    fi
fi

#Java 6 Version x64
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-6u45-linux-x64.bin' ]];
then

    if [ -d /opt/java/jre1.6.0_45 ];
    then
        echo 'Каталог /opt/java/jre1.6.0_45 уже создан, JAVA установлена' >> /home/$username/linux_installer/install_log.log
		else
        echo 'Создание каталога /opt/java' >> /home/$username/linux_installer/install_log.log
        mkdir /opt/java
    fi

    if [ -f jre-6u45-linux-x64.bin ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> /home/$username/linux_installer/install_log.log
		else
				echo 'Дистрибутива JAVA нет' >> /home/$username/linux_installer/install_log.log
				echo 'Скачивание дистрибутива java' >> /home/$username/linux_installer/install_log.log
				wget $url_java
    fi

    if [ -d /home/$username/jre1.6.0_45 ];
    then
		    echo 'JAVA Распакована'  >> /home/$username/linux_installer/install_log.log
		else
        echo 'Разархивация JAVA'  >> /home/$username/linux_installer/install_log.log
        chmod a+x /home/$username/linux_installer/jre-6u45-linux-x64.bin
        /home/$username/linux_installer/jre-6u45-linux-x64.bin
        echo 'Удаление jre-6u45-linux-x64.bin' >> /home/$username/linux_installer/install_log.log
        rm -f jre-6u45-linux-x64.bin
    fi

    if [ -d /opt/java/jre1.6.0_45 ];
    then
        echo 'Найдена JAVA в каталоге /opt/java/jre1.6.0_45' >> /home/$username/linux_installer/install_log.log
		else
			  echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.6.0_45 в /opt/java/jre1.6.0_45' >> /home/$username/linux_installer/install_log.log
			  mv /home/$username/linux_installer/jre1.6.0_45 /opt/java/jre1.6.0_45
			  echo 'Каталог перемещен'  >> /home/$username/linux_installer/install_log.log
			  echo 'Регистрация JAVA в PATH' >> /home/$username/linux_installer/install_log.log
			  export PATH=$PATH:/opt/java/jre1.6.0_45/bin/
			  echo 'PATH зарегистрирован' >> /home/$username/linux_installer/install_log.log
    fi
fi

#Java 8 Version x32
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-8u301-linux-i586.tar' ]];
then
    if [ -d /opt/java/jre1.8.0_301 ];
    then
        echo 'Каталог /opt/java/jre1.8.0_301 уже создан, JAVA установлена' >> /home/$username/linux_installer/install_log.log
		else
        echo 'Создание каталога /opt/java' >> /home/$username/linux_installer/install_log.log
        mkdir /opt/java
    fi

    if [ -f jre-8u301-linux-i586.tar ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> /home/$username/linux_installer/install_log.log
    else
        echo 'Дистрибутива JAVA нет' >> /home/$username/linux_installer/install_log.log
        echo 'Скачивание дистрибутива java' >> /home/$username/linux_installer/install_log.log
				wget $url_java
    fi

    if [ -d /home/$username/jre1.8.0_301 ];
    then
		    echo 'JAVA Распакована'  >> /home/$username/linux_installer/install_log.log
		else
        echo 'Разархивация JAVA'  >> /home/$username/linux_installer/install_log.log
			  tar -xvz /home/$username/linux_installer/jre-8u301-linux-i586.tar
			  echo 'Удаление jre-8u301-linux-i586.tar' >> /home/$username/linux_installer/install_log.log
        rm -f jre-8u301-linux-i586.tar
    fi

    if [ -d /opt/java/jre1.8.0_301 ];
    then
		    echo 'Найдена JAVA в каталоге /opt/java/jre1.8.0_301' >> /home/$username/linux_installer/install_log.log
    else
        echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.8.0_301 в /opt/java/jre1.8.0_301' >> /home/$username/linux_installer/install_log.log
        mv /home/$username/linux_installer/jre1.8.0_301 /opt/java/jre1.8.0_301
        echo 'Каталог перемещен'  >> /home/$username/linux_installer/install_log.log
        echo 'Регистрация JAVA в PATH' >> /home/$username/linux_installer/install_log.log
        export PATH=$PATH:/opt/java/jre1.8.0_301/bin/
        echo 'PATH зарегистрирован' >> /home/$username/linux_installer/install_log.log
    fi
fi

#Java 8 Version x64
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-8u301-linux-x64.tar' ]];
then
    if [ -d /opt/java/jre1.8.0_301 ];
    then
        echo 'Каталог /opt/java/jre1.8.0_301 уже создан, JAVA установлена' >> /home/$username/linux_installer/install_log.log
		else
        echo 'Создание каталога /opt/java' >> /home/$username/linux_installer/install_log.log
        mkdir /opt/java
    fi

    if [ -f jre-8u301-linux-x64.tar ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> /home/$username/linux_installer/install_log.log
    else
				echo 'Дистрибутива JAVA нет' >> /home/$username/linux_installer/install_log.log
				echo 'Скачивание дистрибутива java' >> /home/$username/linux_installer/install_log.log
				wget $url_java
    fi

    if [ -d /home/$username/jre1.8.0_301 ];
    then
		    echo 'JAVA Распакована'  >> /home/$username/linux_installer/install_log.log
    else
        echo 'Разархивация JAVA'  >> /home/$username/linux_installer/install_log.log
        tar -xvz /home/$username/linux_installer/jre-8u301-linux-x64.tar
        echo 'Удаление jre-8u301-linux-x64.tar' >> /home/$username/linux_installer/install_log.log
        rm -f jre-8u301-linux-x64.tar
    fi

    if [ -d /opt/java/jre1.8.0_301 ];
    then
		    echo 'Найдена JAVA в каталоге /opt/java/jre1.8.0_301' >> /home/$username/linux_installer/install_log.log
    else
        echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.8.0_301 в /opt/java/jre1.8.0_301' >> /home/$username/linux_installer/install_log.log
        mv /home/$username/linux_installer/jre1.8.0_301 /opt/java/jre1.8.0_301
        echo 'Каталог перемещен'  >> /home/$username/linux_installer/install_log.log
        echo 'Регистрация JAVA в PATH' >> /home/$username/linux_installer/install_log.log
        export PATH=$PATH:/opt/java/jre1.8.0_301/bin/
        echo 'PATH зарегистрирован' >> /home/$username/linux_installer/install_log.log
    fi
fi

if [[ $distr = 'AltLinux8' ]]; then
    apt-get install i586-libXtst.32bit -y
fi

if [[ $distr = 'AltLinux9' ]]; then
    apt-get install i586-libXtst.32bit i586-libnsl1.32bit libnsl1 -y
fi

if [[ $distr = 'Ubuntu' ]]; then
    apt-get apt-get install libxtst6:i386 -y
fi

if [[ $distr = 'Centos8' ]]; then
    wget http://repo.okay.com.mx/centos/8/x86_64/release/libXtst-1.2.3-7.el8.x86_64.rpm
    rpm -ivh libXtst-1.2.3-7.el8.x86_64.rpm
    rm libXtst-1.2.3-7.el8.x86_64.rpm
    yum install libnsl.i686 -y
    yum install libnsl.x86_64 -y
fi

}

function Install_Wine() {

cd /home/$username/linux_installer

if [[ $distr = 'AstraLinux' ]];
then
  	echo 'Установка wine, конфигурация AstraLinux' >> /home/$username/linux_installer/install_log.log
  	apt-get update && apt-get upgrade -y
  	apt-get install wine winetricks zenity -y
fi

if [[ $distr = 'Ubuntu' ]];
then
  	echo 'Установка wine, конфигурация Ubuntu' >> /home/$username/linux_installer/install_log.log
  	apt-get update && apt-get upgrade -y
  	apt-get install wine winetricks zenity -y
fi

if [[ $distr = 'AltLinux8' ]];
then
  	echo 'Установка wine, конфигурация AltLinux8' >> /home/$username/linux_installer/install_log.log
  	apt-get update && apt-get dist-upgrade -y
  	apt-get install i586-wine.32bit wine wine-gecko wine-mono winetricks -y
fi

if [[ $distr = 'AltLinux9' ]];
then
  	echo 'Установка wine, конфигурация AltLinux9' >> /home/$username/linux_installer/install_log.log
  	apt-get update && apt-get dist-upgrade -y
  	apt-get install i586-wine.32bit wine-mono winetricks -y
fi

if [[ $distr = 'RedOS' ]];
then
  	echo 'Установка wine, конфигурация RedOS' >> /home/$username/linux_installer/install_log.log
  	yum update && yum upgrade -y
  	yum install wine winetricks -y
fi

if [[ $distr = 'RosaLinux' ]];
then
  	echo 'Установка wine, конфигурация RosaLinux' >> /home/$username/linux_installer/install_log.log
  	yum update && yum upgrade -y
  	sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
  	cd /home/$username/linux_installer
  	mkdir /home/$username/linux_installer/cache_rpm
  	cd /home/$username/linux_installer
  	yumdownloader p11-kit-0.20.7-3.res7.i686.rpm
  	rpm -ivh p11-kit-0.20.7-3.res7.i686.rpm --replacefiles
  	yum install audit-libs.i686 cracklib.i686 libdb.i686 libselinux.i686 libsepol.i686 pcre.i686 -y
  	yumdownloader pam-1.1.8-18.res7.i686.rpm
  	rpm -ivh pam-1.1.8-18.res7.i686.rpm --replacefiles
  	yumdownloader pango-1.36.8-2.res7.i686
  	rpm -ivh pango-1.36.8-2.res7.i686.rpm --replacefiles
  	yumdownloader nss-3.28.4-11.res7c.i686
  	yumdownloader nss-pem-1.0.3-4.res7.i686.rpm
  	rpm -ivh nss-3.28.4-11.res7c.i686.rpm nss-pem-1.0.3-4.res7.i686.rpm --replacefiles
  	yum install gcc.i686 libffi.i686 glib2.i686 libthai.i686 cairo.i686 libXft.i686 harfbuzz.i686 nspr.i686 nss-util.i686 nss-softokn.i686 cabextract -y
  	yum install wine.i686 -y
  	rm -rf *.rpm
fi

if [[ $distr = 'Centos8' ]];
then
  	echo 'Установка wine, конфигурация Centos8' >> /home/$username/linux_installer/install_log.log
  	yum update && yum upgrade -y
  	dnf groupinstall 'Development Tools' -y
  	dnf -y install epel-release
  	yum -y install libxslt-devel libpng-devel libX11-devel zlib-devel dbus-devel libtiff-devel freetype-devel libjpeg-turbo-devel  fontconfig-devel gnutls-devel gstreamer1-devel libxcb-devel  libxml2-devel libgcrypt-devel libXcursor-devel libXi-devel libXrandr-devel libXfixes-devel libXinerama-devel libXcomposite-devel libpcap-devel libv4l-devel libgphoto2-devel libusb-devel gstreamer1-devel libgudev SDL2-devel mesa-libOSMesa-devel gsm-devel libudev-devel libvkd3d-devel
  	sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
  	cd /home/$username/linux_installer
  	mkdir /home/$username/linux_installer/cache_rpm
  	cd /home/$username/linux_installer
  	wget -P /etc/yum.repos.d/ ftp://ftp.stenstorp.net/wine32.repo
  	wget http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/SDL2-2.0.10-2.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/glibc-2.28-151.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/libgcc-8.4.1-1.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/libstdc++-8.4.1-1.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/spirv-tools-libs-2020.5-3.20201208.gitb27b1af.el8.i686.rpm
  	wget https://pkgs.dyn.su/el8/extras/x86_64/libvkd3d-shader-1.2-2.el8.i686.rpm
  	wget https://pkgs.dyn.su/el8/extras/x86_64/libvkd3d-1.2-2.el8.i686.rpm
  	rpm -ivh glibc-2.28-151.el8.i686.rpm SDL2-2.0.10-2.el8.i686.rpm libgcc-8.4.1-1.el8.i686.rpm libstdc++-8.4.1-1.el8.i686.rpm spirv-tools-libs-2020.5-3.20201208.gitb27b1af.el8.i686.rpm libvkd3d-shader-1.2-2.el8.i686.rpm
  	dnf install wine wine.i686 -y
  	yum install winetricks -y
  	rm -rf *.rpm
  	yum install libreoffice -y
fi
}

function Run_Crontab() {
    if [[ $distr = 'AstraLinux' ]];
    then
        sudo systemctl enable cron
        sudo systemctl start cron
    fi

    systemctl enable crond
    systemctl start crond
    echo 'Служба Crontab включена, автозапуск добавлен' >> /home/$username/linux_installer/install_log.log
}

function Host_for_oracle_client() {
    echo '127.0.0.1	'$HOSTNAME' localhost '> /etc/hosts
}

function Finalize(){
    echo "username=$username" > ./config.source
    echo "distr=$distr" >> ./config.source
    echo "source.config записан!" >> /home/$username/linux_installer/install_log.log
}

#Запуск функций
Get_Base_Info
Select_Distro
Select_Java_Version
Mount_ARM
Install_Java
Install_Wine
Run_Crontab
Host_for_oracle_client
Finalize
