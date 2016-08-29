using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreSubmissionLib
{
    public class App
    {
        public string id { get; set; }
        public string primaryName { get; set; }
        public string publisherName { get; set; }
        public DateTime firstPublishedDate { get; set; }
        public ApplicationSubmission lastPublishedApplicationSubmission { get; set; }
        public string packageFamilyName { get; set; }
        public string packageIdentityName { get; set; }
        public ApplicationSubmission pendingApplicationSubmission { get; set; }
    }

    public class ApplicationSubmission
    {
        public string id { get; set; }
        public string resourceLocation { get; set; }
    }
}
