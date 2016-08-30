using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreSubmissionLib
{
    public class Submission
    {
        public string id { get; set; }
        public string applicationCategory { get; set; }
        public Pricing pricing { get; set; }
        public string visibility { get; set; }
        public string targetPublishMode { get; set; }
        public DateTime targetPublishDate { get; set; }
        public Dictionary<string, Listing> listings { get; set; }
        public object[] hardwarePreferences { get; set; }
        public bool automaticBackupEnabled { get; set; }
        public bool canInstallOnRemovableMedia { get; set; }
        public bool isGameDvrEnabled { get; set; }
        public bool hasExternalInAppProducts { get; set; }
        public bool meetAccessibilityGuidelines { get; set; }
        public string notesForCertification { get; set; }
        public string status { get; set; }
        public Statusdetails statusDetails { get; set; }
        public string fileUploadUrl { get; set; }
        public List<ApplicationPackage> applicationPackages { get; set; }
        public string enterpriseLicensing { get; set; }
        public bool allowMicrosoftDecideAppAvailabilityToFutureDeviceFamilies { get; set; }
        public Allowtargetfuturedevicefamilies allowTargetFutureDeviceFamilies { get; set; }
        public string friendlyName { get; set; }
    }

    public class Pricing
    {
        public string trialPeriod { get; set; }
        public Marketspecificpricings marketSpecificPricings { get; set; }
        public object[] sales { get; set; }
        public string priceId { get; set; }
    }

    public class Marketspecificpricings
    {
    }

    public class Listing
    {
        public Baselisting baseListing { get; set; }
        public Platformoverrides platformOverrides { get; set; }
    }

    public class Baselisting
    {
        public string copyrightAndTrademarkInfo { get; set; }
        public string[] keywords { get; set; }
        public string licenseTerms { get; set; }
        public string privacyPolicy { get; set; }
        public string supportContact { get; set; }
        public string websiteUrl { get; set; }
        public string description { get; set; }
        public string[] features { get; set; }
        public string releaseNotes { get; set; }
        public Image[] images { get; set; }
        public string[] recommendedHardware { get; set; }
        public string title { get; set; }
    }

    public class Image
    {
        public string fileName { get; set; }
        public string fileStatus { get; set; }
        public string id { get; set; }
        public string imageType { get; set; }
    }

    public class Platformoverrides
    {
    }

    public class Statusdetails
    {
        public object[] errors { get; set; }
        public object[] warnings { get; set; }
        public object[] certificationReports { get; set; }
    }

    public class Allowtargetfuturedevicefamilies
    {
        public bool Desktop { get; set; }
        public bool Mobile { get; set; }
        public bool Holographic { get; set; }
        public bool Xbox { get; set; }
    }

    public class ApplicationPackage
    {
        public string fileName { get; set; }
        public string fileStatus { get; set; }
        public string id { get; set; }
        public string version { get; set; }
        public string architecture { get; set; }
        public string[] languages { get; set; }
        public string[] capabilities { get; set; }
        public string minimumDirectXVersion { get; set; }
        public string minimumSystemRam { get; set; }
        public string[] targetDeviceFamilies { get; set; }
    }


}
