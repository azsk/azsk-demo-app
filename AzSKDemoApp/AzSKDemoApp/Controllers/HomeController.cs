using System.Web.Mvc;
using AzSKDemoApp.Helpers;

namespace AzSKDemoApp.Controllers
{
	public class HomeController : Controller
	{
		public ActionResult Index()
		{
			ViewBag.ImageUrl = StorageHelpers.GetUrlForBlobImage();
			return View();
		}
	}
}