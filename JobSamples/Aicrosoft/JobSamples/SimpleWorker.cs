using Aicrosoft.Scheduler.Jobs;
using Aicrosoft.Scheduler.Workers;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Aicrosoft.JobSamples;

[KeyedName]
public sealed class SimpleWorker(IServiceProvider serviceProvider) : Worker<TimeJobContext>(serviceProvider)
{
    protected override async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        var rnd = new Random(Environment.TickCount);
        var delayMilliseconds = rnd.Next(50, 2000);
        //Logger.LogDebug($"Job --> {Context!.Job.ToJson()}");
        Logger.LogDebug($"{this} You must override this method. need run [{delayMilliseconds} ms] |-->");
        await Task.Delay(delayMilliseconds, cancellationToken); //MOCK WORK. 超时后立即取消，而不再继续执行了。
        await ExecuteCallbackAsync(true);
        Logger.LogInformation($"{this} Mock run done .dealyMilliseconds[{delayMilliseconds} ms] <--|");
    }
}


