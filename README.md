# JobAgent

```text
   __        _       _                    _   
   \ \  ___ | |__   /_\   __ _  ___ _ __ | |_ 
    \ \/ _ \| '_ \ //_\\ / _` |/ _ \ '_ \| __|
 /\_/ / (_) | |_) /  _  \ (_| |  __/ | | | |_ 
 \___/ \___/|_.__/\_/ \_/\__, |\___|_| |_|\__|
                         |___/                
```
![LOGO](./docs/assets/logo/128.png)

[![Apache licensed][9]][10]
[![Docker][3]][4] 

[3]: https://img.shields.io/docker/image-size/aicrosoft/jobagent/latest
[4]: https://hub.docker.com/r/aicrosoft/jobagent
[9]: https://img.shields.io/badge/license-Apache-blue.svg
[10]: LICENSE

📖👉 [查看中文帮助文档](./docs/cn/README.md) 

[JobAgent](https://github.com/neatFactory/JobAgent) is a task scheduling client that is easy to use and expand, and accepts various job trigger types. It is implemented using the [JobsFactory](https://www.nuget.org/packages/Aicrosoft.Scheduling/) task scheduling framework. It is written in [dotnet8](https://dotnet.microsoft.com/en-us/). It is an upgrade and refactoring of my earlier open-source project [BeesTask](https://github.com/Aicrosoft/BeesTask) .

## Advantages
- Multiple trigger modes are supported: 
- - **Setup trigger** – runs when the system or component is upgraded.
- - **Interval trigger** – runs on a fixed time interval.
- - **Cron trigger** – runs based on a cron Expression.
- - **Event trigger** – runs when specific events occur.
- Simply inherit a few classes, set the properties, and override the necessary methods to implement your custom business logic.  
- The system is implemented as a plugin based on a .NET library, featuring a clean and well-structured design that’s easy to manage and use.

## Applicable Scenarios
- Periodically triggering a task to perform certain operations, such as processing large amounts of data;
- Triggering at specific times to perform operations that need to be executed at certain times, such as on the first day of each month;
- Triggering based on events to perform subsequent operations, such as automatic directory updates and transfers;

## Common Usage Examples
- DDNS updates can be executed periodically or triggered by IP update events from routers;
- Monitoring a directory and synchronizing its contents to other locations when changes occur;
- Monitoring events in the database and executing specific business logic based on the content of the events;

## Supported Task Types
`Before using this framework, please determine whether it is suitable for your needs based on the supported job types.`  
| Value       | Type                     | Example Value      | Description                                                                         |
| ----------- | :----------------------- | :----------------- | :---------------------------------------------------------------------------------- |
| Setup       | Installation and Upgrade | ""                 | Runs after startup                                                                  |
| Startup     | Startup                  | "2000"             | Runs before all tasks after Setup, with a delay of 2 seconds. May run continuously. |
| Event       | Event Trigger            | "DirChangeEventer" | Triggered when the specified directory changes                                      |
| Interval    | Interval Execution       | "00:00:20"         | Runs every 20 seconds                                                               |
| Schedulable | Cron Expression          | "* 0/10 * * * ?"   | Cron expression: Executes every 10 minutes                                          |

NOTE: `Job type extensions are not supported at the moment`.

--- 

- [JobAgent](#jobagent)
  - [Advantages](#advantages)
  - [Applicable Scenarios](#applicable-scenarios)
  - [Common Usage Examples](#common-usage-examples)
  - [Supported Task Types](#supported-task-types)
- [Project structure](#project-structure)
- [Quick Start (Simple Example)](#quick-start-simple-example)
  - [Lifecycle of Job](#lifecycle-of-job)
  - [Descript a Job](#descript-a-job)
    - [Code Implementation](#code-implementation)
    - [Application Configuration](#application-configuration)
  - [Worker is Executing while Job Trigger (Job.WorkerName)](#worker-is-executing-while-job-trigger-jobworkername)
- [Key Components in JobsFactory Framework](#key-components-in-jobsfactory-framework)
  - [Job - A task Configuration](#job---a-task-configuration)
    - [Configuration in `appsettings.json`](#configuration-in-appsettingsjson)
    - [Code Implementation](#code-implementation-1)
  - [JobContext - State and Context During Task Execution](#jobcontext---state-and-context-during-task-execution)
    - [Custom CustomJobContext](#custom-customjobcontext)
  - [Worker - The Business Logic Execution Unit](#worker---the-business-logic-execution-unit)
    - [Simple Implementation](#simple-implementation)
  - [Event - Customizing the Triggering Event for Event-Driven Jobs](#event---customizing-the-triggering-event-for-event-driven-jobs)
    - [Simple Implementation](#simple-implementation-1)
  - [Watcher - Each Watcher Monitors Certain Types of Jobs](#watcher---each-watcher-monitors-certain-types-of-jobs)
    - [Simple Implementation of an Event Watcher](#simple-implementation-of-an-event-watcher)
    - [Implementation of a Custom Watcher](#implementation-of-a-custom-watcher)
- [Usage](#usage)
  - [Starting from Scratch](#starting-from-scratch)
    - [Create a New dotnet8 Console Project](#create-a-new-dotnet8-console-project)
    - [Modify Program.cs](#modify-programcs)
    - [Subsequent Steps](#subsequent-steps)
  - [Plugin Mode (Recommended)](#plugin-mode-recommended)
    - [Plugin Configuration Class](#plugin-configuration-class)
    - [Override the ConfigureServices Method](#override-the-configureservices-method)
    - [Subsequent Steps](#subsequent-steps-1)
- [Configuration](#configuration)
  - [Overview](#overview)
  - [Job Configuration](#job-configuration)
    - [Job Configuration Example](#job-configuration-example)
    - [Job Parameter Description](#job-parameter-description)
  - [Configuration for TimeWatcher](#configuration-for-timewatcher)
  - [Plugin Configuration](#plugin-configuration)
  - [Common Parameter Configuration](#common-parameter-configuration)
  - [Obtain Configuration Information](#obtain-configuration-information)
  - [Dynamic Configuration Loading](#dynamic-configuration-loading)
- [Running JobAgent](#running-jobagent)
  - [Manual Execution](#manual-execution)
  - [As a Windows Service](#as-a-windows-service)
  - [As a Docker Container](#as-a-docker-container)
    - [Parameter Description](#parameter-description)
- [Contributing](#contributing)
- [Special Thanks](#special-thanks)

---


# Project structure

```tree
JobAgent.sln
└── JobAgent.Console          // The console that invokes the terminal (entry point for execution)	
└── JobSamples                // Some examples of Job invocations
```
- `JobAgent.Console` does not depend on the `JobSamples` library.
- After `JobSamples` is generated, it can be copied into the `/Plugins/JobSamples` directory under the running directory of `JobAgent.Console`.
- Without the plugin module, this project will not have any workload.



# Quick Start (Simple Example)

## Lifecycle of Job
Different types of jobs are implemented to handle different types of tasks.

<details>
<summary>The workflow for Job task execution</summary>   

![The workflow for Job task execution](./docs/assets/jobfactory/job-work-flow.png)
</details>

## Descript a Job

### Code Implementation

<details>
<summary>Example</summary>

```cs
public class Interval10Sec : Job
{
    public Interval10Sec()
    {
        Trigger = "00:00:10";
    }
    public override string? WorkerName => nameof(SimapleWorker);
}
```

</details>

### Application Configuration

<details>
<summary>Example</summary>

```json
{
 "Jobs": {
   // SampleJobs is the module name, used to distinguish Jobs with the same Job name in multiple plugin modules.
   "SampleJobs": [
     {
       "name": "Interval10Sec",
       "trigger": "00:00:10",
       "workerName": "SimapleWorker"
     },
   ]
 }
}
```
</details>


## Worker is Executing while Job Trigger (Job.WorkerName)
By using the following code, the `SimpleWorker.ExecuteAsync` method will be executed every 10 seconds.

<details>
<summary>Example</summary>

```cs
[KeyedName]
public sealed class SimapleWorker(IServiceProvider serviceProvider) : Worker<JobContext>(serviceProvider)
{
    protected override async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        await Task.Delay(500, cancellationToken); //mock execute 0.5 second.
        await ExecuteCallbackAsync(true);// work finish callback. It's not necessary.
    }
   
    protected override async Task ExecuteCallbackAsync<TResult>(TResult? result) where TResult : default
    {
        if (result is true)
            Logger.LogDebug($"Worker are success.");
        await Task.CompletedTask;
    }
}
```
</details>

> Note the handling of the `CancellationToken` signal, which will receive a cancellation signal when the application stops.


# Key Components in JobsFactory Framework
To better utilize the JobFactory framework and to extend and customize it more deeply, it is essential to understand the relevant components within the framework.
> You can visit [Architecture UML](https://blog.aicro.net/posts/job-v8/v8-task-user-uml) to view the UML class diagram.

## Job - A task Configuration
- A Job is a description of a task, through which you can set its job type and the business logic unit to be executed.
- There are two ways to configure it: typically in the application configuration `appsettings.json` or in the configuration of a plugin module `moduleAssemblyName.json`. Alternatively, you can achieve the same effect by inheriting from the Job class directly in code.
- Once the type of the Job's Trigger is set, do not change it.

### Configuration in `appsettings.json`
<details>
<summary>Example</summary>

```json
{
 "Jobs": {
   // SampleJobs is the module name, used to distinguish Jobs with the same Job name in multiple plugin modules.
   "SampleJobs": [
     {
       "name": "Interval10Sec",
       "trigger": "00:00:10",
       "workerName": "SimapleWorker"
     },
   ]
 }
}
```

</details>

### Code Implementation

<details>
<summary>Example</summary>

```cs
public class Interval10Sec : Job
{
    public Interval10Sec()
    {
        Trigger = "00:00:10";
    }
    public override string? WorkerName => nameof(SimapleWorker);
}
```

</details>

## JobContext - State and Context During Task Execution
- JobContext is the context and state corresponding to each Job, which will be persisted to the default `/states/` directory after the first run.
- When the task runs again, it will read the last persisted state and restore it as the current JobContext.
- Each JobContext must implement the corresponding JobFactory to create the context.
- You can also use it directly without creating a custom JobContext. You can set and retrieve different working states through the Data property.

### Custom CustomJobContext

<details>
<summary>Example</summary>

```cs
public sealed class CustomJobContext : JobContext
{
    public bool Done
    {
        get; set;
    }
}

