using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace Aicrosoft.Extensions;

public static class ConfigureExtensions
{


    public static IHostBuilder AddCurrentAssemblyService(this IHostBuilder hostBuilder)
    {
        hostBuilder.ConfigureServices((hostContext, services) =>
        {
            services.AddService(typeof(ConfigureExtensions).Assembly);
        });
        return hostBuilder;
    }


}
