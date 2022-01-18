# 演示demo
http://42.192.227.196:8080/
账号：gaohuajun
密码：gaohuajun

备注：整套流程尚未实现完全的自动化，如jenkins初次启动和配置、定时清理任务的配置等，仍需手动操作。

# 目标
快速提供测试标准化环境，
促进测试流程高效与稳定。

# 设计原则
* 追求高的ROI
* 快速提供测试所需环境，环境高效支持测试技术执行
* 省去可视化web平台相关技术的研发和维护
* 不重复造轮子，拥抱开源，充分利用已有的优秀轮子

# 整体架构设计
![效果](https://github.com/qtracer/TestDeploy/blob/main/data/%E8%BF%90%E7%BB%B4%E5%B9%B3%E5%8F%B0%E6%9E%B6%E6%9E%84%E5%9B%BE00.png)

# 工具特点
* 符合DevOps思想，持续集成持续交付
* 以Shell脚本为主，功能组件化，支持PipeLine
* 结合Docker容器技术，快速提供所需测试环境
* 集成Httprunner2/Locust1.4等工具特性
* 支持Locust Master-Slave架构，执行分布式压测
* 支持Jenkins Master-Slave架构，自动化测试支持在不同机器上跑


# 环境部署和执行统一入口
> bash ${ShellDir}/main-cli.sh **$JOB_NAME** **$tag** **$workerNum** $appointedCase

其中，必选参数：
* $JOB_NAME ：项目名 
* $tag : 版本号
* $workerNum : 启动核数，Interger
```
# tips:
if [ $workerNum -ge 1 ];then
  echo "performance test"
else
  echo "api test"
fi
```

可选参数：
* $appointedCase ： 指定路径或用例

另，若想实现PipeLine，则需要封装或直接调用views和func里面的Shell脚本。


# 测试集群自动化启动
需要手动配置**ini/host.ini**文件，格式：${host ip},${account},${password},${constant}

其中，${constant}为“isnew”或者“notnew”，如果是新主机且需要做初始化，则必须是“isnew”，初始化后会变为“notnew”。

host.ini为Jenkins Master-Slave以及Locust Master-Slave模式管理下slave的文件，在首次初始化时配置，后续配置需要通过**统一执行入口**重新执行一次slave的初始化。

性能压测时，程序会根据$workerNum计算需要启动多少台主机，无需手动填写。


# NGINX转发请求执行shell
> Jenkins配置：curl -H "dirpath:$PWD" -H "shellpath:${shellpath}" ${host}:81/api/run?name=${JOB_NAME}%20${BRANCH}%200
* PWD不需要改，表示自动化项目代码包路径；参数host对应Nginx主机ip，参数shellpath对应路径+TestDeploy，BRANCH对应自动化测试项目代码分支。
* 该方式已支持，但不推荐使用，默认为关闭状态。若需要使用，则在views/buildEnvDepend.sh 取消注释，开启。

# store.ini部分参数说明
* installedEnv：是否安装了基础环境。不建议手动修改。
* installedCI：是否安装了CI平台Jenkins。不建议手动修改。
* remaincores：执行性能测试时，每个从机预留的cores数量，避免打满，默认预留2个。支持修改。
* hrun_path：接口自动化默认执行的指定路径，默认为testcases/，支持修改，也可在统一执行入口指定。
