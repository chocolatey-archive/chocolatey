<%@ Page Language="C#" inherits="Chocolatey.Web.Actions.Home.Home" enableviewstate="false" %>
<%@ Import Namespace="Chocolatey.Web.Actions.Home" %>
<%@ Import Namespace="FubuMVC.Core.UI" %>
<%@ Import Namespace="Chocolatey.Web.Actions.Package" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="html_form" runat="server">
    <div>
    HI!
    <% = HomeOutput.Name %>
    <% = this.LinkTo(new PackageListInput()).Text("some") %>
    </div>
    </form>
</body>
</html>
