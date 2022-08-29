#!/usr/bin/env bash

###############################################################################
# Variables                                                                   #
###############################################################################

username='username'
distr=''

#InstantClient работает с АРМами после обновления от 28.05.20
#PosgreSQLODBC работает с АРМами после обновления от 23.08.21
oracle_version='12' #Приоритет использования версий: 12, InstantClient, 11.
postgre_sql=''		#При использовании указать версию 13.

#Ссылка на Oracle Client 11, можно указать на локальный каталог(Опционально)
url_oracle_client_11='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/XP_WIN2003_client_32bit/oracle_client_x32.tar'

#Ссылка на Oracle Client 12, можно указать на локальный каталог(Опционально)
url_oracle_client_12='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/win32_12201_client.tar'

#Ссылка на Instant Client, можно указать на локальный каталог(Опционально) 
url_instant_client='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/instant_client19.tar'

#Ссылка на PosgreSQLODBC, можно указать на локальный каталог(Опционально) 
url_postgre_sql='https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_13_01_0000-x86.zip'


###############################################################################
# Functions                                                                   #
###############################################################################

function Get_Info(){
	
	source ./config.source
	
	echo "Допустимые версии Oracle Client:"
	echo "1. Oracle Client 12"
	echo "2. Oracle InstantClient"
	echo "3. Oracle Client 11"

	while [[ $oracle_version = "" ]]
    do
        read -r -p "Введите порядковый номер необходимой версии: " response
        if [[ $response -eq 1 ]];
        then
            oracle_version='12'
        elif [[ $response -eq 2 ]];
        then
            oracle_version='InstantClient'
        elif [[ $response -eq 3 ]];
        then
			oracle_version='11'
		else
			echo "Некорректный ввод."
		fi
	done

    read -r -p "Будет ли использоваться PostgreSQL? [д/Н] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[дД]|[дД][аА])$ ]]
	then
		postgre_sql='13'
	fi
 

}

function Install_Winetricks() {

if [ -d /home/$username/.wine ]; 
then

	winetricks ie8
	winetricks vb6run
	winetricks mdac28
	winetricks vcrun6
	winetricks vcrun2010
	winetricks vcrun2005
	
else 

	if [[ $distr = 'AstraLinux' || $distr = 'Ubuntu' ]]; 
	then 
		WINEARCH=win32 winecfg 
	fi
	
	if [ $distr = 'Centos8' ]; 
	then
		WINEARCH=win32 WINEPREFIX=~/.wine wine wineboot
	fi

	if [ $distr = 'RosaLinux' ]; 
	then 
		cd /home/$username
		wget http://www.kegel.com/wine/winetricks
		chmod a+x winetricks
	fi

	winecfg
	winetricks ie8
	winetricks vb6run
	winetricks mdac28
	winetricks vcrun6
	winetricks vcrun2010
	winetricks vcrun2005

	if [ $distr = 'Centos8' ];
	then
		wine ~/.cache/winetricks/vcrun2010/vcredist_x86.exe
		wine ~/.cache/winetricks/vcrun2005/vcredist_x86.exe
	fi

	if [ $distr = 'AltLinux8' || $distr = 'AltLinux9' ];
	then
		cd ~/.cache/winetricks/vcrun2005
		wine vcredist_x86.EXE
		cd ~/.cache/winetricks/vcrun2010
		wine vcredist_x86.EXE
	fi

fi


if [[ $distr = 'Ubuntu' || $distr = 'Centos8' ]]; 
then 
	winetricks ie8
fi

if [ $distr = 'AstraLinux' ]; 
then

	cd /home/$username/linux_installer
	
	if [ -f wine_gecko-2.47-x86.msi ]; 
	then 
		echo 'wine_gecko-2.47-x86.msi уже скачан' >> /home/$username/linux_installer/install_log.log
	else 
		echo 'Загрузка wine_gecko-2.47-x86.msi' >> /home/$username/linux_installer/install_log.log
		wget http://dl.winehq.org/wine/wine-gecko/2.47/wine_gecko-2.47-x86.msi 
	fi
	
	wine msiexec /i wine_gecko-2.47-x86.msi

	if [ -f wine_gecko-2.47-x86_64.msi ]; 
	then 
		echo 'wine_gecko-2.47-x86.msi уже скачан' >> /home/$username/linux_installer/install_log.log
	else 
		echo 'Загрузка wine_gecko-2.47-x86.msi' >> /home/$username/linux_installer/install_log.log
		wget http://dl.winehq.org/wine/wine-gecko/2.47/wine_gecko-2.47-x86_64.msi
	fi

	wine msiexec /i wine_gecko-2.47-x86_64.msi

fi
}

