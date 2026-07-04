# C/C++ Raylib Modular Build Environment

A highly optimized, professional-grade project template and build system for C and C++ applications using Raylib.

This project was built from the ground up to establish a rigorous, highly modular compilation pipeline. It utilizes a custom Makefile architecture designed to significantly reduce compilation times and cleanly separate language toolchains, reflecting industry-standard build practices.

## Key Build System Features

* **Distinct Language Pipelines:** C and C++ source files are compiled through entirely separate, specialized rules to ensure strict adherence to their respective compiler standards.
* **Precompiled Headers (PCH):** Integrates `.gch` generation (such as `raylib-cpp.hpp.gch`) to cache heavy header files and drastically cut down on repetitive processing.


* **Smart Object Caching:** Object files are intelligently saved and tracked to strictly avoid redundant recompilation of unmodified source files.
* **Performance Profiles:** Includes multiple configurable build profiles to easily switch between heavily optimized performance builds and debug-friendly binaries.
* **IDE Integration:** Comes pre-configured with `.vscode` workspace settings, including `launch.json` and `tasks.json`, for seamless debugging and task execution out of the box.


* **Local Library Linking:** Structurally organizes external dependencies within local `Libraries/` and `inc/` directories (like `raylib-cpp`) for modular portability.



## Project Structure Highlights

* **`Libraries/raylib-cpp/`**: Houses the local Raylib C++ wrapper and its generated precompiled headers.


* **`.vscode/`**: Contains the `launch.json`, `settings.json`, and `tasks.json` to hook the modular Makefile directly into the editor.



---

**Author:** Jeronimo Capelle
*Informatics Engineering*
