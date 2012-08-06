# Implement own https://github.com/fiorix/freegeoip service
#xroxy_parser.rb simply the ip paser in one method

# Everytime an IP is used or check and fails, add a time flag, if down since more than 24h, delete it.
# module to import proxy list file for a one shot import
# http://www.samair.ru/proxy/
# http://tinnhanh.ipvnn.com/free-proxy/China_Proxy_List.ipvnn
# http://fastproxy1.com/China-(Guangzhou)/lists.html

# http://proxy.ipcn.org/proxylist.html
# http://www.free-proxy-list.info/free-proxy-list/China-proxy.php
#
# http://www.binary-zone.com/files/MyProxyList.txt
# http://www.perdoch.info/doc/proxy.txt
# http://web.unideb.hu/~aurel192/proxylist.txt GOod
# http://210.213.141.142/KG7/PF-C/lists/country/out.txt
# http://www.planetnana.co.il/adirbuskila//vips.txt
# http://www.planetnana.co.il/nb1991/programs/proxys/proxyy.txt
#https://www.googleapis.com/customsearch/v1?key=AIzaSyBuw-b_C280KxRj1STeMGvMnjs3qPb-yOo&cref&fileType=txt&q=+”:8080"+”:80"+"china"&alt=json
#https://www.googleapis.com/customsearch/v1?key=AIzaSyBuw-b_C280KxRj1STeMGvMnjs3qPb-yOo&cref&fileType=txt&q=':8080'+%2B+'%3A80'+%2B+china+%2B+proxy+filetype%3Atxt&oq=':8080'+%2B+'%3A80'+%2B+china+%2B+proxy+filetype%3Atxt
#9b913fdfdc39d20095af789b587f6156068987096033b59a758adb2f8a5663dd

# http://proxy-ip-list.com/China/online-anonymous-proxy-China.html OLD
# http://www.speed-tester.info/p_proxylist.php OLD
# http://www.proxy360.cn/default.aspx BAD list