function Install_Oracle_12() {

cd /home/$username/linux_installer

if [ $oracle_version = '12' ]; 
then

	if [ -f win32_12201_client.tar ]; 
	then 
		echo 'Дистрибутив OracleClient уже скачан' >> /home/$username/linux_installer/install_log.log
	else 
		echo 'Дистрибутива OracleClient нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива OracleClient' >> /home/$username/linux_installer/install_log.log
		wget $url_oracle_client_12
		mkdir /home/$username/.wine/drive_c/distrib
		cp /home/$username/linux_installer/win32_12201_client.tar /home/$username/.wine/drive_c/distrib/win32_12201_client.tar	
	fi

	if [ -d /home/$username/.wine/drive_c/distrib/client32 ]; 
	then 
		cd /home/$username/.wine/drive_c/distrib/client32
	else
		cd /home/$username/.wine/drive_c/distrib
		echo'Распаковка win32_12201_client.tar' >> /home/$username/linux_installer/install_log.log
		tar -xvf win32_12201_client.tar
		cd /home/$username/.wine/drive_c/distrib/client32
	fi

	if [ -f setup.exe ]; 
	then 
		echo 'Установка OracleClient' >> /home/$username/linux_installer/install_log.log
		wine setup.exe -ignorePrereq -J"-Doracle.install.client.validate.clientSupportedOSCheck=false"
	else
		echo 'ERR: Setup.exe не найден' >> /home/$username/linux_installer/install_log.log
	fi

fi

}

function Install_Oracle_11() {

cd /home/$username/linux_installer

if [ $oracle_version = '11' ]; 
then

	if [ -f oracle_client_x32.tar ]; 
	then 
		echo 'Дистрибутив OracleClient уже скачан' >> /home/$username/linux_installer/install_log.log
	else 
		echo 'Дистрибутива OracleClient нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива OracleClient' >> /home/$username/linux_installer/install_log.log
		wget $url_oracle_client_11
		mkdir /home/$username/.wine/drive_c/distrib
		cp /home/$username/linux_installer/oracle_client_x32.tar /home/$username/.wine/drive_c/distrib/oracle_client_x32.tar
	fi

	if [ -d /home/$username/.wine/drive_c/distrib/client32 ]; 
	then 
		cd /home/$username/.wine/drive_c/distrib/client32
	else
		echo'Распаковка oracle_client_x32.tar' >> /home/$username/linux_installer/install_log.log
		tar -xvf oracle_client_x32.tar
		cd /home/$username/.wine/drive_c/distrib/client
	fi

	if [ -f setup.exe ]; 
	then 
		echo 'Установка OracleClient' >> /home/$username/linux_installer/install_log.log
		wine setup.exe
	else
		echo 'ERR: Setup.exe не найден' >> /home/$username/linux_installer/install_log.log
	fi

fi

}

function Install_Oracle_Instant() {

	cd /home/$username/linux_installer

if [ $oracle_version = 'InstantClient' ]; 
then

	if [ -d /home/$username/.wine/drive_c/oracle ]; 
	then
		echo 'Каталог /home/$username/.wine/drive_c/oracle уже создан' >> /home/$username/linux_installer/install_log.log
	else
		mkdir /home/$username/.wine/drive_c/oracle
	fi

	if [ -f instant_client19 ]; 
	then 
		echo 'Дистрибутив oracle_instantclient19 уже скачан' >> /home/$username/linux_installer/install_log.log
	else 
		echo 'Дистрибутива oracle_instantclient19 нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива oracle_instantclient19' >> /home/$username/linux_installer/install_log.log
		wget $url_instant_client
	fi

	if [ -d /home/$username/linux_installer/instant_client ]; 
	then 
		echo 'Копирование instant_client в /home/'$username'/.wine/drive_c/oracle' >> /home/$username/linux_installer/install_log.log
		cp -a -u -f /home/$username/linux_installer/instant_client/. /home/$username/.wine/drive_c/oracle
	else
		echo 'Распаковка oracle_instantclient19.tar' >> /home/$username/linux_installer/install_log.log
		tar -xvf instant_client19.tar
		echo 'Копирование instant_client в /home/'$username'/.wine/drive_c/oracle' >> /home/$username/linux_installer/install_log.log
		cp -a -u -f /home/$username/linux_installer/instant_client/. /home/$username/.wine/drive_c/oracle
	fi

fi

}

function Install_Postgre_Sql() {

	cd /home/$username/linux_installer

if [ $postgre_sql = '13' ]; 
then

	if [ -f psqlodbc_13_01_0000-x86.zip ]; 
	then 
		echo 'Дистрибутив PostgreSQL Client уже скачан' >> /home/$username/linux_installer/install_log.log
	else 
		echo 'Дистрибутива PostgreSQL Client нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива PostgreSQL Client' >> /home/$username/linux_installer/install_log.log
		wget $url_postgre_sql
		mkdir /home/$username/.wine/drive_c/distrib
		cp /home/$username/linux_installer/psqlodbc_13_01_0000-x86.zip /home/$username/.wine/drive_c/distrib/psqlodbc_13_01_0000-x86.zip
	fi

	if [ -d /home/$username/.wine/drive_c/distrib ]; 
	then 
		cd /home/$username/.wine/drive_c/distrib
	else
		cd /home/$username/.wine/drive_c/distrib
		echo'Распаковка psqlodbc_13_01_0000-x86.zip' >> /home/$username/linux_installer/install_log.log
		unzip psqlodbc_13_01_0000-x86.zip
	fi

	if [ -f psqlodbc_x86.msi ]; 
	then 
		echo 'Установка PostgreSQL Client' >> /home/$username/linux_installer/install_log.log
		wine start psqlodbc_x86.msi
	else
		echo 'ERR: psqlodbc_x86.msi не найден' >> /home/$username/linux_installer/install_log.log
	fi

fi

}

#Запуск функций
Get_Info
Install_Winetricks
Install_Oracle_12
Install_Oracle_11
Install_Oracle_Instant
Install_Postgre_Sql