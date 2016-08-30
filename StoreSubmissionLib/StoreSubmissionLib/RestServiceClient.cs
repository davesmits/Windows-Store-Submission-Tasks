using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace StoreSubmissionLib
{
    public class RestServiceClient
    {
        private string _token;

        public RestServiceClient(string token)
        {
            _token = token;
        }

        public Task<TResponse> SendRequestAsync<TRequest, TResponse>(HttpMethod method, Uri uri, TRequest content)
        {
            string json = JsonConvert.SerializeObject(content);
            HttpContent httpContent = new StringContent(json);
            httpContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/json");
            return SendRequestAsync<TResponse>(method, uri, httpContent);
        }

        public async Task<TResponse> SendRequestAsync<TResponse>(HttpMethod method, Uri uri, HttpContent content = null)
        {
            var response = await SendRequestAsync(method, uri, content).ConfigureAwait(false);
            var json = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<TResponse>(json);
        }

        public async Task<HttpResponseMessage> SendRequestAsync(HttpMethod method, Uri uri, HttpContent content = null)
        {
            using (var client = new HttpClient())
            {
                HttpRequestMessage requestMessage = new HttpRequestMessage(method, uri);
                if (!string.IsNullOrEmpty(_token))
                    requestMessage.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("bearer", _token);
                requestMessage.Content = content;
                var responseMessage = await client.SendAsync(requestMessage).ConfigureAwait(false);

                if (!responseMessage.IsSuccessStatusCode)
                {
                    string error = await responseMessage.Content.ReadAsStringAsync();
                    Console.WriteLine($"error: {error}");
                }

                responseMessage.EnsureSuccessStatusCode();
                return responseMessage;
            }
        }
    }
}
