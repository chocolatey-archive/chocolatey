COMPILE_TARGET = ENV['config'].nil? ? "debug" : ENV['config']
require File.dirname(__FILE__) + "/build_support/BuildUtils.rb"

include FileTest
require 'albacore'
load "VERSION.txt"

RESULTS_DIR = "results"
PRODUCT = "chocolatey"
COPYRIGHT = 'Copyright 2011 Rob Reynolds. All rights reserved.';
COMMON_ASSEMBLY_INFO = 'src/CommonAssemblyInfo.cs';
CLR_TOOLS_VERSION = "v4.0.30319"

tc_build_number = ENV["BUILD_NUMBER"]
build_revision = tc_build_number || Time.new.strftime('5%H%M')
build_number = "#{BUILD_VERSION}.#{build_revision}"

props = { :stage => File.expand_path("build"), :artifacts => File.expand_path("artifacts") }

desc "**Default**, compiles and runs tests"
task :default => [:compile, :unit_test]

desc "Update the version information for the build"
assemblyinfo :version do |asm|
  asm_version = BUILD_VERSION + ".0"
  
  begin
    commit = `git log -1 --pretty=format:%H`
  rescue
    commit = "git unavailable"
  end
  puts "##teamcity[buildNumber '#{build_number}']" unless tc_build_number.nil?
  puts "Version: #{build_number}" if tc_build_number.nil?
  asm.trademark = commit
  asm.product_name = PRODUCT
  asm.description = build_number
  asm.version = asm_version
  asm.file_version = build_number
  asm.custom_attributes :AssemblyInformationalVersion => asm_version
  asm.copyright = COPYRIGHT
  asm.output_file = COMMON_ASSEMBLY_INFO
end

desc "Compiles the app"
task :compile => [:version] do
  MSBuildRunner.compile :compilemode => COMPILE_TARGET, :solutionfile => 'src/chocolatey.sln', :clrversion => CLR_TOOLS_VERSION
end

desc "Runs unit tests"
task :unit_test => :compile do
  runner = NUnitRunner.new :compilemode => COMPILE_TARGET, :source => 'src', :platform => 'x86', :results => RESULTS_DIR
  runner.executeTests ['chocolatey.Tests']
end