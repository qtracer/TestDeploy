# 工具特点
* 符合DevOps思想，持续集成持续交付
* 功能组件化，脚本可拓展性强，支持PipeLine
* 结合Docker容器技术，快速提供所需测试环境
* 使用节点代理、暴露端口，实现宿主机与容器之间的互动
* 日志监控关键节点
* 一键清除环境


# 环境部署统一入口
> bash ${ShellDir}/main-cli.sh $JOB_NAME $tag

其中，$JOB_NAME是项目名，tag是版本号。

另，若想实现PipeLine，则需要封装或直接调用views和func里面的Shell脚本。


