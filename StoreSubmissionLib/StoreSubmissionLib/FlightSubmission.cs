using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreSubmissionLib
{

    public class FlightSubmission
    {
        public string id { get; set; }
        public string flightId { get; set; }
        public string status { get; set; }
        public Statusdetails statusDetails { get; set; }
        public List<ApplicationPackage> flightPackages { get; set; }
        public string fileUploadUrl { get; set; }
        public string targetPublishMode { get; set; }
        public DateTime targetPublishDate { get; set; }
        public string notesForCertification { get; set; }
    }

}
