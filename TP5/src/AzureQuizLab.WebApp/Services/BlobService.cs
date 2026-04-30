using Azure.Core;
using Azure.Identity;
using Azure.Storage.Blobs;

namespace AzureQuizLab.Services;

public class BlobService
{
    private readonly BlobContainerClient _container;

    //public BlobService(IConfiguration config)
    //{
    //    var serviceClient = new BlobServiceClient(
    //        new Uri(config["Storage:Url"]),
    //        new DefaultAzureCredential());

    //    _container = serviceClient.GetBlobContainerClient("quiz-results");
    //    _container.CreateIfNotExists();
    //}

    public BlobService(IConfiguration config, IHostEnvironment env)
    {
        TokenCredential credential = new ChainedTokenCredential(
            new ManagedIdentityCredential(),
            new AzureCliCredential());

        var serviceClient = new BlobServiceClient(
            new Uri(config["Storage:Url"]!),
            credential);

        _container = serviceClient.GetBlobContainerClient("quiz-results");
        _container.CreateIfNotExists();
    }

    //public BlobService(IConfiguration config, IHostEnvironment env)
    //{
    //    var tenantId = config["Storage:TenantId"];

    //    TokenCredential credential = env.IsDevelopment()
    //        ? new AzureCliCredential(new AzureCliCredentialOptions
    //        {
    //            TenantId = tenantId
    //        })
    //        : new DefaultAzureCredential(new DefaultAzureCredentialOptions
    //        {
    //            TenantId = tenantId
    //        });

    //    var serviceClient = new BlobServiceClient(
    //        new Uri(config["Storage:Url"]!),
    //        credential);

    //    _container = serviceClient.GetBlobContainerClient("quiz-results");
    //    _container.CreateIfNotExists();
    //}

    public async Task<string> UploadAsync(string content)
    {
        var name = $"result-{Guid.NewGuid()}.json";
        var blob = _container.GetBlobClient(name);

        await blob.UploadAsync(BinaryData.FromString(content));

        return name;
    }

    public async Task<List<string>> ListAsync()
    {
        var result = new List<string>();

        await foreach (var blob in _container.GetBlobsAsync())
        {
            result.Add(blob.Name);
        }

        return result;
    }

    public async Task<string> DownloadAsync(string name)
    {
        var blob = _container.GetBlobClient(name);

        var content = await blob.DownloadContentAsync();

        return content.Value.Content.ToString();
    }
}