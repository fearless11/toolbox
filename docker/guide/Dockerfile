FROM baseImage

RUN command

# 四部分：基础镜像、维护者信息、镜像操作指令、容器启动指令

# # 命令组成，#开头注释
# FROM
# MAINTAINER
# RUN
# CMD
# ADD src dest  # src可是本地文件，URL，tar文件会自动解压
# COPY src dest # src是本地文件内容，目录不存在自动创建
# ENV
# EXPOSE
# USER
# WORKDIR  # 为RUN、CMD指定配置工作目录
# HEALTHCHECK  # 容器健康检测
# SHELL

# 减少镜像层数 ： 多个RUN合并为一条
# 及时删除临时文件或缓存文件
# 调整指令顺序
# 减少外部源干扰