public sealed class CustomJobContextFactory(IServiceProvider serviceProvider)
    : JobContextServiceBase(serviceProvider), IJobContextFactory<CustomJobContext>, ITransient
{
    public override CustomJobContext LoadOrCreate(IJob job)
    {
        var ctx = LoadOrCreateNew(job, Create);
        return ctx;
    }

    protected override CustomJobContext Create() => new();
}

```

</details>

## Worker - The Business Logic Execution Unit
- Workers are registered to the DI container using their class name via `KeyedName`, or you can specify a string name. If no name is specified, the full class name will be registered in the DI container.
- When implementing your own Worker business class, you need to point the WorkerName of the Job to it.
- Each Worker requires a corresponding JobContext to determine the context type.

### Simple Implementation

<details>
<summary>Example</summary>

```cs
[KeyedName]
public sealed class SimapleWorker(IServiceProvider serviceProvider) : Worker<JobContext>(serviceProvider)
{
    protected override async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        await Task.Delay(500, cancellationToken); //mock execute 0.5 second.
        await ExecuteCallbackAsync(true);// work finish callback. It's not necessary.
    }
   
    protected override async Task ExecuteCallbackAsync<TResult>(TResult? result) where TResult : default
    {
        if (result is true)
            Logger.LogDebug($"Worker are success.");

        await Task.CompletedTask;
    }
}
```

</details>


## Event - Customizing the Triggering Event for Event-Driven Jobs
- This is the event trigger for the Job's triggering type.
- Each event is different, so it needs to be implemented based on specific business requirements.
- The class name of the event is the name of the class that starts the event detection.

### Simple Implementation

<details>
<summary>Example</summary>

```cs
[KeyedName]
public sealed class RouterEventer(IServiceProvider serviceProvider) : Eventer<TimeJobContext>(serviceProvider)
{
    public override async Task StartAsync(TimeJobContext? jobContext, CancellationToken cancellationToken)
    {
        await base.StartAsync(jobContext, cancellationToken);
        var receiver = new UdpReceiver(ServiceProvider, cancellationToken);
        receiver.OnMessage += async (s, e) =>
        {
            var workerName = jobContext.GetWorkerName();
            var worker = ServiceProvider.GetKeyedService<IWorker<TimeJobContext>>(workerName);
            if (worker == null)
            {
                Logger.LogError($"{this} No Worker[{workerName}] was found.");
                return;
            }

            var dnsrst = jobContext!.GetData<DDNSState>() ?? new DDNSState();
            jobContext.SetData(dnsrst);
            await worker.StartAsync(jobContext, cancellationToken); //trigger the worker.
        };
        await Task.CompletedTask;
    }
}

