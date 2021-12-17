# 目标
快速提供测试标准化环境，
促进测试流程高效与稳定。

# 设计原则
* 追求高的ROI
* 快速提供测试所需环境，环境高效支持测试技术执行
* 省去可视化web平台相关技术的研发和维护
* 不重复造轮子，拥抱开源，充分利用已有的优秀轮子

# 整体架构设计
![效果](https://github.com/qtracer/TestDeploy/blob/main/data/%E8%BF%90%E7%BB%B4%E5%B9%B3%E5%8F%B0%E6%9E%B6%E6%9E%84%E5%9B%BE.png)

# 工具特点
* 符合DevOps思想，持续集成持续交付
* 纯Shell脚本，功能组件化，支持PipeLine
* 结合Docker容器技术，快速提供所需测试环境
* 集成Httprunner2/Locust1.4等工具特性
* 测试集群自动化启动多核，执行分布式压测
* 日志监控，快速定位和排查


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
需要手动配置**ini/host.ini**文件，格式：${host ip},${account},${password}

程序会根据$workerNum计算需要启动多少台主机。