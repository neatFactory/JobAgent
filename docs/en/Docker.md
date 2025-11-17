# JobAgent

```text
   __        _       _                    _   
   \ \  ___ | |__   /_\   __ _  ___ _ __ | |_ 
    \ \/ _ \| '_ \ //_\\ / _` |/ _ \ '_ \| __|
 /\_/ / (_) | |_) /  _  \ (_| |  __/ | | | |_ 
 \___/ \___/|_.__/\_/ \_/\__, |\___|_| |_|\__|
                         |___/                
```
![LOGO](https://github.com/neatFactory/JobAgent/raw/main/docs/assets/logo/128.png)

📖👉 [查看中文帮助文档](https://github.com/neatFactory/JobAgent/tree/main/docs/cn) 

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

## Run As a Docker 
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

