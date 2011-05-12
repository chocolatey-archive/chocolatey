<%@ page language="C#" inherits="Chocolatey.Web.Actions.Home.Home" masterpagefile="~/Site.Master"
    enableviewstate="false" %>

<%@ import namespace="Chocolatey.Web.Actions.Home" %>
<%@ import namespace="Chocolatey.Web.Actions.Package" %>
<asp:content id="header" contentplaceholderid="head" runat="server">
    <title>Let's Get Chocolatey! Like apt-get, but for Windows!</title>
</asp:content>
<asp:content id="main" contentplaceholderid="content" runat="server">
    <div>
        HI!
        <% = HomeResponse.Name %>
        <% = this.LinkTo(new PackageListInput()).Text("some") %>
    </div>
</asp:content>