```

</details>

## Watcher - Each Watcher Monitors Certain Types of Jobs
- Each Watcher monitors one or more Jobs.
- Each Watcher corresponds to a specific JobContext.
- It creates the corresponding JobContext for the Job when it starts.
- It is responsible for triggering and managing the Worker of the Job.
- For Jobs of the same Trigger type, there may be multiple Watchers, with Watchers corresponding to Triggers and specific JobContexts.
- You can implement a custom Watcher.

### Simple Implementation of an Event Watcher

<details>
<summary>Example</summary>

```cs
public sealed class MyEventWatcher(IServiceProvider serviceProvider) : EventWatcherBase<MyJobContext>(serviceProvider)
{
}
```

</details>


### Implementation of a Custom Watcher

<details>
<summary>Example</summary>

```cs
public sealed class MyWatcher(IServiceProvider serviceProvider) : Watcher<MyJobContext>(serviceProvider), ITransient
{
    protected override TriggerStyle TriggerStyle => TriggerStyle.Setup;

    protected override async Task ExecuteAsync()
    {
        var ctxs = JobContexts;
        using var logDis = Logger.BeginScopeLog(out string scopedId);
        try
        {
            var runjxs = ctxs.Where(x => !x.Done).OrderBy(x => x.OrderVersion);
            foreach (var run in runjxs)
            {
                if (AppCancellationToken.IsCancellationRequested) break;
                var name = run.GetWorkerName();
                var worker = ServiceProvider.GetKeyedService<IWorker<SetupJobContext>>(name);
                if (worker == null)
                    Logger.LogError($"{this} No Worker[{name}] was found.");
                else
                    await worker.StartAsync(run, AppCancellationToken);
            }
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, $"{this} has exception:{ex.Message}");
        }
    }
}
```

</details>


# Usage

## Starting from Scratch

### Create a New dotnet8 Console Project
- Add the required package references.
```shell
NuGet\Install-Package Aicrosoft.Scheduling
NuGet\Install-Package Aicrosoft.Extensions.Hosting
```

### Modify Program.cs

<details>
<summary>Example</summary>

```cs
using Aicrosoft.Logging.NLog;
using Aicrosoft.Services;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var start = Environment.TickCount64;
var logger = NLogHelper.GetLogger();
logger.DelegateDiag();
logger.CaptureGlobalException();
logger.LogTrace($"Loggger was created TimeElapsed:{Environment.TickCount64 - start} ms");
try
{
    NLogHelper.SetConfigurationVariableWhenRelease("logLevel", "Info");
    start = Environment.TickCount64;
    logger.LogTrace($"Begin Build Host Envirment ...");
    using IHost host = Host.CreateDefaultBuilder(args)
        .AddServices() //add entry assembly to DI
        .AddJobsFactory()  //use jobsfactory component.
        .AddPluginsService() //enable plugins support.
        .AddAsWindowsService("JobAgent")
        .AddNLog()
        //.UseAop()
        .AddServiceDIDebug() //show DI table.
        .Build()
        ;
    ServiceLocator.ServiceProvider = host.Services; //DI Service hook.
    logger.LogTrace($"End Build. TimeElapsed:{Environment.TickCount64 - start} ms");
    await host.RunAsync();
    return 0;
}
catch (Exception ex)
{
    logger.LogError(ex, "Build and run IHost has a exception");
    return -9;
}
finally
{
    NLogHelper.Shutdown();
}

