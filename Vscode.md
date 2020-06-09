# Vscode

## ssh配置
* 安装remote development
* 点插件ssh targets，点设置，编辑,ssh/config
```
Host lun_mi_linux
    HostName 10.221.130.42
    User wl
    IdentityFile "C:\Users\Lun\.ssh\id_rsa"
```
* ctrl,打开设置，打开extensions，点击remote-SSH，点edit json中加入如下配置：
```
"remote.SSH.remotePlatform":{
"lun_mi_linux": "linux",
}
```
* 现在就可以用密码登录了，如果报错，系统变量需要把OPENSSH删掉，加入git\usr\bin
* 免密码配置：
	* 把本地的.ssh\id_rsa.pub内容加到linux的~/.ssh/authorized_keys中
	* 然后设定权限
		* chmod 700 ~/.ssh/
		* chmode 600 ~/.ssh/authorized_keys

## 显示git历史插件：Git Graph