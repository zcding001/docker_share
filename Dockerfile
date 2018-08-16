#
#多分支无等待测试环境部署
#
#author		:	zc.ding
#date		:	2018-08-16
#filename	:	Dockerfile
#
#
FROM phusion/baseimage:0.10.1




#enable sshd
#RUN rm -rf /etc/service/sshd/down 
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

COPY Shanghai /etc/localtime

# Clean up APT when done.
RUN echo 'Asia/Shanghai' >/etc/timezone && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /share/soft/jdk

# 暴露debug端口
# #invet
EXPOSE 5100
# #loan
EXPOSE 5101
# #payment
EXPOSE 5102
# #sencondary
EXPOSE 5103
# #user
EXPOSE 5104
# #tomat-debug
EXPOSE 5105
EXPOSE 5106

# Define default command.
CMD ["/sbin/my_init"]






