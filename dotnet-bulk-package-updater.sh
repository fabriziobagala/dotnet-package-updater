# Copyright (c) Fabrizio Bagalà. All rights reserved.
# Licensed under the MIT License.

#!/bin/bash

# Temporary file to keep track of the number of updated packages
count_file=$(mktemp)
echo 0 > "$count_file"

# Include prerelease packages or not
include_prerelease=""

# Function to update a specific package in a csproj file
update_package() {
  local csproj=$1
  local pkg=$2
  local version=$3
  local prerelease_flag=$4

  # Updating process message with package name in single quotes
  printf "Updating '%s' to version %s in %s... " "$pkg" "$version" "$csproj"

  # Attempt to update the package, including prerelease if specified
  if [ "$prerelease_flag" = "true" ]; then
    # Check for prerelease versions separately
    prerelease_version=$(dotnet list "$csproj" package --outdated --include-prerelease | grep "$pkg" | awk '{print $5}')
    if [ -n "$prerelease_version" ]; then
      version="$prerelease_version"
    fi
  fi
  
  # Update the package with the determined version
  if dotnet add "$csproj" package "$pkg" --version "$version" > /dev/null 2>&1; then
    printf "Completed!\n"
    echo $(( $(cat "$count_file") + 1 )) > "$count_file"
  else
    printf "Failed!\n"
  fi
}

# Parsing options for projects and packages
while getopts "p:k:r" opt; do
  case $opt in
    p) projects_input="$OPTARG" ;;
    k) packages_input="$OPTARG" ;;
    r) include_prerelease="true" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Initialize counters for not found projects, not found packages, and outdated packages
declare -i not_found_projects_count=0
declare -i not_found_packages_count=0
declare -i outdated_packages_count=0

# If no projects are specified, use all .csproj files
if [[ -z "$projects_input" ]]; then
  projects_input="*.csproj"
fi

# Split input projects and packages into arrays
IFS=';' read -ra projects <<< "$projects_input"
IFS=';' read -ra packages <<< "$packages_input"

# Loop through each specified project
for proj_name in "${projects[@]}"; do
  # Handle wildcard .csproj files
  if [[ "$proj_name" == *.csproj ]]; then
    proj_files=$(find . -type f -name "$proj_name")
  else
    if [ ! -f "$proj_name" ]; then
      echo "Project file '$proj_name' not found."
      ((not_found_projects_count++))
      continue
    fi
    proj_files=("$proj_name")
  fi

  # Loop through found csproj files
  for found_proj in $proj_files; do
    if [ ${#packages[@]} -eq 0 ]; then
      # Update all outdated packages if no specific package is specified
      outdated_command="dotnet list \"$found_proj\" package --outdated"
      [ "$include_prerelease" = "true" ] && outdated_command+=" --include-prerelease"
      eval $outdated_command | grep '>' | awk '{print $2, $5}' | while read -r pkg version; do
        update_package "$found_proj" "$pkg" "$version" "$include_prerelease"
      done
    else
      # Update only specified packages
      for pkg in "${packages[@]}"; do
        package_info=$(dotnet list "$found_proj" package)
        if ! grep -q "$pkg" <<< "$package_info"; then
          echo "Package '$pkg' not found in $found_proj."
          ((not_found_packages_count++))
          continue
        fi
        outdated_command="dotnet list \"$found_proj\" package --outdated"
        [ "$include_prerelease" = "true" ] && outdated_command+=" --include-prerelease"
        outdated_info=$(eval $outdated_command | grep "$pkg")
        if [ -z "$outdated_info" ]; then
          echo "Package '$pkg' in $found_proj is not outdated."
          ((outdated_packages_count++))
          continue
        fi
        version=$(echo "$outdated_info" | awk '{print $5}')
        update_package "$found_proj" "$pkg" "$version" "$include_prerelease"
      done
    fi
  done
done

# Read the count of updated packages and clean up
count=$(cat "$count_file")
rm "$count_file"

# Function to pluralize words based on the count
pluralize() {
  [ "$1" -eq 1 ] && echo "$2" || echo "${2}s"
}

# Construct the summary message parts
summary_parts=()
[ "$count" -gt 0 ] && summary_parts+=("$count $(pluralize "$count" 'package') updated")
[ "$not_found_projects_count" -gt 0 ] && summary_parts+=("$not_found_projects_count $(pluralize "$not_found_projects_count" 'project') not found")
[ "$not_found_packages_count" -gt 0 ] && summary_parts+=("$not_found_packages_count $(pluralize "$not_found_packages_count" 'package') not found")
[ "$outdated_packages_count" -gt 0 ] && summary_parts+=("$outdated_packages_count $(pluralize "$outdated_packages_count" 'package') not outdated")

# Output the summary message, or a message that no actions were taken
if [ ${#summary_parts[@]} -eq 0 ]; then
  echo "No updates performed."
else
  printf "%s\n" "$(IFS=,; echo "${summary_parts[*]}")"
fi
