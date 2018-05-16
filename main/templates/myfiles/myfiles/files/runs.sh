sudo ps auxfS |grep Hello |awk {'print $2'} | xargs -i kill -9 {}
java -jar /tmp/HelloWorld*.jar
