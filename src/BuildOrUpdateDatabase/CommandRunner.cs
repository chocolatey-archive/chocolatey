namespace BuildOrUpdateDatabase
{
    using System.Diagnostics;
    using System.IO;
    using System.Reflection;

    public class CommandRunner
    {
        public static int run(string process, string arguments, bool wait_for_exit)
        {
            int exit_code = -1;
            ProcessStartInfo psi = new ProcessStartInfo(Path.GetFullPath(process), arguments)
                                       {
                                           WorkingDirectory = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location),
                                           UseShellExecute = false,
                                           RedirectStandardOutput = false,
                                           CreateNoWindow = false
                                       };

            using (Process p = new Process())
            {
                p.StartInfo = psi;
                p.Start();
                if (wait_for_exit)
                {
                    p.WaitForExit();
                }
                exit_code = p.ExitCode;
            }

            return exit_code;
        }
    }
}