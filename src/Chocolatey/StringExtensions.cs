namespace Chocolatey
{
    public static class StringExtensions
    {
        public static string FormatWith(this string item, params object[] args)
        {
            return string.Format(item, args);
        }
    }
}