```

</details>


### Subsequent Steps

- Add Job configurations or code.
- Implement the business logic Worker.
- If extending JobContext, implement the corresponding JobContextFactory and Worker.

## Plugin Mode (Recommended)

- Use the existing open-source [JobAgent](https://github.com/neatFactory/JobAgent).
- Create a new library project and add the reference.
```shell
NuGet\Install-Package Aicrosoft.Scheduling
NuGet\Install-Package Aicrosoft.Extensions.Hosting
```
- The plugin assembly is your business module, where you can fully implement complex business logic.
- As long as the corresponding Job description is implemented, it will be called by the framework.
- When a plugin assembly has dependencies on libraries outside of those in JobAgent, add `<EnableDynamicLoading>true</EnableDynamicLoading>` in the assembly properties.⚠️


### Plugin Configuration Class

- It automatically adds services from the plugin assembly to the DI container.
- It defaults to reading the configuration from `AssemblyName.json`.

<details>
<summary>Example</summary>

```cs
public class JobAppSetup : PluginSetupBase
{
}
```

</details>


### Override the ConfigureServices Method

- If you have custom configuration instances, override the `ConfigureServices` method.

<details>
<summary>Example</summary>

```cs
public class JobAppSetup : PluginSetupBase
{
    protected override void ConfigureServices(HostBuilderContext hostBuilderContext, IServiceCollection services)
    {
        base.ConfigureServices(hostBuilderContext, services);
        services.Configure<DDNSOption>(hostBuilderContext.Configuration.GetSection(DDNSOption.SectionName));

        // Add custom service to DI
        services.AddSingleton<IMyBiz, MyBiz>();
    }
}
```

</details>

### Subsequent Steps
- Copy the files generated in the bin directory of the assembly to the `Bin\Plugins\PluginName\` directory of [JobAgent](https://github.com/neatFactory/JobAgent).


# Configuration

## Overview
- The `appsettings.json` in JobAgent is not mandatory. Without it, all plugin modules will be loaded.
- Different modules in the `Plugins` directory of JobAgent will load their correspondingly named configuration files by default.
- If the `Aicrosoft.Extensions.NLog` module is used, `nlog.config` is the configuration for NLog.

## Job Configuration
🚀 **Job configuration is the core of the entire system**
You can configure it in the `appsettings.json` under the root directory of JobAgent, or in the correspondingly named configuration under the plugin directory.

### Job Configuration Example
<details>
<summary>Example</summary>

```json
{
  "Jobs": {
    // SampleJobs is the module name, used to distinguish Jobs with the same Job name in multiple plugin modules.
    "SampleJobs": [
      {
        "enable": false,
        "name": "Interval-Woker-Sample1",
        "trigger": "00:00:05",
        "workerName": "SampleJobs.Aicrosoft.SimpleIntervalWorker, SampleJobs"
      },
      {
        "enable": true,
        "name": "L11",
        "trigger": "* 0/10 * * * ?",
        "priority": "lowest",
        "workerName": "LoopSampleWorker"
      },
    ]
  }
}

