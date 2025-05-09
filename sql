[FunctionName("LoginFunction")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
    ILogger log)
{
    log.LogInformation("Processing login request.");

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    LoginRequest data = JsonConvert.DeserializeObject<LoginRequest>(requestBody);

    string userEmailID = data.EmailID;
    string userPassword = data.Password;
    string userType = data.UserType;
    int result;

    string connectionString = Environment.GetEnvironmentVariable("SqlConnectionString");

    using (SqlConnection con = new SqlConnection(connectionString))
    using (SqlCommand cmd = new SqlCommand("SELECT [dbo].ufn_ValidateLogin(@userEmailID,@userPassword,@customerType)", con))
    {
        cmd.Parameters.AddWithValue("@userEmailID", userEmailID);
        cmd.Parameters.AddWithValue("@userPassword", userPassword);
        cmd.Parameters.AddWithValue("@customerType", userType);

        try
        {
            con.Open();
            result = Convert.ToInt32(cmd.ExecuteScalar());
        }
        catch (Exception e)
        {
            log.LogError(e, "Exception occurred during login.");
            return new StatusCodeResult(StatusCodes.Status500InternalServerError);
        }
    }

    return new OkObjectResult(result);
}
