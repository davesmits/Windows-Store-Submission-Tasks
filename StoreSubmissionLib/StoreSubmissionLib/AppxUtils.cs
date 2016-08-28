using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace StoreSubmissionLib
{
    public class AppxUtils
    {
        public Version AnalyzeAppxUpload(string appxUploadFile)
        {
            string temp = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            try
            {
                ZipFile.ExtractToDirectory(appxUploadFile, temp);
                var appxBundleFiles = Directory.GetFiles(temp, "*.appxbundle");
                Version lowestVersion = null;
                foreach (var appxBundle in appxBundleFiles)
                {
                    var version = AnalyzeAppxBundle(appxBundle);
                    if (lowestVersion == null || version < lowestVersion)
                        lowestVersion = version;
                }
                return lowestVersion;
            }
            finally
            {
                Directory.Delete(temp, true);
            }
        }

        private Version AnalyzeAppxBundle(string appxBundleFile)
        {
            string temp = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            try
            {
                ZipFile.ExtractToDirectory(appxBundleFile, temp);
                var appxFiles = Directory.GetFiles(temp, "*.appx");
                Version lowestVersion = null;
                foreach (var appx in appxFiles)
                {
                    var version = AnalyzeAppx(appx);
                    if (lowestVersion == null || version < lowestVersion)
                        lowestVersion = version;
                }
                return lowestVersion;
            }
            finally
            {
                Directory.Delete(temp, true);
            }
        }

        private Version AnalyzeAppx(string appxFile)
        {
            string temp = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            try
            {
                ZipFile.ExtractToDirectory(appxFile, temp);
                var manifestFiles = Directory.GetFiles(temp, "*AppxManifest.xml", SearchOption.AllDirectories);
                Version lowestVersion = null;
                XNamespace ns = "http://schemas.microsoft.com/appx/manifest/foundation/windows10";
                foreach (var manifestFile in manifestFiles)
                {
                    var xDoc = XDocument.Load(manifestFile);

                    var versionString = xDoc.Descendants(ns + "TargetDeviceFamily").Single().Attribute("MinVersion").Value;
                    var version = new Version(versionString);
                    if (lowestVersion == null || version < lowestVersion)
                        lowestVersion = version;

                }
                return lowestVersion;
            }
            finally
            {
                Directory.Delete(temp, true);
            }
        }
    }
}