```
</details>

### Job Parameter Description
- `Jobs` - A structure keyed by module name, with Job configurations as arrays.
- `name` - The name of the Job, not mandatory.
- `enable` - Whether to enable this task.
- `trigger` - The triggering method, refer to [Supported Job Types](#supported-job-types).
- `workerName` - The name in the DI container for the business logic class to be executed after the Job is triggered.
- `timeout` - Default is 30 seconds. It is the timeout for executing the specific business logic. Jobs of the `Startup` type are not limited by this.
- `extend` - A dictionary of type `Dictionary<string, string>` that provides additional property extensions for this Job.
- Subclasses of Job can implement equivalent configurations in the configuration.

## Configuration for TimeWatcher

<details>
<summary>Example</summary>

```json
{
    "TimeWatcher": {
        "Delay": "00:00:30" 
  },
}

```
</details>

- The node can be omitted and the default value will be used.
- TimeWatcher will run after a 30-second delay by default.
- TimeWatcher monitors Jobs of the `Interval` and `Schedulable` types.

## Plugin Configuration

<details>
<summary>Example</summary>

```json
{
    "Plugins": {
        "PluginsRoot": "Plugins",
        "DisableAutoload": true, 
        "AssemblyNames": {
            "SampleJobs": true,
            "DDNSJob": false
        }
    }
}
```
</details>

- `PluginsRoot` - The root directory name for plugins, default is `Plugins`.
- `DisableAutoload` - When set to `true`, it will load plugins based on the `AssemblyNames` configuration instead of automatically loading them.
- `AssemblyNames` - Specifies which plugins to load.
  - If `false`, it will automatically load all plugins under the `PluginsRoot` directory.

## Common Parameter Configuration

<details>
<summary>Example</summary>

```json
{
 "Resources": [
   {
     "name": "NetFile",
     "type": "Http",
     "value": "http://127.0.0.1/{0:yyyyMMdd}.txt"
   },
   {
     "name": "LocalFile",
     "type": "Local",
     "value": "Data\\{0:yyyyMMdd}_{1}.txt",
     "params": {
       "encoding": "gb2312",
       "account": "admin",
       "password": "admin1234.com"
     }
   },
   {
     "name": "RankDb",
     "type": "SqlServer",
     "value": "Data Source=192.168.1.50;Initial Catalog=DbRank;User ID=sa;Password=sa;App=WST_SG2Rank V1.0"
   }
 ]
}
```
</details>

## Obtain Configuration Information

<details>
<summary>Example</summary>

```cs
var resources = Services.GetService<IOptions<ResourcesOption>>().Value;
```
</details>

## Dynamic Configuration Loading
Dynamic configuration loading is not supported at the moment. If you modify the configuration, you must restart the application.


# Running JobAgent
There are several ways to run JobAgent.

## Manual Execution
Download the corresponding version from [Release](https://github.com/neatFactory/JobAgent/releases), extract it, and then run:
```shell
.\JobAgent
```

## As a Windows Service
1. Download the latest version of [JobAgent_...win-x64.zip](https://github.com/neatFactory/JobAgent/releases) for the Windows platform.
2. Extract it to the running directory, and then modify the configuration in the installation script to the desired Windows service name and description.
   ```bat
    set serviceApp="JobAgent.exe"  
    set serviceName="JobAgent" # modify it.
    set serviceDescription="This is a Windows task scheduling system called JobAgent."; # modify it.
   ```
3. Execute the installation command.
```shell
install -i  # install it 
```

4. You will then be able to see the service in the Windows Services panel.
5. Execute the uninstallation command.
```shell
install -u  # uninstall it 
```

## As a Docker Container
Available Docker registries:

- <https://hub.docker.com/r/aicrosoft/jobagent>
- <https://github.com/neatFactory/JobAgent/pkgs/container/jobagent>
> Visit <https://hub.docker.com/r/aicrosoft/jobagent> to get the latest Docker image.

```shell

