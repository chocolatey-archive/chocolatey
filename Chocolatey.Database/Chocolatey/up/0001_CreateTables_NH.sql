
    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK61AD96909E70D456]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageAuthor]'))
alter table dbo.[NugetPackageAuthor]  drop constraint FK61AD96909E70D456


    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK740A391E9E70D456]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageDependency]'))
alter table dbo.[NugetPackageDependency]  drop constraint FK740A391E9E70D456


    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK1B887BB69E70D456]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageOwner]'))
alter table dbo.[NugetPackageOwner]  drop constraint FK1B887BB69E70D456


    if exists (select 1 from sys.objects where object_id = OBJECT_ID(N'dbo.[FK799164959E70D456]') AND parent_object_id = OBJECT_ID('dbo.[NugetPackageTag]'))
alter table dbo.[NugetPackageTag]  drop constraint FK799164959E70D456


    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageAuthor]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageAuthor]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageDependency]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageDependency]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageOwner]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageOwner]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageSpecification]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageSpecification]

    if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[NugetPackageTag]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table dbo.[NugetPackageTag]

    create table dbo.[NugetPackageAuthor] (
        NugetPackageAuthorID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       Name VarChar(255) null,
       NugetPackageSpecification_id BIGINT null,
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
       NugetPackageSpecification_id BIGINT null,
       primary key (NugetPackageDependencyID)
    )

    create table dbo.[NugetPackageOwner] (
        NugetPackageOwnerID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       Name VarChar(255) null,
       NugetPackageSpecification_id BIGINT null,
       primary key (NugetPackageOwnerID)
    )

    create table dbo.[NugetPackageSpecification] (
        NugetPackageSpecificationID BIGINT IDENTITY NOT NULL,
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
       primary key (NugetPackageSpecificationID)
    )

    create table dbo.[NugetPackageTag] (
        NugetPackageTagID BIGINT IDENTITY NOT NULL,
       EnteredDate DATETIME null,
       ModifiedDate DATETIME null,
       EnteredByUser VarChar(255) null,
       ModifiedByUser VarChar(255) null,
       Name VarChar(255) null,
       NugetPackageSpecification_id BIGINT null,
       primary key (NugetPackageTagID)
    )

    alter table dbo.[NugetPackageAuthor] 
        add constraint FK61AD96909E70D456 
        foreign key (NugetPackageSpecification_id) 
        references dbo.[NugetPackageSpecification]

    alter table dbo.[NugetPackageDependency] 
        add constraint FK740A391E9E70D456 
        foreign key (NugetPackageSpecification_id) 
        references dbo.[NugetPackageSpecification]

    alter table dbo.[NugetPackageOwner] 
        add constraint FK1B887BB69E70D456 
        foreign key (NugetPackageSpecification_id) 
        references dbo.[NugetPackageSpecification]

    alter table dbo.[NugetPackageTag] 
        add constraint FK799164959E70D456 
        foreign key (NugetPackageSpecification_id) 
        references dbo.[NugetPackageSpecification]
