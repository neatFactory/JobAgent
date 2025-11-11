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
    //normal flow.
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
