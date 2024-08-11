# 推荐用v2.0.0及以上版本，因历史原因，旧版本运行不稳定

# 1.目标
快速提供测试标准化环境，
促进测试流程高效与稳定。

# 2.设计原则
* 高效的自动化和标准化
* 简单的技术栈，高可维护性
* 拥抱开源，充分利用已有的优秀轮子

# 3.整体架构设计
![效果](https://github.com/qtracer/TestDeploy/blob/main/data/%E8%BF%90%E7%BB%B4%E5%B9%B3%E5%8F%B0%E6%9E%B6%E6%9E%84%E5%9B%BE00.png)

# 4.核心特性
* 结合Docker容器技术，轻量高效
* 开箱即用，简化测试的执行过程，提供测试用例版本控制机制
* 集成Httprunner2.X/Locust1.4.X等工具特性
* 提供了与CI/CD流水线的统一集成机制
* 最大化测试执行机器的资源利用率
* 支持通过参数输入切换不同环境

# 5.如何快速开始
* main-cli.sh放置在项目根目录下，假设为**PRJ_ROOT_DIR**
* 配置 $PRJ_ROOT_DIR/ini/hosts.ini（不配置默认单机）
* CLI进入$PRJ_ROOT_DIR，通过环境部署和任务构建统一入口执行初始化
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh #Bash
```
首次初始化时会搭建CI平台Jenkins
* 配置Jenkins、创建节点
* Jenkins创建任务、配置任务
#### 自动化测试任务的重要配置
（1）选择“参数化构建过程”，git参数名称**BRANCH**，选项参数名称**appointedHost**
（2）若用到master-slave模式，同时要勾选“限制项目并发构建”
（3）“源码管理”，填写要拉取的代码仓库
（4）构建选择“执行Shell”，配置 
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh $JOB_NAME $BRANCH 0 $appointedHost #Bash
```
（5）其他配置略
#### 性能测试任务的重要配置
（1）选择“参数化构建过程”，git参数名称**BRANCH**
（2）“源码管理”，填写要拉取的代码仓库
（3）构建选择“执行Shell”，配置 
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh $JOB_NAME $BRANCH <正整数，如6> #Bash
```
（4）其他配置略

注意事项：镜像都是从Docker Hub等远程仓库下载的，最好用私库拉取镜像。


# 6.环境部署和任务构建统一入口
> bash $PRJ_ROOT_DIR/main-cli.sh **$JOB_NAME** **$BRANCH** **$workerNum** **$appointedHost** $appointedCase

其中，**任务构建时**，必选参数：
* $JOB_NAME ：项目名，Jenkins环境变量，直接引用
* $BRANCH : 代码分支，Jenkins的git参数，“参数化构建过程”中定义，这里引用
* $workerNum : 启动worker数量，自定义参数，类型为Interger，需手动填写一个参数值
* $appointedHost: Jenkins的选项参数，“参数化构建过程”中定义，这里引用。填写需要执行自动化测试的所有环境，与开发代码呼应。
```
# tips:
if [ $workerNum -ge 1 ];then
  "performance test"
else
  "interface automation test"
fi
```

可选参数：
* $appointedCase：指定路径或用例，自定义参数，路径填写 $PRJ_ROOT_DIR 的相对路径，如 testcases/create_user.yml


# 7.重要配置文件说明
## 7.1.测试集群配置hosts.ini
配置**$PRJ_ROOT_DIR/ini/hosts.ini**，格式：$host,$account,$password,$constant,$MasterOrSlave

* $host：slave节点的IP地址
* $account：slave节点主机的账号
* $password：slave节点主机的密码
* $constant：参数值为“isnew”或者“notnew”，如果是新主机且需要做初始化，则必须是“isnew”，初始化后会变为“notnew”
* $MasterOrSlave：参数值为“master”或者“slave”，指明是master还是slave节点。

hosts.ini为Jenkins Master-Slave以及Locust Master-Slave模式管理slave的文件，在首次初始化前配置，后续新增slave需要重新执行一次初始化
```Bash
bash $PRJ_ROOT_DIR/main-cli.sh
```

若只有单台测试机器，该配置文件无需做任何配置。

## 7.2.config.ini部分参数说明
* installedEnv：是否安装了基础环境。注：若因网络问题环境安装失败，需要手动重置为false并执行初始化。
* installedCI：是否安装了CI平台Jenkins。不建议手动修改。
* remaincores：执行性能测试时，每个从机预留的cores数量，避免打满，默认预留1个。
* hrun_path：接口自动化默认执行的指定路径，默认为testcases/，支持修改，也可在统一执行入口指定。
* hrun_main：接口自动化执行入口，默认为main-hrun.py，支持修改，与代码入口对应。

# 8.Jenkins Pipeline
**Jenkins Pipeline不走main-cli.sh统一入口**，部署文件分三部分：
* build：views/pipelineBuild.sh
* runAPI：views/pipelineRunAPIAuto.sh
* getReport：views/pipelineHrunReport.sh

# 9.代码文档组织结构
* HttpRunner2.X参考：https://github.com/qtracer/HttpRunner_demo
* Locust1.4.1参考：https://docs.locust.io/en/stable/

# 10.Jenkins建议插件
除了系统默认安装插件外，这里建议安装以下插件
* Node and Label parameter	
* Extended Choice Parameter
* Git Parameter
* Git
* Email Extension Plugin
* Role-based Authorization Strategy
* Pipeline Stage View
* Generic Webhook Trigger
* gitlab
* Pipeline
* SSH Agent Plugin
* SSH Build Agents plugin
* SSH Pipeline Steps

# 11.NGINX转发请求执行shell
> Jenkins配置：curl -H "dirpath:$PWD" -H "shellpath:${shellpath}" ${host}:81/api/run?name=${JOB_NAME}%20${BRANCH}%200
* PWD为shell系统变量，表示自动化项目代码包路径；参数host对应Nginx主机ip address，参数shellpath对应路径+TestDeploy，参数BRANCH对应自动化测试项目代码分支。
* 该方式已支持，但不推荐使用，默认为关闭状态。若需要使用，则在views/buildEnvDepend.sh 取消注释，开启。
