using StoreSubmissionLib;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
            string appId = "9nblggh1rmqv".ToUpper();
            string flightId = "";
            string filePath = "C:\\Dave\\ATC.Navigation_1.1.54.0_x86_x64_arm_bundle.appxupload";
#else
            string tenantId = args[0];
            string clientId = args[1];
            string clientSecret = args[2];
            string appId = args[3];
            string flightId = args[4];
            string filePath = args[5];
#endif
            if (!File.Exists(filePath))
            {
                Console.WriteLine($"file: {filePath} does not exists");
                return;
            }

            if (flightId == "0")
                flightId = string.Empty;

            UploadPackageAsync(tenantId, clientId, clientSecret, appId, flightId, filePath).Wait();
        }

        static async Task UploadPackageAsync(string tenantId, string clientId, string clientSecret, string appId, string flightId, string filePath)
        {
            SubmissionService submissionService = new SubmissionService();
            var token = await submissionService.GetAccessToken(tenantId, clientId, clientSecret);
            Console.WriteLine("Access token aquired");

            if (string.IsNullOrEmpty(flightId))
            {
                await StartNonFlightSubmission(token, appId, filePath);
            }
            else
            {
                await StartFlightSubmission(token, appId, flightId, filePath);
            }
        }

        private static async Task StartNonFlightSubmission(AuthenticationResult token, string appId, string filePath)
        {
            SubmissionService submissionService = new SubmissionService();
            var appInfo = await submissionService.GetAppAsync(token.access_token, appId);

            if (appInfo.pendingApplicationSubmission != null)
            {
                Console.WriteLine("Submission already in progresss");
                return;
            }

            Submission submission = await submissionService.CreateNewSubmissionAsync(token.access_token, appId);
            Console.WriteLine("Submission created");

            UpdateSubmission(submission, filePath);
            submission = await submissionService.UpdateSubmissionAsync(token.access_token, appId, submission);
            Console.WriteLine("Submission updated with package");

            await submissionService.UploadFileAsync(submission.fileUploadUrl, filePath);
            Console.WriteLine("Appxupload uploaded");

            await submissionService.CommitSubmissionAsync(token.access_token, appId, submission);
            Console.WriteLine("Submission commited");
        }

        private static async Task StartFlightSubmission(AuthenticationResult token, string appId, string flightId, string filePath)
        {
            SubmissionService submissionService = new SubmissionService();
            var appInfo = await submissionService.GetAppAsync(token.access_token, appId, flightId);

            if (appInfo.pendingApplicationSubmission != null)
            {
                Console.WriteLine("Submission already in progresss");
                return;
            }

            Submission submission = await submissionService.CreateNewSubmissionAsync(token.access_token, appId, flightId);
            Console.WriteLine("Submission created");

            UpdateSubmission(submission, filePath);
            submission = await submissionService.UpdateSubmissionAsync(token.access_token, appId, flightId, submission);
            Console.WriteLine("Submission updated with package");

            await submissionService.UploadFileAsync(submission.fileUploadUrl, filePath);
            Console.WriteLine("Appxupload uploaded");

            await submissionService.CommitSubmissionAsync(token.access_token, appId, flightId, submission);
            Console.WriteLine("Submission commited");
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

            Applicationpackage highestPackage = null;
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

            submission.applicationPackages.Insert(0, new Applicationpackage
            {
                fileStatus = "PendingUpload",
                fileName = Path.GetFileName(filePath)
            });
        }
    }
}
