# dotnet-bulk-package-updater

A Bash script designed to streamline the process of updating NuGet packages in .NET projects.

## Features

- Update packages in multiple .csproj files at once
- Selectively update specific packages
- Include pre-release package versions in updates
- Provide summary of the update process

## Prerequisites

To use this script, you need:

- Bash shell (Unix/Linux/macOS or Windows with WSL/Git Bash)
- [.NET SDK](https://dotnet.microsoft.com/en-us/download)

## Installation

1. Clone the repository or download the [script](dotnet-bulk-package-updater.sh).
2. Make the script executable:
   
   ```bash
   chmod +x dotnet-bulk-package-updater.sh
   ```

3. To ensure that the line endings in the script file are in Unix format, follow the [dos2unix](https://dos2unix.sourceforge.io/) command on the script:

   ```bash
   dos2unix dotnet-bulk-package-updater.sh
   ```
   
4. Place the script in the root directory of your .NET solution to ensure it can find .csproj files recursively.

## Usage

To use the script, you have the following options:

```bash
./dotnet-bulk-package-updater.sh [-p <projects>] [-k <packages>] [-r]
```

- `-p`: Specify one or multiple project files separated by semicolons (`;`). If omitted, all .csproj files will be considered.
- `-k`: Specify one or multiple packages separated by semicolons (`;`). If omitted, all outdated packages will be updated.
- `-r`: Include pre-release versions in the update process.

### Examples

- Update all packages in all projects:

  ```bash
  ./dotnet-bulk-package-updater.sh
  ```

- Include pre-release versions in updates:

  ```bash
  ./dotnet-bulk-package-updater.sh -r
  ```

- Update all packages in a specific project:

  ```bash
  ./dotnet-bulk-package-updater.sh -p "MyProject.csproj"
  ```
  
- Update all packages in specific projects:

  ```bash
  ./dotnet-bulk-package-updater.sh -p "MyProject.csproj;MyProject.Tests.csproj"
  ```

- Update a specific package in all projects:

  ```bash
  ./dotnet-bulk-package-updater.sh -k "Newtonsoft.Json"
  ```

- Update specific packages in all projects:

  ```bash
  ./dotnet-bulk-package-updater.sh -k "Dapper;Newtonsoft.Json"
  ```

- Update specific packages in a specific project:

  ```bash
  ./dotnet-bulk-package-updater.sh -p "MyProject.csproj" -k "Dapper;Newtonsoft.Json"
  ```

- Update specific packages in a specific project including pre-release versions:

  ```bash
  ./dotnet-bulk-package-updater.sh -p "MyProject.csproj" -k "Dapper;Newtonsoft.Json" -r
  ```

### Output

The script provides a succinct output for each action it performs. Upon completion, it presents a summary like the following:

```text
3 packages updated, 1 project not found, 2 packages not found, 1 package not outdated
```

## Detailed script walkthrough

### Script structure

1. **Shebang declaration and temporary file**: At the beginning of the script, the shebang (`#!/bin/bash`) is defined, which informs the system that this script should be executed in a Bash environment. Right after, a temporary file is created to track the number of updated packages.

2. **Variables**: A variable `include_prerelease` is defined to determine whether or not to include pre-release versions of packages in the update process.

3. **Function `update_package`**: This function is responsible for updating a specific package within a .csproj file. It accepts as arguments the path to the .csproj file, the package name, version, and a flag indicating whether to consider pre-release versions.

4. **Option parsing**: Option parsing is performed using the getopts construct. The options are `-p` to specify projects, `-k` for packages, and `-r` to include pre-release versions. These options allow users to specify exactly which projects and packages should be updated.

5. **Counters**: Several counters are initialized to track the number of not found projects and packages, and non-outdated packages.

6. **Project selection**: The case where no specific projects have been provided as input is handled. In this case, the script will consider all .csproj files.

7. **Splitting inputs**: The inputs for projects and packages are split into arrays to facilitate processing.

8. **Main loop**: The script loops through each specified project. For each project, it checks for .csproj files and then proceeds to loop through them.

9. **Package updating**: For each project file found, the script updates all outdated packages if no individual packages have been specified. If specific packages have been provided, it updates only those.

10. **Summary and cleanup**: At the end, the script reads the total count of updated packages from the temporary file, then removes the temporary file and provides a summary of the operation, including counters for not found projects and packages, and non-outdated packages.

### Additional functions

- **Function `pluralize`**: A small utility function that pluralizes a word based on the count provided, to make the output more readable.

- **Construction of summary message**: A summary message is constructed that lists the number of updated packages, the number of projects and packages not found, and the number of non-outdated packages.

### Error handling considerations

- **Success operation check**: After each attempt to update a package, the script checks if the operation succeeded and increments the counter accordingly. If it fails, it provides an error message.

- **Handling of not found files and non-outdated packages**: If a project script or a package is not found, or if a package is not outdated, the script handles these cases without interrupting execution, providing an informative message.
    
## Troubleshooting

If you encounter any issues while running the script, ensure that:

- You have the correct permissions to modify the .csproj files.
- The .NET Core SDK is properly installed and the dotnet CLI is accessible from your terminal.
- You are running the script in the correct directory or providing the right paths to your .csproj files.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
