# dotnet-package-updater

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

1. Clone the repository or download the [script](dotnet-package-updater.sh).
2. Make the script executable:
   
   ```bash
   chmod +x dotnet-package-updater.sh
   ```

3. To ensure that the line endings in the script file are in Unix format, follow the [dos2unix](https://dos2unix.sourceforge.io/) command on the script:

   ```bash
   dos2unix dotnet-package-updater.sh
   ```
   
4. Place the script in the root directory of your .NET solution to ensure it can find .csproj files recursively.

## Usage

To use the script, you have the following options:

```bash
./dotnet-package-updater.sh [-p <projects>] [-k <packages>] [-r]
```

- `-p`: Specify one or multiple project files separated by semicolons (`;`). If omitted, all .csproj files will be considered.
- `-k`: Specify one or multiple packages separated by semicolons (`;`). If omitted, all outdated packages will be updated.
- `-r`: Include pre-release versions in the update process.

### Examples

- Update all packages in all projects:

  ```bash
  ./dotnet-package-updater.sh
  ```

- Include pre-release versions in updates:

  ```bash
  ./dotnet-package-updater.sh -r
  ```

- Update all packages in a specific project:

  ```bash
  ./dotnet-package-updater.sh -p "MyProject.csproj"
  ```
  
- Update all packages in specific projects:

  ```bash
  ./dotnet-package-updater.sh -p "MyProject.csproj;MyProject.Tests.csproj"
  ```

- Update a specific package in all projects:

  ```bash
  ./dotnet-package-updater.sh -k "Newtonsoft.Json"
  ```

- Update specific packages in all projects:

  ```bash
  ./dotnet-package-updater.sh -k "Dapper;Newtonsoft.Json"
  ```

- Update specific packages in a specific project:

  ```bash
  ./dotnet-package-updater.sh -p "MyProject.csproj" -k "Dapper;Newtonsoft.Json"
  ```

- Update specific packages in a specific project including pre-release versions:

  ```bash
  ./dotnet-package-updater.sh -p "MyProject.csproj" -k "Dapper;Newtonsoft.Json" -r
  ```

### Output

The script provides a succinct output for each action it performs. Upon completion, it presents a summary like the following:

```text
3 packages updated, 1 project not found, 2 packages not found, 1 package not outdated
```
    
## Troubleshooting

If you encounter any issues while running the script, ensure that:

- You have the correct permissions to modify the .csproj files.
- The .NET Core SDK is properly installed and the dotnet CLI is accessible from your terminal.
- You are running the script in the correct directory or providing the right paths to your .csproj files.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
