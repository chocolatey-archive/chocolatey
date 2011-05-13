<%@ page language="C#" inherits="Chocolatey.Web.Actions.Package.List" masterpagefile="~/Site.Master" %>
<%@ import namespace="Chocolatey.Web.Actions.Package" %>
<%@ Import Namespace="Chocolatey.Web.Actions.Package.Edit" %>
<asp:content id="header" contentplaceholderid="head" runat="server">
    <title>Chocolatey Packages, yo!</title>
</asp:content>
<asp:content id="main" contentplaceholderid="content" runat="server">
    <div>
        Packages
    </div>
    <div>
        <ul>
            <% foreach (var package in Model.Packages)
               { %>
            <li>
                <%=this.LinkTo(new PackageEditRequest(){Id = package.Id}).Text(package.Name) %> [delete?]
            </li>
            <% } %>
        </ul>
    </div>
</asp:content>
