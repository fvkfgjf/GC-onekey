#!/bin/bash

function command_1(){
    echo "开始一键一键安装原神及环境！"
	echo "安装运行环境!"
	if type java >/dev/null 2>&1; 
	then
		echo "java 已安装，跳过"
	else
		
		# 在 /usr/local 目录下安装jdk
		cd /usr/local
		wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz
		tar -zxvf jdk-17_linux-x64_bin.tar.gz 
		# 将jdk-17改名为java
		mv jdk-17.0.5 java
		echo "export JAVA_HOME=/usr/local/java" >> /etc/profile
		echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
		echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> /etc/profile
		source /etc/profile
		echo "java 安装完毕"
	fi
	#安装mingodb
	cd /opt
	wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-6.0.3.tgz
	tar -zxvf mongodb-linux-x86_64-rhel70-6.0.3.tgz
	rm -f mongodb-linux-x86_64-rhel70-6.0.3.tgz
	mv mongodb-linux-x86_64-rhel70-6.0.3 mongodb
	mkdir -p ./mongodb/data ./mongodb/log ./mongodb/conf
	chmod -R 777 /opt/mongodb
	echo "mongodb 安装完毕"
	yum -y install -y screen
	echo "screen 安装完毕"
	yum -y install -y git
	echo "git 安装完毕"
	cd ~
	if [ -d "Grasscutter" ]; then
		rm -rf Grasscutter
	fi
	git clone https://ghproxy.com/https://github.com/Grasscutters/Grasscutter.git
	cd Grasscutter
	chmod +x gradlew
	./gradlew jar # Compile
	git clone https://gitlab.com/YuukiPS/GC-Resources.git
	cd GC-Resources
	mv Resources resources
	mv resources /root/Grasscutter
	chmod -R 777 /root/Grasscutter
	echo "服务端准备完毕！开始启动服务端！"
	command_2
}


function command_2(){
    echo "服务端启动中!"
	chmod -R 777 /root/Grasscutter
	cd /opt/mongodb/
	bin/mongod --port=27017 --dbpath=/opt/mongodb/data --logpath=/opt/mongodb/log/mongodb.log --fork
	cd /root/Grasscutter
	source /etc/profile
	screen_name="Grasscutter" 
	screen -dmS $screen_name
	cd /root/Grasscutter && java -jar *.jar
	sleep 5
	my_ip=`curl -s https://ipv4.ipw.cn/api/ip/myip`
	grep -q "127.0.0.1" /root/Grasscutter/config.json && sed -i 's#127.0.0.1#'$my_ip'#g' /root/Grasscutter/config.json || echo ""
	grep -q ""$my_ip"" /root/Grasscutter/config.json && echo "config.json文件中IP已修改为"$my_ip",若此处IP不对，请自行前往更改!" || echo ""
	sed -i 's/"language": "en_US"/"language": "zh_CN"/' /root/Grasscutter/config.json
	sed -i 's/"fallback": "en_US"/"fallback": "zh_CN"/' /root/Grasscutter/config.json
	sed -i 's/"document": "EN"/"document": "ZH"/' /root/Grasscutter/config.json
	sleep 5
	echo "ctrl+D切出"
	
	
}

function command_3(){
    echo "正在关闭服务端!"
	cd /opt/mongodb/
	bin/mongod --port=27017 --dbpath=/opt/mongodb/data --shutdown
	screen -ls|awk 'NR>=2&&NR<=5{print $1}'|awk '{print "screen -S "$1" -X quit"}'|sh
	echo "服务端已关闭!"
}

function command_4(){
    screen -r Grasscutter
}

