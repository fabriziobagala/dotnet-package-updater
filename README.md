# dotnet-bulk-package-updater

A Bash script designed to streamline the process of updating NuGet packages in .NET projects. This tool allows developers to update all NuGet packages across multiple .csproj files or selectively target specific packages, all from the command line.

## Features

<!-- - **Bulk Updates**: Update all NuGet packages in a project or across multiple projects with a single command.
- **Selective Updates**: Specify which packages to update, avoiding the need to update all packages unnecessarily.
- **Versatile Searching**: Target project files with custom search patterns or use the default to find all `.csproj` files in the directory tree.
- **Silent Operation**: Perform updates quietly in the background, providing concise and clear output upon completion or when errors occur.
- **Summary Report**: Get a report of the update process, including the number of packages updated and lists of not found or not outdated packages.
-->

- Bulk updating of all NuGet packages within project files.
- Targeted updating for specific NuGet packages.
- Search functionality for .csproj files using customizable patterns.
- Quiet operation with informative output.
- Summary report of update results.

## Prerequisites

To use this script, you need:

- A Unix-like environment with Bash installed.
- [dotnet CLI](https://dotnet.microsoft.com/en-us/download) installed and accessible from the command line.

## Installation

1. Clone the repository or download the [script](dotnet-bulk-package-updater.sh).
2. Make the script executable:
   
   ```bash
   chmod +x dotnet-bulk-package-updater.sh
   ```
3. Place the script in the root directory of your .NET solution to ensure it can find .csproj files recursively.

## Usage

Execute the script with the following command structure:

```bash
./dotnet-bulk-package-updater.sh [options]
```

### Options

- `-p`: Specify the project(s) to update. You can list multiple projects separated by a semicolon `;`.
- `-k`: Specify the package(s) to update. You can list multiple packages separated by a semicolon `;`.

### Examples

- Update all packages in all projects:

  ```bash
  ./dotnet-bulk-package-updater.sh
  ```

- Update all packages in a specific project:

  ```bash
  ./dotnet-bulk-package-updater.sh -p "MyProject.csproj"
  ```
  
- Update all packages in multiple specific projects:

  ```bash
  ./dotnet-bulk-package-updater.sh -p "MyProject.csproj;MyProject.Tests.csproj"
  ```

- Update a specific package in all projects:

  ```bash
  ./dotnet-bulk-package-updater.sh -k "Newtonsoft.Json"
  ```

- Update multiple specific packages in all projects:

  ```bash
  ./dotnet-bulk-package-updater.sh -k "Dapper;Newtonsoft.Json"
  ```

- Update multiple specific packages in a specific project:

  ```bash
  ./dotnet-bulk-package-updater.sh -p "MyProject.csproj" -k "Dapper;Newtonsoft.Json"
  ```

### Output

The script provides a succinct output for each action it performs. Upon completion, it presents a summary like the following:

```text
3 packages updated, 1 project not found, 2 packages not found, 1 package not outdated
```

## Detailed Script Walkthrough

Below is a section-by-section breakdown of the `dotnet-bulk-package-updater` script:

### Temporary file management

- A temporary file is initialized to keep a count of the number of successfully updated packages.

### Function definitions

- The `update_package` function is the workhorse of the script. It takes in three parameters: the path to a `.csproj` file, the name of a NuGet package, and the desired version to update to. It prints update attempts and outcomes to the console and increments the package update count upon success.

### Option parsing

- The script parses command-line options `-p` (project files) and `-k` (packages) to tailor the update process. If neither is provided, it defaults to updating all `.csproj` files.

### Input handling

- If no specific projects or packages are provided, all `.csproj` files in the directory tree are targeted.
- The script converts semicolon-separated strings for projects and packages into arrays for easier manipulation.

### Main update logic

- The script loops through each specified project file and performs updates. If no specific packages are defined, it updates all outdated packages found within a project.
  
### Update execution

- Before attempting an update, it checks if a package is outdated to avoid unnecessary operations.
- The `update_package` function is called with the necessary parameters if an update is deemed required.

### Summary and cleanup

- After processing all updates, the script reads the final count of updated packages from the temporary file and then removes the file.
- A summary message is dynamically constructed to reflect the count of updated packages, and the number of projects and packages that were not found or were already up-to-date.

### Pluralization utility

- The `pluralize` function is a small utility to ensure proper grammar in the summary by pluralizing words based on their count.

Each section is integral to ensuring the script runs smoothly and provides the user with a clear and concise output, making package management in .NET projects much simpler and more automated.

## Troubleshooting

If you encounter any issues while running the script, ensure that:

- You have the correct permissions to modify the .csproj files.
- The .NET Core SDK is properly installed and the dotnet CLI is accessible from your terminal.
- You are running the script in the correct directory or providing the right paths to your .csproj files.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
