using System;
using System.Configuration;
using System.Threading.Tasks;
using System.Web.Configuration;
using Microsoft.Azure.KeyVault;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;

namespace AzSKDemoApp.Helpers
{
	public static class StorageHelpers
	{
		public static string GetUrlForBlobImage()
		{
			var readPolicy = new SharedAccessBlobPolicy
			{
				Permissions = SharedAccessBlobPermissions.Read,
				SharedAccessExpiryTime = DateTime.UtcNow + TimeSpan.FromMinutes(5)
			};

			// Retrieve storage account from connection string.
			var storageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings["StorageAccountConnectionString"]);

			// Create the blob client.
			var blobClient = storageAccount.CreateCloudBlobClient();

			// Retrieve reference to a previously created container.
			const string containerName = "patent-images";
			var container = blobClient.GetContainerReference(containerName);
			
			const string fullFileName = "prototype.png";
			var blockBlob = container.GetBlockBlobReference(fullFileName);
			var newUri = new Uri(blockBlob.Uri.AbsoluteUri + blockBlob.GetSharedAccessSignature(readPolicy));
			return newUri.ToString();
		}
	}
}