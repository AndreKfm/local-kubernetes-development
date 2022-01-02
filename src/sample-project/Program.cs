/// <summary>
/// Demo application to be run under local Kubernetes environment.
/// Will output each second an incremented counter and the current 
/// operating system the application is running on - if everything 
/// is ok the console should show the following output 
/// 
/// Running directly under Windows (Windows version might differ)
///
///     Sample project - running under Microsoft Windows NT 1?????0 - 1
///     Sample project - running under Microsoft Windows NT 1?????0 - 2
///     Sample project - running under Microsoft Windows NT 1?????0 - 3
///     Sample project - running under Microsoft Windows NT 1?????0 - 4
///     Sample project - running under Microsoft Windows NT 1?????0 - 5
///     Sample project - running under Microsoft Windows NT 1?????0 - 6
///
///
/// running underKubernetes the output should be similar to
/// 
///     Sample project - running under Unix 5.10.60.1 - 1
///     Sample project - running under Unix 5.10.60.1 - 2
///     Sample project - running under Unix 5.10.60.1 - 3
///     Sample project - running under Unix 5.10.60.1 - 4
///     Sample project - running under Unix 5.10.60.1 - 5
///     Sample project - running under Unix 5.10.60.1 - 6
///
/// </summary>


CancellationTokenSource source = new ();
Console.WriteLine("Enter any key + CR to stop or CTRL+C");

Console.CancelKeyPress += delegate {
    source.Cancel ();
    Environment.Exit (0);
};

var token = source.Token;
var task = Task.Run(async() => await LoopAndOutputCounterTillCancellation(token));

try
{
    Console.ReadLine();
    source.Cancel();
    task.Wait();
}
catch (TaskCanceledException) { }
catch (Exception e) { Console.Error.WriteLine($"Exception occured {e.Message }"); }


Console.WriteLine("Finished");




async Task LoopAndOutputCounterTillCancellation(CancellationToken token)
{
    try
    {
        int counter = 0;
        while (token.IsCancellationRequested == false)
        {
            Console.WriteLine($"Sample project - running under {Environment.OSVersion.VersionString} - {++counter}");
            await Task.Delay(1000, token);
        }
    }
    catch (TaskCanceledException) { }

}