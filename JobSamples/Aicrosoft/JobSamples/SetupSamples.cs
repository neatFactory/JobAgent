using Aicrosoft.Scheduler.Jobs;
using Aicrosoft.Scheduler.Workers;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Reflection;

namespace Aicrosoft.JobSamples;


public sealed class SetupJobV1 : Job
{
    public SetupJobV1()
    {
        Extend["OrderVersion"] = "202511101210";
        Extend["AdaptedVersions"] = "1.*;2.*3.0.*";
        Extend["ExcludedVersions"] = "5.0.*";
    }

    public override string? WorkerName => nameof(SqlServerUpdateV20250827Worker);

}


public sealed class SetupJobV2 : Job
{
    public SetupJobV2()
    {
        Extend["OrderVersion"] = "202510101210";
        Extend["AdaptedVersions"] = "5.*;6.*3;7.0.*";
        Extend["ExcludedVersions"] = "5.0.*";
    }

    public override string? WorkerName => nameof(SqlServerUpdateV20250827Worker);

   
}


[KeyedName]
public sealed class SqlServerUpdateV20250827Worker(IServiceProvider serviceProvider) : Worker<SetupJobContext>(serviceProvider)
{
    protected override async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        var currentVersion = Assembly.GetEntryAssembly()?.GetName().Version;
        if (currentVersion == null || !Context!.IsNeedUpdate(currentVersion))
        {
            Logger.LogDebug($"Current Job is not adapted this version[{currentVersion}]");
            return;
        }

        var rnd = new Random(Environment.TickCount);
        var delayMilliseconds = rnd.Next(500, 2000);
        Logger.LogInformation($"{this} You must override this method. need run [{delayMilliseconds} ms] |-->");
        await Task.Delay(delayMilliseconds, cancellationToken); //MOCK WORK. 超时后立即取消，而不再继续执行了。
        await ExecuteCallbackAsync(true);
        Logger.LogInformation($"{this} Mock run done .dealyMilliseconds[{delayMilliseconds} ms] <--|");
    }

    protected override async Task ExecuteCallbackAsync<TResult>(TResult? result) where TResult : default
    {
        if (result is true)
            Context!.Done = true; //done

        await Task.CompletedTask;
    }

}
