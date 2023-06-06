using Aspose.Words;
using Aspose.Words.Rendering;
using Aspose.Words.Saving;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Hosting;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace DocumentComparison
{
	public class DocumentSession {
		public string docid;
		public string sessionid;
		public string sessiontime;
	}
    public partial class Default : System.Web.UI.Page
    {
        public string CurrentFolder
        {
            get
            {
                return ViewState["CurrentFolder"] as string;
            }
            set
            {
                ViewState["CurrentFolder"] = value;
            }
        }
		static SqlConnection conn;
		static SqlCommand comm;
		static SqlDataReader dreader;
		static string connstring = "server=localhost;database=PT_dm1_Data;Integrated Security=True;";
		protected void Page_Load(object sender, EventArgs e)
        {
            Common.SetLicense();
            if (!IsPostBack)
            {
                this.CurrentFolder = Common.DataDir;
				//GetAllPageViewd("269");

			}
            
            // Handle file upload, ONLY in case of post back
         //   if (IsPostBack)
                //UploadFile(sender, e);

            //PopulateFoldersAndFiles();
        }
		[WebMethod]
		public static ArrayList GetDocumentData(string filePath, string sessionID)
		{
			Common.SetLicense();

			ArrayList result = new ArrayList();
			try
			{
				// Create a temporary folder
				string documentFolder = CreateTempFolders(filePath, sessionID);

				// Load the document in Aspose.Words
				Document doc = new Document(filePath);
				// Convert the document to images
				ImageSaveOptions options = new ImageSaveOptions(SaveFormat.Jpeg);
				options.PageCount = 1;
				// Save each page of the document as image.
				for (int i = 0; i < doc.PageCount; i++)
				{
					options.PageIndex = i;
					doc.Save(string.Format(@"{0}\{1}.png", documentFolder, i), options);
				}
				result.Add(Common.Success); // 0. Result
				result.Add(doc.PageCount.ToString()); // 1. Page count
				result.Add(MapPathReverse(documentFolder)); // 2. Images Folder path
			}
			catch (Exception ex)
			{
				result.Clear();
				result.Add(Common.Error + ": " + ex.Message); // 0. Result
			}
			return result;
		}

		[WebMethod]
		public static string SavePageData(string UserID,string docid, string pageNo)
		{
			string result = pageNo;
			if (docid != "null" && (GEtPageDataExistsInDB(docid, pageNo) == 0))
			{
				SavePageDatainDB(UserID,docid, pageNo);

			}
			return result;
		}

		[WebMethod]
		public static Array GetPageViewdData(string docid)
		{
			return GetAllPageViewd(docid).ToArray();
		}

		[WebMethod]
		public static Array GetDocumentSessionData(string docId, string sessionTime)
		{
			return GetSessionData(docId, sessionTime).ToArray();
		}

		private static List<DocumentSession> GetSessionData(string docId, string sessionTime) {
			List<DocumentSession> documentSeesions = new List<DocumentSession>();
			conn = new SqlConnection(connstring);
			conn.Open();
			comm = new SqlCommand("insert into DocumentPageSession values(" + docId + ", '"+ sessionTime + "')", conn);
			try
			{
				comm.ExecuteNonQuery();
				comm = new SqlCommand("select * from DocumentPageSession where docid = " + docId, conn);
				using (SqlDataReader reader = comm.ExecuteReader())
				{
					while (reader.Read())
					{
						string docid = Convert.ToString(reader["docid"]);
						string sessionid = Convert.ToString(reader["sessionid"]);
						string sessiontime = Convert.ToString(reader["sessiontime"]);
						documentSeesions.Add(new DocumentSession() { docid = docid, sessionid = sessionid, sessiontime = sessiontime });
					}
				}
			
				//returnMess = "Saved...";
			}
			catch (Exception)
			{
				//returnMess = "Not Saved";
			}
			finally
			{
				conn.Close();
			}
			return documentSeesions;
		}

		public static string SavePageDatainDB(string UserID, string docid, string pageNo)
		{
			string returnMess = string.Empty;
			conn = new SqlConnection(connstring);
			conn.Open();
			comm = new SqlCommand("insert into DocumentPageMapping values(" + docid + ",'" + pageNo + "','" + UserID + "')", conn);
			try
			{
				comm.ExecuteNonQuery();
				 returnMess= "Saved...";
			}
			catch (Exception)
			{
				returnMess = "Not Saved";
			}
			finally
			{
				conn.Close();
			}
			return returnMess;
		}
		public static int GEtPageDataExistsInDB(string docid, string pageNo)
		{
			string returnMess = string.Empty;
			int RecordCount = 0;
			conn = new SqlConnection(connstring);
			conn.Open();
			comm = new SqlCommand("select Count(*) from DocumentPageMapping where docid = " + docid + " and PageViewd=" + pageNo + " ", conn);
			try
			{
				 RecordCount = Convert.ToInt32(comm.ExecuteScalar()); 
			}
			catch (Exception)
			{
				return RecordCount;
			}
			finally
			{
				conn.Close();
			}
			return RecordCount;
		}

		public static List<string> GetAllPageViewd(string docid)
		{
			List<string> li = new List<string>();
			string returnMess = string.Empty;
			int RecordCount = 0;
			conn = new SqlConnection(connstring);
			conn.Open();
			comm = new SqlCommand("select * from DocumentPageMapping where docid = " + docid + " ", conn);
			try
			{
				SqlDataReader sdr = comm.ExecuteReader();
				while (sdr.Read())
				{
					li.Add(sdr["PageViewd"].ToString());
				}
			}
			catch (Exception)
			{
				return li;
			}
			finally
			{
				conn.Close();
			}
			return li;
		}

		public static string MapPathReverse(string path)
		{
			string appPath = HttpContext.Current.Server.MapPath("~");
			var scheme = HttpContext.Current.Request.Url.Scheme;
			var host = HttpContext.Current.Request.Url.Host;
			var port = HttpContext.Current.Request.Url.Port;
			var virtualPath = path.Replace(appPath, "").Replace("\\", "/");
			string res = string.Format("{3}://{0}:{1}/{2}", host, port, virtualPath, scheme);
			return res;
		}

		/// <summary>
		/// Create a temporary folder to store the images for the document
		/// </summary>
		/// <param name="filePath"></param>
		/// <param name="sessionID"></param>
		private static string CreateTempFolders(string filePath, string sessionID)
		{
			// Create the folder unique to the user's session
			string tempFolder = HostingEnvironment.MapPath(Common.tempDir);
			string sessionFolder = tempFolder + Path.DirectorySeparatorChar + sessionID;
			if (Directory.Exists(sessionFolder) == false)
				Directory.CreateDirectory(sessionFolder);

			// In session folder, re-create the folder for the document
			string documentFolder = Path.Combine(sessionFolder, Path.GetFileName(filePath));
			if (Directory.Exists(documentFolder) == true)
				Directory.Delete(documentFolder, true);
			Directory.CreateDirectory(documentFolder);

			return documentFolder;
		}

	}
}