namespace BuildOrUpdateDatabase
{
    using System;
    using System.Configuration;
    using System.IO;
    using System.Reflection;
    using System.Text;
    using Chocolatey.Infrastructure.Persistence.Conventions;
    using Chocolatey.Mappings;
    using NHibernate;
    using NHibernate.Tool.hbm2ddl;
    using Configuration = NHibernate.Cfg.Configuration;

    internal class Program
    {
        private static string ROUNDHOUSE_EXE;
        private static string DB_SERVER;
        private static string DB_NAME;
        private static string PATH_TO_SCRIPTS;
        private static string NAME_OF_SCRIPT;
        private static string NAME_OF_UPDATE_SCRIPT;
        private static bool INITIAL_DEVELOPMENT;


        private static void Main(string[] args)
        {
            try
            {
                ROUNDHOUSE_EXE = ConfigurationManager.AppSettings["roundhouse_exe"];
                DB_SERVER = ConfigurationManager.AppSettings["db_server"];
                DB_NAME = ConfigurationManager.AppSettings["db_name"];
                PATH_TO_SCRIPTS = ConfigurationManager.AppSettings["path_to_scripts"];
                NAME_OF_SCRIPT = ConfigurationManager.AppSettings["name_of_script"];
                NAME_OF_UPDATE_SCRIPT = ConfigurationManager.AppSettings["name_of_update_script"];
                INITIAL_DEVELOPMENT = ConfigurationManager.AppSettings["has_this_installed_into_prod"] == "false";

                run_roundhouse_nhibernate();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                Console.ReadKey();
            }
        }

        private static void run_roundhouse_nhibernate()
        {
            if (INITIAL_DEVELOPMENT)
            {
                run_initial_database_setup();
            }
            else
            {
                run_maintenance_database_setup();
            }
        }

        // initial database setup

        public static void run_initial_database_setup()
        {
            create_the_database(ROUNDHOUSE_EXE, DB_SERVER, DB_NAME);
            build_database_schema(DB_SERVER, DB_NAME);
            run_roundhouse_drop_create(ROUNDHOUSE_EXE, DB_SERVER, DB_NAME, PATH_TO_SCRIPTS);
        }

        private static void create_the_database(string roundhouse_exe, string server_name, string db_name)
        {
            CommandRunner.run(roundhouse_exe, string.Format("/s={0} /db={1} /f={2} /silent /simple", server_name, db_name, Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)), true);
        }

        private static void build_database_schema(string db_server, string db_name)
        {
            //Assembly mapping_assembly = Assembly.LoadFile(Path.GetFullPath(MAPPINGS_ASSEMBLY));
            //Assembly convention_assembly = Assembly.LoadFile(Path.GetFullPath(CONVENTIONS_ASSEMBLY));

            //ISessionFactory sf = NHibernateSessionFactory.build_session_factory(db_server, db_name,mapping_assembly,convention_assembly, build_schema);
            ISessionFactory sf = NHibernateSessionFactory.build_session_factory<NugetNuspecMap, PrimaryKeyConvention>(db_server, db_name, build_schema);
        }

        private static void build_schema(Configuration cfg)
        {
            SchemaExport s = new SchemaExport(cfg);
            s.SetOutputFile(Path.Combine(PATH_TO_SCRIPTS, Path.Combine("Up", NAME_OF_SCRIPT)));
            s.Create(true, false);
        }

        private static void run_roundhouse_drop_create(string roundhouse_exe, string server_name, string db_name, string path_to_scripts)
        {
            CommandRunner.run(roundhouse_exe, string.Format("/s={0} /db={1} /f=. /silent /drop", server_name, db_name), true);
            CommandRunner.run(roundhouse_exe, string.Format("/s={0} /db={1} /f={2} /silent /simple", server_name, db_name, path_to_scripts), true);
        }

        // maintenance database setup

        public static void run_maintenance_database_setup()
        {
            //restore_the_database(ROUNDHOUSE_EXE, DB_SERVER, DB_NAME, PATH_TO_RESTORE);
            upgrade_database_schema(DB_SERVER, DB_NAME);
            run_roundhouse_updates(ROUNDHOUSE_EXE, DB_SERVER, DB_NAME, PATH_TO_SCRIPTS);
        }

        private static void restore_the_database(string roundhouse_exe, string server_name, string db_name, string path_to_restore)
        {
            CommandRunner.run(roundhouse_exe, string.Format("/s={0} /db={1} /f=. /silent /restore /restorefrompath=\"{2}\"", server_name, db_name, path_to_restore), true);
        }

        private static void upgrade_database_schema(string db_server, string db_name)
        {
            ISessionFactory sf = NHibernateSessionFactory.build_session_factory<NugetNuspecMap, PrimaryKeyConvention>(db_server, db_name, update_schema);
        }

        public static void update_schema(Configuration cfg)
        {
            SchemaUpdate s = new SchemaUpdate(cfg);
            StringBuilder sb = new StringBuilder();
            s.Execute(x => sb.Append(x), false);
            string updateScriptFileName = Path.Combine(PATH_TO_SCRIPTS, Path.Combine("up", NAME_OF_UPDATE_SCRIPT));
            if (File.Exists(updateScriptFileName)) { File.Delete(updateScriptFileName); }
            File.WriteAllText(updateScriptFileName, sb.ToString());
        }

        private static void run_roundhouse_updates(string roundhouse_exe, string server_name, string db_name, string path_to_scripts)
        {
            CommandRunner.run(roundhouse_exe, string.Format("/s={0} /db={1} /f={2} /silent", server_name, db_name, path_to_scripts), true);
        }
    }
}