function command_5(){
    command_3
	while true
	do
		if [ ! -e "/root/Grasscutter/config.json" ]; then
			echo "未找到配置文件，如已安装游戏，请尝试卸载重装！"
			break
		fi
		echo "*--------------------------------------------------------*"
		echo "                   自定义配置修改菜单                     "
		echo "*--------------------------------------------------------*"
		echo "1.  打开自动注册                                          "
		echo "2.  关闭自动注册                                          "
		echo "3.  打开注册自动给予权限                                  "
		echo "4.  关闭注册自动给予权限                                  "
		echo "5.  修改服务器名称                                        "
		echo "6.  修改进服左下角聊天框提示语                            "
		echo "7.  修改指令小助手名称                                    "
		echo "8.  修改指令小助手名称下方签名                            "
		echo "9.  修改进服邮件标题                                      "
		echo "10. 修改进服邮件内容（不是邮件附带的道具）                "
		echo "11. 修改进服邮件发送者名称                                "
		echo "                                                          "
		echo "0. 返回上一级菜单                                         "
		echo "                                                          "
		echo "*--------------------------------------------------------*"
		echo "**********************************************************"
		echo "请输入操作编号："
		read number
		case $number in
			"1")sed -i 's/"autoCreate":[^,]*/"autoCreate": true/' /root/Grasscutter/config.json
			echo "修改成功！"
			;;
			"2")sed -i 's/"autoCreate":[^,]*/"autoCreate": false/' /root/Grasscutter/config.json
			echo "修改成功！"
			;;
			"3")sed -i 's/"defaultPermissions":[^,]*/"defaultPermissions": [*]/' /root/Grasscutter/config.json
			echo "修改成功！"
			;;
			"4")sed -i 's/"defaultPermissions":[^,]*/"defaultPermissions": []/' /root/Grasscutter/config.json
			echo "修改成功！"
			;;
			"5")echo "请输入服务器名称："
				read sever_name
				sed -i 's/"defaultName":[^,]*/"defaultName": "'$sever_name'"/' /root/Grasscutter/config.json
				echo "修改成功！"
			;;
			"6")echo "请输入您想要设置的提示语："
				read huanying
				sed -i 's/"welcomeMessage":[^,]*/"welcomeMessage": "'$huanying'"/' /root/Grasscutter/config.json
				echo "修改成功！"
			;;
			"7")echo "请输入指令小助手名称："
				read nick_name
				sed -i 's/"nickName":[^,]*/"nickName": "'$nick_name'"/' /root/Grasscutter/config.json
				echo "修改成功！"
			;;
			"8")echo "请输入指令小助手名称下方签名："
				read nick_yu
				sed -i 's/"signature":[^,]*/"signature": "'$nick_yu'"/' /root/Grasscutter/config.json
				echo "修改成功！"
			;;
			"9")echo "请输入进服邮件标题："
				read mail_title
				sed -i 's/"title":[^,]*/"title": "'$mail_title'"/' /root/Grasscutter/config.json
				echo "修改成功！"
			;;
			"10")echo "请输入进服邮件内容："
				read mail_content
				sed -i 's/"content":.*$/"content": "'$mail_content'",/' /root/Grasscutter/config.json
				echo "修改成功！"
			;;
			"11")echo "请输入进服邮件发送者名称："
				read mail_sender
				sed -i 's/"sender":[^,]*/"sender": "'$mail_sender'"/' /root/Grasscutter/config.json
				echo "修改成功！"
			;;
			"0")echo "不要忘记启动游戏哦！"
				break
			;;
		esac
	done
}

function command_6(){
    command_3
	cd ~
	rm -rf Grasscutter/resources
	rm -rf Grasscutter/data
	rm -f Grasscutter/*.jar
	cd Grasscutter
	rm -f config.json
	git clone https://ghproxy.com/https://github.com/Grasscutters/Grasscutter.git
	cd Grasscutter
	chmod +x gradlew
	./gradlew jar # Compile
	git clone https://gitlab.com/YuukiPS/GC-Resources.git
	mv Resources resources
	chmod -R 777 /root/Grasscutter
	echo "服务端更新完成！自动启动服务端！"
	command_2
}

function command_0(){
    echo "退出菜单!"
}

function command_886(){
    echo "开始一键卸载环境及服务端"
	cd ~
	command_3
	rm -fr /root/Grasscutter
	rm -fr /opt/mongodb
	rm -fr /opt/jdk-17.0.4.1
	yum -y remove screen
	yum -y remove git
	sed -i '$d' /etc/profile
	sed -i '$d' /etc/profile
	sed -i '$d' /etc/profile
	source /etc/profile
	rm /root/onekey.sh
	echo "已完全卸载相关环境及文件并清理残留！"
}

while true
do
	cd ~
	if [ -d "/root/Grasscutter" ]; then
		cd Grasscutter
		Grasscutter_local=`ls -f *.jar`
		Grasscutter_local=${Grasscutter_local:12:5} 
		echo $Grasscutter_local
	fi
	if [ ! -d "/root/Grasscutter" ]; then
		Grasscutter_local='未安装'
	fi
	tag=`wget -qO- -t1 -T2 "https://api.github.com/repos/Grasscutters/Grasscutter/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'`
	Grasscutter_new=${tag:1:5}
	cd ~
	echo "*--------------------------------------------------------*"
	echo "               原神(Grasscutter)一键脚本                  "
	echo "                   coolchill && ioi                       "
	echo "                        已开源                            "
	echo "     开源地址：https://github.com/cool-chill/GC-onekey    "
	echo "*--------------------------------------------------------*"
	echo "1. 一键安装环境并部署最新服务端                           "
	echo "2. 启动服务端                                             "
	echo "3. 关闭服务端                                             "
	echo "                                                          "
	echo "4. 进入控制台(按住ctrl+A并按D切出，进入控制台请勿乱输)    "
	echo "                                                          "
	echo "5. 修改配置(自动注册,自动授权,服务器名称,提示语等信息)    "
	echo "  -修改配置默认会先关闭服务器，修改完毕后记得启动服务端   "
	echo "                                                          "
	echo "已安装服务端版本：$Grasscutter_local                          "
	echo "最新服务端版本：  $Grasscutter_new                            "
	echo "6. 更新服务端(不会删除玩家数据，config中配置会重置)       "
	echo "                                                          "
	echo "0. 退出菜单                                               "
	echo "                                                          "
	echo "886.一键卸载原神及环境                                    "
	echo "*--------------------------------------------------------*"
	echo "**********************************************************"
	echo "请输入操作编号："
	read number
	case $number in
		"1")command_1
		;;
		"2")command_2
		;;
		"3")command_3
		;;
		"4")command_4
		;;
		"5")command_5
		;;
		"6")command_6
		;;
		"0")command_0
			break
		;;
		"886")command_886
			break
		;;
	esac
done