function juse() {
     local config_file=~/.juse_versions
     local bash_config=~/.bashrc
     local -A jvm_paths

     [[ ! -f "$config_file" ]] && touch "$config_file"

     while IFS="|" read -r ver path; do
         [[ -n "$ver" && -n "$path" ]] && jvm_paths[$ver]="$path"
     done < "$config_file"

     case $1 in
         add)
             local new_path="$2"
             if [[ -z "$new_path" || ! -d "$new_path" ]]; then
                 echo "Error: Please provide a valid directory path." >&2
                 return 1
             fi

             local new_ver=$("$new_path/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | sed 's/^1\.//;s/\..*//')

             if [[ -z "$new_ver" ]]; then
                 echo "Error: Could not determine Java version at $new_path" >&2
                 return 1
             fi

             echo "$new_ver|$new_path" >> "$config_file"
             echo "Added Java $new_ver: $new_path"
             ;;

         del)
             if [[ -z "$2" || -z "${jvm_paths[$2]}" ]]; then
                 echo "Error: Please specify a valid version to delete." >&2
                 return 1
             fi

             grep -v "^$2|" "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
             echo "Removed Java $2 from the list."
             ;;

         list)
             echo "Available Java versions:"
             for version in $(printf "%s\n" "${!jvm_paths[@]}" | sort -n); do
                 printf "  %-4s -> %s\n" "$version" "${jvm_paths[$version]}"
             done
             ;;

         current)
             [[ -n "$JAVA_HOME" ]] && { echo "JAVA_HOME: $JAVA_HOME"; java -version; } || echo "JAVA_HOME not set."
             ;;

         set-default)
             if [[ -z "$2" || -z "${jvm_paths[$2]}" ]]; then
                 echo "Error: Invalid version. Use 'juse list'." >&2
                 return 1
             fi
             sed -i '/juse [0-9]* silent/d' "$bash_config"
             echo "juse $2 silent" >> "$bash_config"
             echo "Default set to $2 in $bash_config."
             ;;

         "")
             echo "Usage: juse <version | command>"
             echo ""
             echo "Commands:"
             echo "  add <path>         Add a new Java version by path"
             echo "  del <ver>          Remove a Java version from the list"
             echo "  list               List all available Java versions"
             echo "  current            Show the currently active Java version"
             echo "  set-default <ver>  Set the default Java version for new terminals"
             ;;


         *)
             if [[ -n "${jvm_paths[$1]}" ]]; then
                 export JAVA_HOME="${jvm_paths[$1]}"
                 if [[ ":$PATH:" != *":$JAVA_HOME/bin:"* ]]; then
                     export PATH="$JAVA_HOME/bin:$PATH"
                 fi
                 [[ "$2" != "silent" ]] && { echo "Switched to Java $1"; java -version; }
             else
                 echo "Error: Unknown version or command '$1'" >&2
                 return 1
             fi
             ;;
     esac
}
