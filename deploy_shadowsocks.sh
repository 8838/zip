#!/bin/bash

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo "此脚本需要root权限，请使用sudo或以root身份运行" 
   exit 1
fi

echo "==== 开始安装 ===="

# 启用BBR加速
echo "配置BBR加速..."
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
echo "BBR配置完成"

# 安装Docker
echo "安装Docker..."
curl -fsSL get.docker.com | bash
echo "Docker安装完成"

# 启动并设置Docker自启动
echo "启动Docker并设置自启动..."
systemctl start docker
systemctl enable docker
echo "Docker服务已启动"

# 拉取Shadowsocks镜像
echo "拉取Shadowsocks镜像..."
docker pull teddysun/shadowsocks-libev:3.3.5
echo "镜像拉取完成"

# 创建配置目录和文件
echo "创建Shadowsocks配置..."
mkdir -p /etc/shadowsocks-libev

cat > /etc/shadowsocks-libev/config.json <<EOF
{
    "server":["[::0]", "0.0.0.0"],
    "server_port":9001,
    "password":"8838.github.io",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false,
    "nameserver":"1.1.1.1",
    "mode":"tcp_and_udp"
}
EOF
echo "配置文件已创建"

# 运行Shadowsocks容器
echo "启动Shadowsocks容器..."
docker run -d -p 9001:9001 -p 9001:9001/udp --name ss-libev --restart=always -v /etc/shadowsocks-libev:/etc/shadowsocks-libev teddysun/shadowsocks-libev:3.3.5

# 检查容器是否正常运行
if [ "$(docker ps -q -f name=ss-libev)" ]; then
    echo "==== 安装完成 ===="
    echo "Shadowsocks服务已成功启动"
    echo "服务器IP: $(curl -s https://ipinfo.io/ip)"
    echo "端口: 9001"
    echo "密码: 8838.github.io"
    echo "加密方式: aes-256-gcm"
else
    echo "==== 安装失败 ===="
    echo "Shadowsocks容器未能正常启动，请检查日志"
    docker logs ss-libev
fi