# tips:
# 减少镜像层数，多个RUN合并为一条
# 及时删除临时文件或缓存文件
# 调整指令顺序

# 基础镜像
FROM baseImage

# 为RUN、CMD指定配置工作目录
WORKDIR /the/workdir/path

# source可是本地文件，URL，tar文件会自动解压
ADD source dest

# source是本地文件内容，目录不存在自动创建
COPY source dest

# 运行命令 
RUN command

# 设置环境变量
ENV key=value

# 暴露端口
EXPOSE port

# 运行用户
USER daemon

# 健康检查
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "executable" ]

# 执行命令，可作为entrypoint参数
# 可覆盖，命令传递的cmd会覆盖，docker exec -it xxx cmd 
CMD [ "executable" ]

# 执行命令
ENTRYPOINT [ "executable" ]
