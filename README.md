# RES Command-line interface (RES CLI)

The RES Command-line interface (RES CLI) is a command-line tool used to create, manage, and run projects created using the RES game engine. The RES engine is a minimalist game engine written in Haxe focused on raster graphics. You can find more information about the RES engine and its features on the [GitHub repository](https://github.com/RES-Haxe/res).

## Installation

To use the RES CLI, you can either download a pre-built executable from the GitHub releases page or build it from the source code. To build the project from source, you will need Haxe 4.2.5 and the hxcpp target configured. You can find more information about configuring the hxcpp target [here](https://haxe.org/manual/target-cpp.html).

Once you have Haxe and the hxcpp target set up, navigate to the project directory and run the following command:

```bash
haxe dist.hxml
```

This will build the project and prepare an archive with the binaries for the platform from which it was built (Windows, Linux, or OS X x64).

To use the RES CLI globally, add the directory containing the executable to your system's PATH environment variable.

## Usage

Once you have the RES CLI installed and added to your PATH, you can use it to initialize a new RES project and build and run it.

### Creating a new project

To create a new RES project, use the following command:

```bash
res init project-name [directory]
```

Where `project-name` is the name of your project, and `[directory]` is an optional argument specifying the directory in which to initialize the project. If not specified, the project will be initialized in a new directory with the same name as the project.

For example, to initialize a new project in the current directory, use the following command:

```bash
res init project-name .
```

### Building and running a project

To build and run a RES project, navigate to the project directory and use the following command:

```bash
res run <target>
```

Where `<target>` is the target platform for the build. The currently supported targets are `hl` for HashLink and `js` for JavaScript/HTML5. By default, the `hl` target is used if no target is specified.

For example, to build and run the project for the `hl` target, use the following command:

```bash
res run hl
```

To build and run the project for the `js` target, use the following command:

```bash
res run js
```

## Contributing

If you encounter any issues or have suggestions for new features, please feel free to open an issue on the [GitHub repository](https://github.com/RES-Haxe/res-cli). If you want to contribute to the project, you can fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.