# Debugging creation, you can enter the container to perform operations
sudo docker run -d \
  --name jobagent \
  aicrosoft/jobagent:debug


# Volume mapping creation

## Pre-create Empty Directories on the Host Machine and Assign Permissions
sudo mkdir -p /apps/ja/logs /apps/ja/plugins /apps/ja/states
sudo chmod -R 777 /apps/ja
sudo chown -R 65532:65532 /apps/ja

## Create a Container
sudo docker run -d \
  --name jobagent \
  -v /apps/ja/logs:/app/logs:rw \
  -v /apps/ja/plugins:/app/Plugins:rw \
  -v /apps/ja/states:/app/states:rw \
  aicrosoft/jobagent:latest
```

### Parameter Description
- If you don't need to view logs, you don't need to map `/app/logs`. Logs will only be retained for 30 days.
- If you don't need to view or modify the state of Jobs, you don't need to map `/app/states`.
- If you map `/app/Plugins`, you must place the plugin content in the corresponding path on the host machine.
- You can map `/app/appsettings.json` to the corresponding configuration on the host machine.
- You can map `/app/Plugins/PluginName/PluginName.json` to the corresponding configuration on the host machine.


# Contributing

Contributions are welcome! Feel free to submit a Pull Request.

> A good question is more important than the answer!

# Special Thanks

