#!/bin/bash

# Temporary file to keep track of the number of updated packages
count_file=$(mktemp)
echo 0 > "$count_file"

# Function to update a specific package in a csproj file
update_package() {
  local csproj=$1
  local pkg=$2
  local version=$3

  # Updating process message with package name in single quotes
  printf "Updating '%s' to version %s in %s... " "$pkg" "$version" "$csproj"

  # Attempt to update the package
  if dotnet add "$csproj" package "$pkg" --version "$version" > /dev/null 2>&1; then
    printf "Completed!\n"
    echo $(( $(cat "$count_file") + 1 )) > "$count_file"
  else
    printf "Failed!\n"
  fi
}

# Initialize counters for not found projects, not found packages, and outdated packages
declare -i not_found_projects_count=0
declare -i not_found_packages_count=0
declare -i outdated_packages_count=0

projects_input=""
packages_input=""

# Parsing options for projects and packages
while getopts "p:k:" opt; do
  case $opt in
    p) projects_input="$OPTARG" ;;
    k) packages_input="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Check if at least one project or package has been specified
if [[ -z "$projects_input" && -z "$packages_input" ]]; then
  projects_input="*.csproj"
fi

# Split input projects and packages into arrays
IFS=';' read -ra projects <<< "$projects_input"
IFS=';' read -ra packages <<< "$packages_input"

# Loop through each specified project
for proj_name in "${projects[@]}"; do
  if [[ "$proj_name" == "*.csproj" ]]; then
    proj_files=$(find . -type f -name "$proj_name" -print)
  else
    proj_files=$(find . -type f -name "$proj_name" -print)
    if [ -z "$proj_files" ]; then
      echo "Project file '$proj_name' not found."
      ((not_found_projects_count++))
      continue
    fi
  fi

  for found_proj in $proj_files; do
    if [ ${#packages[@]} -eq 0 ]; then
      # Update all outdated packages if no specific package is specified
      dotnet list "$found_proj" package --outdated | grep '>' | awk '{print $2, $5}' | while read pkg version; do
        update_package "$found_proj" "$pkg" "$version"
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
        outdated_info=$(dotnet list "$found_proj" package --outdated | grep "$pkg")
        if [ -z "$outdated_info" ]; then
          echo "Package '$pkg' in $found_proj is not outdated."
          ((outdated_packages_count++))
          continue
        fi
        version=$(echo "$outdated_info" | awk '{print $5}')
        update_package "$found_proj" "$pkg" "$version"
      done
    fi
  done
done

# Read the count of updated packages and clean up
count=$(cat "$count_file")
rm "$count_file"

# Function to pluralize words based on the count
pluralize() { [ "$1" -eq 1 ] && echo "$2" || echo "${2}s"; }

# Construct the summary message parts
summary_parts=()
[ $count -gt 0 ] && summary_parts+=("$count $(pluralize $count 'package') updated")
[ $not_found_projects_count -gt 0 ] && summary_parts+=("$not_found_projects_count $(pluralize $not_found_projects_count 'project') not found")
[ $not_found_packages_count -gt 0 ] && summary_parts+=("$not_found_packages_count $(pluralize $not_found_packages_count 'package') not found")
[ $outdated_packages_count -gt 0 ] && summary_parts+=("$outdated_packages_count $(pluralize $outdated_packages_count 'package') not outdated")

# Output the summary message
printf "%s\n" "$(IFS=,; echo "${summary_parts[*]}")"
