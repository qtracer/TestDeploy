<h3 align="center"><p style="color: green;font-weight: bold; font-size: 68px;">测试DevOps工具</p></h3>
<p align="center">
  <a href="https://github.com/qtracer/TestDeploy/releases"><img src="https://img.shields.io/github/v/release/qtracer/TestDeploy" alt="GitHub release"></a>
  <a href="https://www.linux.org/"><img src="https://img.shields.io/badge/Language-Bash | Python3-blue.svg"></a>
  <a href="https://github.com/qtracer/TestDeploy"><img src="https://img.shields.io/badge/System-Centos 7 | Ubuntu 18/20-red.svg"></a>
  <a href="https://github.com/qtracer/TestDeploy"><img src="https://img.shields.io/badge/Privileges-root | sudo-green.svg"></a>
  <a href="https://blog.csdn.net/qq_24601279/article/details/122942046"><img src="https://img.shields.io/badge/Desc-CSDN-green.svg"></a>
  
<!--   <a href="https://github.com/qtracer/TestDeploy"><img src="https://img.shields.io/github/stars/qtracer/TestDeploy?color=%23D0A20D&style=flat-square" alt="Stars"></a>
  <a href="https://github.com/qtracer/TestDeploy"><img src="https://img.shields.io/github/forks/qtracer/TestDeploy?color=%230ACB84&style=flat-square" alt="Forks"></a> -->
</p>
<hr />

### 推荐用最新版本

# 1.定位
TestDeploy是一套符合DevOps实践的测试解决方案，涵盖接口测试、性能测试等测试类型，能够有效管理测试集群，快速提供测试标准化环境，促进测试流程高效与稳定。

# 2.核心特性
* 结合Docker容器技术，环境一键部署，用例一键执行
* 集成Httprunner2.X/Locust2.X等工具特性
* 提供了与CI/CD流水线的统一集成机制
* 性能测试最大化测试执行机器的资源利用率
* 通过参数输入切换不同环境和执行特定用例
  
# 3.整体设计
![效果](https://github.com/qtracer/TestDeploy/blob/main/data/%E8%BF%90%E7%BB%B4%E5%B9%B3%E5%8F%B0%E6%9E%B6%E6%9E%84%E5%9B%BE00.png)

# 4.快速开始
* main-cli.sh放置在项目根目录下，假设为**PRJ_ROOT_DIR**
* 配置 $PRJ_ROOT_DIR/ini/hosts.ini（不配置默认单机）
* 通过环境部署和任务构建统一入口执行初始化
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh
```

## 环境部署和任务构建统一入口
> bash $PRJ_ROOT_DIR/main-cli.sh **$JOB_NAME** **$BUILD_NUMBER** **$WORKERNUM** $arg1 $arg2

### 自动化测试任务
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh $JOB_NAME $BUILD_NUMBER 0 $HOST $APPOINTEDCASES
# JOB_NAME: 项目名，Jenkins环境变量，直接引用
# BUILD_NUMBER: 构建号，Jenkins环境变量，直接引用。项目的tag标签也可以，仅做标识用
# HOST: 任务执行环境
# APPOINTEDCASES: 指定用例，非必选，默认testsuites/
```

### 性能测试任务
```Bash 
bash $PRJ_ROOT_DIR/main-cli.sh $JOB_NAME $BUILD_NUMBER $WORKERNUM $HOST $APPOINTEDCASES
# WORKERNUM：Locust worker进程数,默认1 worker对应1 CPU core，依此动态计算需要多少主机节点的支持。另，1 worker约可支持1000虚拟用户
# HOST: 任务执行环境
# APPOINTEDCASES: 非必选，对应Locust的@tag属性
```
```
# tips:
if [ $WORKERNUM -ge 1 ];then
  "performance test"
else
  "interface automation test"
fi
```

# 5.重要配置文件说明
## hosts.ini测试集群配置
配置**$PRJ_ROOT_DIR/ini/hosts.ini**，格式：$host,$account,$password,$constant,$MasterOrSlave

* $host：节点的IP地址
* $account：节点主机的账号(支持root账号和sudo免密提权账号)
* $password：节点主机的密码
* $constant：参数值为“isnew”或者“notnew”，如果是新主机且需要做初始化，则必须是“isnew”，初始化后会变为“notnew”
* $MasterOrSlave：参数值为“master”或者“slave”，指明是master还是slave节点。

在首次初始化前配置（不配置默认单机），后续每新增节点均需要重新执行一次初始化
```Bash
bash $PRJ_ROOT_DIR/main-cli.sh
```
#tips：Locust分布式性能测试按照hosts.ini的节点顺序分配资源，故自动化测试代理节点建议放最后。

## config.ini部分参数说明
* installedEnv：是否安装了基础环境。注：若因网络问题环境安装失败，需要手动重置为false并执行初始化
* remaincores：执行性能测试时，每个从机预留的cores数量，避免打满，默认预留1个
* hrun_main：接口自动化统一执行入口，默认main-hrun.py
* hrun_path: 接口自动化执行的指定路径，默认testsuites/
* locust_main: locust压测统一执行入口，默认locustfile.py
* locust_project_setEnv: locust执行前切换压测环境和数据源的文件(务必放置在压测项目根目录下)，默认project_setEnv.py。若不存在,则按照默认执行

# 6.Jenkins Pipeline
**Jenkins Pipeline不走main-cli.sh统一入口**，部署文件分三部分：
* build：views/pipelineBuild.sh
* runAPI：views/pipelineRunAPIAuto.sh
* getReport：views/pipelineHrunReport.sh

# 7.NGINX转发请求执行shell[已停止维护]
> Jenkins配置：curl -H "dirpath:$PWD" -H "shellpath:${shellpath}" ${host}:81/api/run?name=${JOB_NAME}%20${WORKERNUM}%200
* PWD为shell系统变量，表示自动化项目代码包路径；参数host对应Nginx主机ip address，参数shellpath对应路径+TestDeploy，参数BRANCH对应自动化测试项目代码分支。
* 该方式已支持，但不推荐使用，默认为关闭状态。若需要使用，则在views/buildEnvDepend.sh 取消注释，开启。
