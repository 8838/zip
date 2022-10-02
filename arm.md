![PES75.png](https://pic.rmb.bdstatic.com/bjh/5d7aee6594ec58c9f41bacb2c75ba08f.jpeg)

<!-- wp:image {"align":"left","id":3857,"sizeSlug":"large"} -->
<figure class="wp-block-image alignleft size-large"><img src="https://www.moe.ms/drive/img/2022/07/ARM-logo-1024x383.jpg" alt="" class="wp-image-3857"/></figure>
<!-- /wp:image -->

<!-- wp:heading -->
<h2>前言</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>用甲骨文ARM机器建站大半年了，每日一备份还是很不错的，宝塔对arm的支持不是很好，默认的面板防火墙对arm机器有兼容性问题。之前一直没管它，只要没sb搞网站。今天监控通知我的网站下线了。查了一下是被cc攻击。4+24的配置都直接负载百分百。于是立刻查询相关资料着手解决这个问题。</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>宝塔面板的nginx 编译脚本直接忽略 ARM 对 LuaJIT 的支持，这导致了许多依赖 lua 语言的插件失效，例如 Nginx 防火墙、网站监控报表。</p>
<!-- /wp:paragraph -->

<!-- wp:heading -->
<h2>先决条件</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>需要debian11系统。debian10无法解决。甲骨文自带的ubuntu没测试过不清楚，甲骨文自带的系统太难用了，我每次都是dd系统。dd系统参考:<a href="https://www.moe.ms/2804.html">链接</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>如果你的系统是debian11，那可以直接解决，网站不受影响。暂时卸载nginx和防火墙插件，其他软件不动。然后再运行下面命令</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>cat&gt;/www/server/panel/install/nginx_prepare.sh&lt;&lt;EOL
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
 
wget -c -O LuaJIT-2.1.zip https://github.com/LuaJIT/LuaJIT/archive/refs/heads/v2.1.zip -T 10
unzip LuaJIT-2.1.zip
if &#91; -e LuaJIT-2.1 ]; then
    cd LuaJIT-2.1
    make linux
    make install
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.1/
    ln -sf /usr/local/lib/libluajit-5.1.so.2 /usr/local/lib64/libluajit-5.1.so.2
    if &#91; `grep -c /usr/local/lib /etc/ld.so.conf` -eq 0 ]; then
        echo "/usr/local/lib" &gt;&gt; /etc/ld.so.conf
    fi
    ldconfig
    cd ..
fi
rm -rf LuaJIT-2.1*
Install_cjson
EOL</code></pre>
<!-- /wp:code -->

<!-- wp:code -->
<pre class="wp-block-code"><code>sed -i 's/\r//g' /www/server/panel/install/nginx_prepare.sh</code></pre>
<!-- /wp:code -->

<!-- wp:code -->
<pre class="wp-block-code"><code>cat&gt;/www/server/panel/install/nginx_configure.pl&lt;&lt;EOL
--add-module=/www/server/nginx/src/ngx_devel_kit --add-module=/www/server/nginx/src/lua_nginx_module
EOL</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>安装lua5。</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>apt install lua5* -y</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>安装nginx，代码中的1.21代表nginx版本，经测试1.18版本也没有问题</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>cd /www/server/panel/install</code></pre>
<!-- /wp:code -->

<!-- wp:code -->
<pre class="wp-block-code"><code>bash install_soft.sh 0 install nginx 1.21</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>现在再去宝塔软件商店安装防火墙就没有问题了</p>
<!-- /wp:paragraph -->
