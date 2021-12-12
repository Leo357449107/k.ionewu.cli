# k.ionewu.cli
大鹏加速Openwrt脚本  
依赖:  
        jshn curl ca-certificates或者ca-bundle  
使用:  
		命令行
　　        sh k.ionewu.cli.sh "UID" "OPENID"  
　　
		mwan3通知
			/etc/mwan3.user sh k.ionewu.cli.sh "UID" "OPENID" $ACTION $DEVICE

说明:  
  
	：脚本会依次按照NETLISTDFT的顺序检查接口能不能连上IPV4URL，然后使用找到的第一个接口进行处理。
		如果没有找到将使用系统默认路由。

	：UID，OPENID请在网页端扫码登陆后抓包获得。  

：可以添加到mwan3通知里响应接口上线，使用mwan3提供接口连接，只响应跟踪成功(connected)。

	：我只测过四川电信  

	：理论上只支持Openwrt  

	：我在openwrt的vi里面写的，写的丑，不爱请Alt+F4  

TODO:  
	过几天写成Package（我觉得我不会做的）。  
