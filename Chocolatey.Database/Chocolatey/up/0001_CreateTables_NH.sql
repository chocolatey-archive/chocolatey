
    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK61AD9690C838F43A]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageAuthor]'))
alter table dbo.[NugetPackageAuthor]  drop constraint FK61AD9690C838F43A


    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK740A391EC838F43A]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageDependency]'))
alter table dbo.[NugetPackageDependency]  drop constraint FK740A391EC838F43A


    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK1B887BB6C838F43A]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageOwner]'))
alter table dbo.[NugetPackageOwner]  drop constraint FK1B887BB6C838F43A


    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK79916495C838F43A]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageTag]'))
alter table dbo.[NugetPackageTag]  drop constraint FK79916495C838F43A


    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageAuthor]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageAuthor]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageDependency]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageDependency]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageOwner]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageOwner]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackage]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackage]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageTag]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageTag]

    create table dbo.[NugetPackageAuthor] (
        NugetPackageAuthorID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       Name VarChar(255) null,
       NugetPackage_id BIGINT null,
       primary key (NugetPackageAuthorID)
    )

    create table dbo.[NugetPackageDependency] (
        NugetPackageDependencyID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       Name VarChar(255) null,
       Version VarChar(255) null,
       NugetPackage_id BIGINT null,
       primary key (NugetPackageDependencyID)
    )

    create table dbo.[NugetPackageOwner] (
        NugetPackageOwnerID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       Name VarChar(255) null,
       NugetPackage_id BIGINT null,
       primary key (NugetPackageOwnerID)
    )

    create table dbo.[NugetPackage] (
        NugetPackageID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       NugetId VarChar(255) null,
       Name VarChar(255) null,
       Version VarChar(255) null,
       Summary VarChar(255) null,
       Description VarChar(255) null,
       ProjectUrl VarChar(255) null,
       LicenseUrl VarChar(255) null,
       IconUrl VarChar(255) null,
       primary key (NugetPackageID)
    )

    create table dbo.[NugetPackageTag] (
        NugetPackageTagID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       Name VarChar(255) null,
       NugetPackage_id BIGINT null,
       primary key (NugetPackageTagID)
    )

    alter table dbo.[NugetPackageAuthor] 
        add constraint FK61AD9690C838F43A 
        foreign key (NugetPackage_id) 
        references dbo.[NugetPackage]

    alter table dbo.[NugetPackageDependency] 
        add constraint FK740A391EC838F43A 
        foreign key (NugetPackage_id) 
        references dbo.[NugetPackage]

    alter table dbo.[NugetPackageOwner] 
        add constraint FK1B887BB6C838F43A 
        foreign key (NugetPackage_id) 
        references dbo.[NugetPackage]

    alter table dbo.[NugetPackageTag] 
        add constraint FK79916495C838F43A 
        foreign key (NugetPackage_id) 
        references dbo.[NugetPackage]
