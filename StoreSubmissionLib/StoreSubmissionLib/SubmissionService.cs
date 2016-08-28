using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace StoreSubmissionLib
{
    public class SubmissionService
    {
        public async Task<AuthenticationResult> GetAccessToken(string tenantId, string clientId, string clientSecret)
        {
            using (HttpClient client = new HttpClient())
            {
                string url = $"https://login.microsoftonline.com/{tenantId}/oauth2/token";

                var dictionary = new Dictionary<string, string>();
                dictionary.Add("grant_type", "client_credentials");
                dictionary.Add("client_id", clientId);
                dictionary.Add("client_secret", clientSecret);
                dictionary.Add("resource", "https://manage.devcenter.microsoft.com");

                var content = new FormUrlEncodedContent(dictionary);
                var result = await client.PostAsync(new Uri(url), content);
                result.EnsureSuccessStatusCode();

                string json = await result.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<AuthenticationResult>(json);
            }
        }

        public Task<App> GetAppAsync(string token, string appId)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync<App>(HttpMethod.Get, new Uri(url));
        }

        public Task<App> GetAppAsync(string token, string appId, string flightId)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/flights/{flightId}";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync<App>(HttpMethod.Get, new Uri(url));
        }

        public Task<Submission> CreateNewSubmissionAsync(string token, string appId)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/submissions";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync<Submission>(HttpMethod.Post, new Uri(url));
        }

        public Task<Submission> CreateNewSubmissionAsync(string token, string appId, string flightId)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/flights/{flightId}/submissions";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync<Submission>(HttpMethod.Post, new Uri(url));
        }

        public Task<Submission> UpdateSubmissionAsync(string token, string appId, Submission submission)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/submissions/{submission.id}";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync<Submission, Submission>(HttpMethod.Put, new Uri(url), submission);
        }

        public Task<Submission> UpdateSubmissionAsync(string token, string appId, string flightId, Submission submission)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/flights/{flightId}/submissions/{submission.id}";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync<Submission, Submission>(HttpMethod.Put, new Uri(url), submission);
        }

        public Task DeleteSubmissionAsync(string token, string appId, Submission submission)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/submissions/{submission.id}";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync(HttpMethod.Delete, new Uri(url));
        }

        public Task CommitSubmissionAsync(string token, string appId, Submission submission)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/submissions/{submission.id}/commit";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync(HttpMethod.Post, new Uri(url));
        }

        public Task CommitSubmissionAsync(string token, string appId, string flightId, Submission submission)
        {
            string url = $"https://manage.devcenter.microsoft.com/v1.0/my/applications/{appId}/flights/{flightId}/submissions/{submission.id}/commit";
            var restClient = new RestServiceClient(token);
            return restClient.SendRequestAsync(HttpMethod.Post, new Uri(url));
        }


        public async Task UploadFileAsync(string targetUrl, string filePath)
        {
            //    $Body = [System.IO.File]::ReadAllBytes($file);
            //$Request = [System.Net.HttpWebRequest]::CreateHttp($url);
            //$Request.Method = 'PUT';
            //$Request.Headers.Add('x-ms-blob-type', 'BlockBlob')

            //$Request.ContentType = "application/octet-stream"
            //$Stream = $Request.GetRequestStream();
            //$Stream.Write($Body, 0, $Body.Length);
            //$Request.GetResponse();

            using (HttpClient client = new HttpClient())
            {
                using (var fileStream = new FileStream(filePath, FileMode.Open))
                {
                    var content = new System.Net.Http.StreamContent(fileStream);
                    content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/octet-stream");

                    HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Put, targetUrl);
                    request.Headers.Add("x-ms-blob-type", "BlockBlob");
                    request.Content = content;

                    var response = await client.SendAsync(request);
                    response.EnsureSuccessStatusCode();
                }
            }
        }

       

        
    }
}
