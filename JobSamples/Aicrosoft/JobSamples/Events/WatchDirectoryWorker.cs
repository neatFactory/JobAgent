using Aicrosoft.Scheduler.Eventers;
using Aicrosoft.Scheduler.Jobs;
using Aicrosoft.Scheduler.Workers;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Text;

namespace Aicrosoft.JobSamples.Events;

/// <summary>
/// Fetch the dir chagned event.
/// </summary>
/// <param name="serviceProvider"></param>
[KeyedName]
public sealed class WatchDirectoryWorker(IServiceProvider serviceProvider) : Worker<JobContext>(serviceProvider)
{
    protected override async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        var e = Context!.GetData<FileSystemEventArgs>();
        Logger.LogInformation($"DirectoryChanged[{e?.ChangeType}] --> {e?.FullPath} . and the FileSystemEventArgs result is -> {e?.ToJson()}");
        await ExecuteCallbackAsync(true);
    }
}


public sealed class WatchDownloadDirectoryEventJob : Job
{
    public WatchDownloadDirectoryEventJob()
    {
        Trigger = nameof(DirectoryChangeSimpleEventer); //the envet startup name.
        Extend.Add("TartgetDirectoryPath", "C:\\");
    }

    public override string? WorkerName => nameof(WatchDirectoryWorker);

}
