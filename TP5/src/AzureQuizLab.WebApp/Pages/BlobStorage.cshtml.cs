using AzureQuizLab.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Text.Json;

namespace AzureQuizLab.Pages;

public class BlobStorageModel : PageModel
{
    private readonly BlobService _blobService;

    public BlobStorageModel(BlobService blobService)
    {
        _blobService = blobService;
    }

    public List<string> Files { get; set; } = new();

    [BindProperty]
    public string SelectedFile { get; set; }

    public string? Content { get; set; }

    public async Task OnGetAsync()
    {
        Files = await _blobService.ListAsync();
    }

    public async Task<IActionResult> OnPostUploadAsync()
    {
        var json = JsonSerializer.Serialize(new
        {
            user = "jp",
            score = Random.Shared.Next(0, 10),
            date = DateTime.UtcNow
        });

        await _blobService.UploadAsync(json);
        Files = await _blobService.ListAsync();
        return Page();
    }

    public async Task<IActionResult> OnPostDownloadAsync()
    {
        Files = await _blobService.ListAsync();
        Content = await _blobService.DownloadAsync(SelectedFile);
        return Page();
    }
}
