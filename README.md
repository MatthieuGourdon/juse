# juse
Juse is a lightweight Bash function designed to manage multiple Java installations without the overhead of heavy version managers. It allows you to register JDK paths, switch your JAVA_HOME and PATH on the fly, and persist a default version across new terminal sessions.


## Installation
1. Copy the juse() function into your `~/.bashrc` file or this line in your `~/.bashrc`: 
```Bash
$ source ~/.local/bin/java_functions.sh
```
2. Reload your shell to apply the changes:
```Bash
source ~/.bashrc
```

## Usage
### Add a Java version
Provide the path to the JDK root directory. The script will automatically detect the version number.
```Bash
juse add /usr/lib/jvm/java-17-openjdk-amd64
```


### List registered versions
Displays all versions currently stored in your configuration.
```Bash
juse list
```


### Switch version (Current session)
Updates your environment variables for the current terminal window.
```Bash
juse 17
```


### Set default version
Updates your ~/.bashrc so that the specified version is automatically loaded in every new terminal.
```Bash
juse set-default 21
```


### Show current status
Displays the active JAVA_HOME and the output of java -version.
```Bash
juse current
```


### Delete a version
Removes a version entry from the configuration list.
```Bash
juse del 8
```


## Technical Details
### Storage
Configuration data is stored in `~/.juse_versions` using a simple pipe-delimited format:
```
version|/path/to/jdk
```

### Environment Management
When a version is selected:
- JAVA_HOME is exported to the registered path.
- $JAVA_HOME/bin is prepended to the PATH if it is not already present.
