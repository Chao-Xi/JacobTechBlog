var target = Argument("target", "Default");

var projectNames = "HelloWorld";
var solution = "./HelloWorld.sln";
var configuration = Argument<string>("configuration", "Release");
var framework = Argument<string>("framework", "netcoreapp2.0");

class DeployableProject
{
    public string ProjectName { get; set; }
    public string ProjectFilePath { get; set; }
    public string DistDirectory { get; set; }
}

List<DeployableProject> deployableProjects = new List<DeployableProject>();

Task("Setup")
    .Does(() =>
    {
        foreach (var projectName in projectNames.Split(';'))
        {
            deployableProjects.Add(new DeployableProject{
                ProjectName = projectName,
                ProjectFilePath = "./" + projectName + "/" + projectName + ".csproj",
                DistDirectory = "./artifacts/" + projectName + "/"
            });
        }
    });

Task("Clean")
    .IsDependentOn("Setup")
    .Does(() =>
    {
        Information("Cleaning Binary folders");
        CleanDirectories("./**/bin");
        CleanDirectories("./**/obj");
        CleanDirectories("./artifacts");
        CleanDirectories("./TestResults");
    });

Task("Restore")
    .IsDependentOn("Clean")
    .Does(() =>
    {
        DotNetCoreRestore();
    });

Task("Build")
    .IsDependentOn("Restore")
    .Does(() =>
    {
        foreach(var deployableProject in deployableProjects)
        {
            DotNetCoreBuild(deployableProject.ProjectFilePath, new DotNetCoreBuildSettings
            {
                Framework = framework,
                Configuration = configuration,
            });
        }
    });

Task("Publish")
    .IsDependentOn("Build")  
    .Does(() =>
    {
        foreach(var deployableProject in deployableProjects)
        {
            var settings = new DotNetCorePublishSettings
            {
                Framework = framework,
                Configuration = configuration,
                OutputDirectory = deployableProject.DistDirectory
            };

            DotNetCorePublish(deployableProject.ProjectFilePath, settings);
        }
    });


Task("Default")
    .IsDependentOn("Publish");

RunTarget(target);