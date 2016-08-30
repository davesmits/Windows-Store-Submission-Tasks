using StoreSubmissionLib;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace StoreSubmission
{
    class Program
    {
        static void Main(string[] args)
        {
#if DEBUG
            string tenantId = "61e615f3-161b-4bda-a67a-407317766d1f";
            string clientId = "8e577dbb-5c5b-4958-ab5b-71ccbb853003";
            string clientSecret = "u+wRbf0vs+Kb1UEmB3c9DBuGOQ7+1mQ3HjggkJWFSP4=";
            string appId = "9nblggh1rmqv";
            string flightName = "AlphaVersion";
            //string flightName = "";
            string filePath = "C:\\Dave\\ATC.Navigation_1.1.54.0_x86_x64_arm_bundle.appxupload";
#else
            Console.WriteLine("number of args: " + args.Length);
            string tenantId = args[0];
            string clientId = args[1];
            string clientSecret = args[2];
            string appId = args[3];
            string flightName = args[4];
            string filePath = args[5];
#endif
            if (!File.Exists(filePath))
            {
                Console.WriteLine($"file: {filePath} does not exists");
                return;
            }

            if (flightName == "-")
                flightName = string.Empty;

            UploadPackageAsync(tenantId, clientId, clientSecret, appId, flightName, filePath).Wait();
        }

        static async Task UploadPackageAsync(string tenantId, string clientId, string clientSecret, string appId, string flightName, string filePath)
        {
            SubmissionService submissionService = new SubmissionService();
            var token = await submissionService.GetAccessToken(tenantId, clientId, clientSecret);
            Console.WriteLine("Access token aquired");

            if (string.IsNullOrEmpty(flightName))
            {
                await StartNonFlightSubmission(token, appId, filePath);
            }
            else
            {
                await StartFlightSubmission(token, appId, flightName, filePath);
            }
        }

        private static async Task StartNonFlightSubmission(AuthenticationResult token, string appId, string filePath)
        {
            SubmissionService submissionService = new SubmissionService();
            var appInfo = await submissionService.GetAppAsync(token.access_token, appId);

            if (appInfo.pendingApplicationSubmission != null)
            {
                Console.WriteLine("Submission already in progresss");
                throw new Exception();
            }

            Submission submission = await submissionService.CreateNewSubmissionAsync(token.access_token, appId);
            Console.WriteLine("Submission created");
            try
            {
                UpdateSubmission(submission, filePath);
                submission = await submissionService.UpdateSubmissionAsync(token.access_token, appId, submission);
                Console.WriteLine("Submission updated with package");

                await submissionService.UploadFileAsync(submission.fileUploadUrl, filePath);
                Console.WriteLine("Appxupload uploaded");

                SubmissionStatus status = await submissionService.CommitSubmissionAsync(token.access_token, appId, submission);
                bool released = CheckSubmissionStatus(submission.targetPublishMode, status, true);
                while (!released)
                {
                    await Task.Delay(TimeSpan.FromSeconds(10));
                    status = await submissionService.GetSubmissionStatusAsync(token.access_token, appId, submission);
                    released = CheckSubmissionStatus(submission.targetPublishMode, status, true);
                }
                Console.WriteLine("Submission released");
            }
            catch
            {
                await submissionService.DeleteSubmissionAsync(token.access_token, appId, submission);
                throw;
            }
        }

        

        private static async Task StartFlightSubmission(AuthenticationResult token, string appId, string flightName, string filePath)
        {
            SubmissionService submissionService = new SubmissionService();
            var appInfo = await submissionService.GetFlightsAsync(token.access_token, appId, flightName);

            if (appInfo.pendingFlightSubmission != null)
            {
                Console.WriteLine("Submission already in progresss");
                throw new Exception();
            }

            FlightSubmission submission = await submissionService.CreateNewSubmissionAsync(token.access_token, appId, appInfo.flightId);
            Console.WriteLine("Submission created");
            try
            {
                UpdateSubmission(submission, filePath);
                submission = await submissionService.UpdateSubmissionAsync(token.access_token, appId, appInfo.flightId, submission);
                Console.WriteLine("Submission updated with package");

                //await Task.Delay(TimeSpan.FromSeconds(20));
                await submissionService.UploadFileAsync(submission.fileUploadUrl, filePath);
                Console.WriteLine("Appxupload uploaded");

                SubmissionStatus status = await submissionService.CommitSubmissionAsync(token.access_token, appId, appInfo.flightId, submission);
                bool released = CheckSubmissionStatus(submission.targetPublishMode, status, false);
                while (!released)
                {
                    await Task.Delay(TimeSpan.FromSeconds(10));
                    status = await submissionService.GetSubmissionStatusAsync(token.access_token, appId, appInfo.flightId, submission);
                    released = CheckSubmissionStatus(submission.targetPublishMode, status, true);
                }
                Console.WriteLine("Submission commited");
            }
            catch
            {
                await submissionService.DeleteSubmissionAsync(token.access_token, appId, appInfo.flightId, submission);
                throw;
            }
        }


        private static void UpdateSubmission(Submission submission, string filePath)
        {
            var appxUtils = new AppxUtils();
            var newVersion = appxUtils.AnalyzeAppxUpload(filePath);


            foreach (var package in submission.applicationPackages)
            {
                //not need the package version but the min target version of windows
                //var currentVersion = new Version(package.version);
                //if (currentVersion == newVersion)
                //{
                //    package.fileStatus = "PendingDelete";
                //}
            }

            ApplicationPackage highestPackage = null;
            foreach (var package in submission.applicationPackages)
            {
                if (highestPackage == null)
                    highestPackage = package;
                else
                {
                    var currentPackage = new Version(highestPackage.version);
                    var newPackage = new Version(package.version);
                    if (newPackage > currentPackage)
                        highestPackage = package;
                }
            }
            if (highestPackage != null)
            {
                highestPackage.fileStatus = "PendingDelete";
            }

            submission.applicationPackages.Insert(0, new ApplicationPackage
            {
                fileStatus = "PendingUpload",
                fileName = Path.GetFileName(filePath)
            });

        }

        private static void UpdateSubmission(FlightSubmission submission, string filePath)
        {
            var appxUtils = new AppxUtils();
            var newVersion = appxUtils.AnalyzeAppxUpload(filePath);

            foreach (var package in submission.flightPackages)
            {
                //not need the package version but the min target version of windows
                //var currentVersion = new Version(package.version);
                //if (currentVersion == newVersion)
                //{
                //    package.fileStatus = "PendingDelete";
                //}
            }

            ApplicationPackage highestPackage = null;
            foreach (var package in submission.flightPackages)
            {
                if (highestPackage == null)
                    highestPackage = package;
                else
                {
                    var currentPackage = new Version(highestPackage.version);
                    var newPackage = new Version(package.version);
                    if (newPackage > currentPackage)
                        highestPackage = package;
                }
            }
            if (highestPackage != null)
            {
                highestPackage.fileStatus = "PendingDelete";
            }

            submission.flightPackages.Insert(0, new ApplicationPackage
            {
                fileStatus = "PendingUpload",
                fileName = Path.GetFileName(filePath)
            });
        }

        private static bool CheckSubmissionStatus(string targetPublishMode, SubmissionStatus status, bool waitForRelease)
        {
            if (status.status.EndsWith("Failed") || status.status == "Canceled")
                throw new Exception("Submission Failed");
            switch (status.status)
            {
                case "CommitStarted":
                    return false;
                case "CommitFailed":
                    throw new Exception("Submission Commit Failed");
                case "PreProcessing":
                    return waitForRelease ? false : true;
                case "Published":
                    return true;
                case "Release":
                    return targetPublishMode == "Immediate" ? true : false;
                default:
                    return false;
            }
        }

    }
}
