using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreSubmissionLib
{

    public class Apps
    {
        public string nextLink { get; set; }
        public App[] value { get; set; }
        public int totalCount { get; set; }
    }

    public class App
    {
        public string id { get; set; }
        public string primaryName { get; set; }
        public string publisherName { get; set; }
        public DateTime firstPublishedDate { get; set; }
        public Lastpublishedapplicationsubmission lastPublishedApplicationSubmission { get; set; }
        public string packageFamilyName { get; set; }
        public string packageIdentityName { get; set; }
        public Pendingapplicationsubmission pendingApplicationSubmission { get; set; }
    }

    public class Lastpublishedapplicationsubmission
    {
        public string id { get; set; }
        public string resourceLocation { get; set; }
    }

    public class Pendingapplicationsubmission
    {
        public string id { get; set; }
        public string resourceLocation { get; set; }
    }

}
