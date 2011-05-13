<%@ page title="" language="C#" masterpagefile="~/Site.Master" autoeventwireup="true" inherits="Chocolatey.Web.Actions.Package.Edit.Edit" %>
<%@ import namespace="Chocolatey.Web.Actions.Package.Edit" %>
<asp:content id="Content1" contentplaceholderid="head" runat="server">
    <title>Edit A Package</title>
</asp:content>
<asp:content id="Content2" contentplaceholderid="content" runat="server">
    <div>
        <% = this.FormFor(new PackageEditSubmit {Id = Model.Package.Id})  %>
        <fieldset>
            <ul>
                <% = this.InputFor(p => p.Package.NugetId) %>
                <% = this.InputFor(p => p.Package.Name) %>
                <% = this.InputFor(p => p.Package.Summary) %>
                <% = this.InputFor(p => p.Package.Description) %>
            </ul>
        </fieldset>
        <input type="submit" value="Submit" />
        <% = this.EndForm() %>
    </div>
</asp:content>
