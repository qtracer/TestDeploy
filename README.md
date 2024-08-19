<h3><p align="center",style="color: #FF0000;font-weight: bold; font-size: 68px;">标准化环境部署与测试持续集成工具</p></h3>
<p align="center">
  <a href="https://github.com/qtracer/TestDeploy/releases"><img src="https://img.shields.io/github/v/release/qtracer/TestDeploy" alt="GitHub release"></a>
  <a href="https://github.com/qtracer/TestDeploy"><img src="https://img.shields.io/github/stars/qtracer/TestDeploy?color=%231890FF&style=flat-square" alt="Stars"></a>
  <a href="https://github.com/qtracer/TestDeploy"><img src="https://img.shields.io/github/forks/qtracer/TestDeploy?color=%231890FF&style=flat-square" alt="Forks"></a>
</p>
<hr />

### 推荐用v2.0.0+版本（特别是最新版），因历史原因，旧版本运行不稳定

# 1.目标
快速提供测试标准化环境，
促进测试流程高效与稳定。

# 2.整体设计
![效果](https://github.com/qtracer/TestDeploy/blob/main/data/%E8%BF%90%E7%BB%B4%E5%B9%B3%E5%8F%B0%E6%9E%B6%E6%9E%84%E5%9B%BE00.png)

# 3.核心特性
* 结合Docker容器技术，环境一键部署，用例一键执行
* 集成Httprunner2.X/Locust2.X等工具特性
* 提供了与CI/CD流水线的统一集成机制
* 性能测试最大化测试执行机器的资源利用率
* 通过参数输入切换不同环境和执行特定用例

# 4.快速开始
* main-cli.sh放置在项目根目录下，假设为**PRJ_ROOT_DIR**
* 配置 $PRJ_ROOT_DIR/ini/hosts.ini（不配置默认单机）
* 通过环境部署和任务构建统一入口执行初始化，默认搭建CI平台Jenkins
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh #Bash
```

## 环境部署和任务构建统一入口
> bash $PRJ_ROOT_DIR/main-cli.sh **$JOB_NAME** **$BUILD_NUMBER** **$WORKERNUM** $arg1 $arg2

### 自动化测试任务
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh $JOB_NAME $BUILD_NUMBER 0 $HOST $APPOINTEDCASES #Bash
# JOB_NAME: 项目名，Jenkins环境变量，直接引用
# BUILD_NUMBER: 构建号，Jenkins环境变量，直接引用
# HOST: 任务执行环境
# APPOINTEDCASES: 指定用例，非必填，默认/testcases
```

### 性能测试任务
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh $JOB_NAME $BUILD_NUMBER $WORKERNUM $APPOINTEDCASES #Bash
# APPOINTEDCASES: 非必选，对应locust的tag
```

#### tips:
if [ $WORKERNUM -ge 1 ];then
  "performance test"
else
  "interface automation test"
fi
```

# 5.重要配置文件说明
## 5.1.测试集群配置hosts.ini
配置**$PRJ_ROOT_DIR/ini/hosts.ini**，格式：$host,$account,$password,$constant,$MasterOrSlave

* $host：slave节点的IP地址
* $account：slave节点主机的账号
* $password：slave节点主机的密码
* $constant：参数值为“isnew”或者“notnew”，如果是新主机且需要做初始化，则必须是“isnew”，初始化后会变为“notnew”
* $MasterOrSlave：参数值为“master”或者“slave”，指明是master还是slave节点。

在首次初始化前配置，后续新增slave需要重新执行一次初始化
```Bash
bash $PRJ_ROOT_DIR/main-cli.sh
```

## 5.2.config.ini部分参数说明
* installedEnv：是否安装了基础环境。注：若因网络问题环境安装失败，需要手动重置为false并执行初始化。
* installedCI：是否安装了CI平台Jenkins。不建议手动修改。
* remaincores：执行性能测试时，每个从机预留的cores数量，避免打满，默认预留1个。
* hrun_main：接口自动化执行入口，默认为main-hrun.py，支持修改，与代码执行入口对应。

# 6.Jenkins Pipeline
**Jenkins Pipeline不走main-cli.sh统一入口**，部署文件分三部分：
* build：views/pipelineBuild.sh
* runAPI：views/pipelineRunAPIAuto.sh
* getReport：views/pipelineHrunReport.sh

# 7.代码文档组织结构
* HttpRunner2.X参考：https://github.com/qtracer/HttpRunner_demo
* Locust2.X参考：https://docs.locust.io/en/stable/

# 8.Jenkins建议插件
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

# 9.NGINX转发请求执行shell
> Jenkins配置：curl -H "dirpath:$PWD" -H "shellpath:${shellpath}" ${host}:81/api/run?name=${JOB_NAME}%20${BRANCH}%200
* PWD为shell系统变量，表示自动化项目代码包路径；参数host对应Nginx主机ip address，参数shellpath对应路径+TestDeploy，参数BRANCH对应自动化测试项目代码分支。
* 该方式已支持，但不推荐使用，默认为关闭状态。若需要使用，则在views/buildEnvDepend.sh 取消注释，开启。
