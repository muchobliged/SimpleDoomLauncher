#!/bin/bash
nimble build -d:mingw --opt:size --app:gui -d:release -d:strip -d:imguiStatic -d:glfwStatic -f
