using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreSubmissionLib
{

    public class Flights
    {
        public Flight[] value { get; set; }
        public int totalCount { get; set; }
    }

    public class Flight
    {
        public string flightId { get; set; }
        public string friendlyName { get; set; }
        public ApplicationSubmission lastPublishedFlightSubmission { get; set; }
        public ApplicationSubmission pendingFlightSubmission { get; set; }
        public string[] groupIds { get; set; }
        public string rankHigherThan { get; set; }
    }
}
