
    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetNuspec]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetNuspec]

    create table dbo.[NugetNuspec] (
        NugetNuspecID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       NugetId VarChar(255) null,
       Name VarChar(255) null,
       Version VarChar(255) null,
       Authors VarChar(255) null,
       Owners VarChar(255) null,
       Summary VarChar(255) null,
       Description VarChar(255) null,
       ProjectUrl VarChar(255) null,
       Tags VarChar(255) null,
       LicenseUrl VarChar(255) null,
       IconUrl VarChar(255) null,
       primary key (NugetNuspecID)
    )
