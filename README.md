A Makefile for Java projects
============================
This is about an alternative way to manage the build process of Java
projects.

If you have ever written a `Makefile` for GNU `make` and are tired of
the slowness and clumsiness of the mainstream tools used to manage Java
projects (e.g. `maven`, `ant`, etc.), this project may help you take
full control of your own projects and drastically reduce the time
required to compile them.

> **NOTE**: I'm writing a few wiki pages that will more extensively
> analyse the reasons behind this project and how the problem was
> solved.
> In the meanwhile you can tweak this sample project, trying to figure
> out if it may be of any use to you.

How?
----
**make4java** is not a new tool you have to learn to use, but it is a
novelty way to use GNU `make` to manage Java projects -- with particular
emphasis on big ones -- effectively.

A project employing the **make4java** approach will be made of:

1. a `Makefile`
2. one or more `build.mk` files
3. the source code

The `Makefile` will be a copy of the one provided here and modified to
adapt it to the project's requirements.

The `build.mk` files are written from scratch, one for each JAR archive
or native library produced.

The source code can be both Java or native C code interfaced to the JVM
through the JNI.
Also, it is possible to add resources to the JAR archives produced, as
long as they are kept separate from the source code.

To make things more tangible, a full blown sample Java project is
provided: it uses almost all features of **make4java** (the only one
left out being the external libraries management).

If you're lucky, you'll only need to rewrite a few lines of the sample
`Makefile` to adapt it to your project.
In the worst case you will need to add/modify some rules, e.g., modify
the packaging rules or add rules for deployment.
In any case the *core* of the `Makefile` should need no tweak, as it
addresses problems common to any Java project.

The sample project
------------------
A typical Java project has the following structure:

* the whole project is split into a number of "components", each one
  containing everything needed to build a JAR archive or a native
  library, i.e., source code, resources, external libraries and even JAR
  archives or native libraries from some other component
* inside each component, source code and resources are both organised
  hierarchically but rooted on distinct directories
* the result of the build process is some kind of archive containing the
  JAR archives and native libraries from all or some of the project's
  components plus a bunch of miscellaneous files like scripts,
  documentation, etc.

The sample project follows the above schema:

* there are three components: `bar`, `foo/java` and `foo/native`, where
  `bar`'s JAR archive will contain `foo/java`'s JAR archive
* the Java source code is rooted on `src/main/java`, the native code on
  `src/main/native` and the resources on `src/main/resources`
* building the sample project will yield a `.tar.gz` containing `bar`'s
  JAR archive, `foo/native`'s native library, `bin/run.sh` and
  `doc/README`

To compile it, you need a JDK, version 1.3 or successive should do,
however I've only tested version 1.7 and 1.8 of OpenJDK.

Native code is disabled by default.
To enable it you can pass `ENABLE_FOO_FEATURE=true` to `make`, or,
better, create a file named `localdefs.mk` beside the `Makefile`,
containing the following text:

```
ENABLE_FOO_FEATURE = true
```

Native code support is available only for Linux and FreeBSD, however
adding more architectures should be trivial.

To compile everything run:

```
make
```

or:

```
make ENABLE_FOO_FEATURE=true
```

A tar archive will be created under the `packages` directory.
The `build` directory will contain a bunch of files and directories
required to build the package and keep the current status of the source
code.

You can unpack the package and run the `bin/run.sh` script -- it will
print some random text.
What the sample project does is not really important.

To clean up run:

```
make clean
```

For more information, read the sample `Makefile` -- it has plenty of
comments.

A real world example
--------------------
The [clone of the Mobicents jSS7][] is a bigger, real world project
based on a previous (unreleased) version of **make4java**, where the
difference in performance between the original build system used
(`maven`) and **make4java** is clearly noticeable.

Sure, you have to *manually* download all the external libraries
required, but, on the other hand, this gives you the freedom to choose
which version of the libraries to use.
When using `maven` with *big* projects, with tens or hundreds of
dependencies it happens more often than not to be forced to install two
slightly different version of the same library, just because they are
themselves dependencies of other libraries whose dependencies you can't
control -- or maybe can, with great effort.

Tweak instructions
------------------
Java classes are compiled in three phases:

1. first, the list of the source files to be compiled is built (if all
   the classes are up to date, the list  will be empty)
2. then, if the list is not empty, all the source files collected are
   compiled with a single invocation of `javac`
3. finally, everything else left to be done is done (e.g., building
   JARs, compiling native code, etc.)

All the dependencies are tracked, that is:

1. if class A is modified, all the classes that make use of it are
   recompiled too
2. JAR archives containing class/resource/JAR files that were
   recompiled/modified/updated will be updated as well

Note that inter-class dependencies are tracked only if the `jdeps`
utility is available.
If it cannot be found (or if it was explicitly disabled), then the Java
source files will be all recompiled every time just only one of them
requires recompilation -- that is, if none of them were modified, no
source files will be recompiled at all.

`jdeps` was added in JDK 1.8, however you don't need to compile your
source code with JDK 1.8 just to enjoy incremental compilation: you can
tell `Makefile` to use `javac`, `javah` and `java` from, say, JDK 1.7
and `jdeps` from JDK 1.8.
All you need to do is to redefined `Makefile`'s `JAVA`, `JAVAH`, `JAVAC`
and `JDEPS` variables with appropriate values.

> **NOTE**: Because the specific names of the tools used in a
> development environment is a local matter, the preferred way to
> redefine those variables is to put them inside a file named
> `localdefs.mk`, next to the `Makefile`.

### The Makefile ###
For the sake of clarity and documentation, the `Makefile` was split into
the following parts:

1. Tools
2. Project properties and structure
3. build.mk's variables and macros
4. External libraries
5. Java components
6. Native components
7. Components' build.mk files
8. Packaging
9. Clean-up

However, the parts you may need to tweak are:

1. Tools
2. Project properties and structure
3. Components' build.mk files
4. Packaging
5. Clean-up

"Tools" defines a variable for each program used in the build process.
Its function is mainly to allow the final user of your project to use a
different version of a tool than the one available in his system.
As already said above, this is a local matter and should be addressed
putting all the redefined variables in the `localdefs.mk` file.

"Project properties and structure" defines some useful variables --
e.g., the current version of your project (`package.version`) -- and the
names of several directories and files -- e.g., the name of the root
directory of the Java source code tree (`SOURCES_PATH`), the name of
file containing inter-class dependencies (`JAVA_DEPENDENCIES`), etc.

For example, the sample project stores the Java source files in the
`src/main/java` subdirectory under each component's base directory.
To use another subdirectory, redefine the `SOURCES_PATH` variable.

> **NOTE**: For the structure of you project is *not* a local matter,
> you should actually modify the `Makefile`.

"Components' build.mk files" contains a list of included `build.mk`
files, one for each project's component.
To make some of the components optional, you may put their include
directives inside conditional blocks (see the sample `Makefile` for an
example).
More on the `build.mk` files in the next section.

"Packaging" is meant to contain the instructions required to build a
package, deploy the components or whatever is most appropriate to be
done of the components built.

For the sake of illustration, the sample `Makefile` contains
instructions to build a `.tar.gz` archive containing some of the
project's components, a README and a script to start the application.
You may adapt it to your needs or write your own instructions from
scratch, but, whichever path you decide to take, keep in mind that:

1. you may define a sensible default target by simply naming it before
   any other targets -- e.g., the `package` target in the "Project
   properties and structure" is the default target
2. to add dependencies between the packaging targets and the projects'
   components add as many `$(<componentname>.buildname)` as required to
   the target's prerequisites (more on this in the next section)

Finally, "Clean-up" contains instructions to remove all the files
created by `make`.
To keep things as simple as possible, the sample project stores all the
generated files in two directories:

1. `$(BUILD_DIR)`, to hold all the intermediate files
2. `$(PACKAGE_DIR)`, to hold the final products of the build process

If your packaging instructions do something more complex than wrapping
some files in an archive -- e.g., deploying files into a remote server
-- this is the right place to insert instructions to undo whatever the
packaging instructions do.

### The build.mk ###
The `Makefile` deals with global properties of the project, whereas the
`build.mk` deals with the properties of a single component, i.e., a JAR
archive or a native library.

A `build.mk` should contain a single macro invocation:

```
$(eval $(call BUILD_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_RESOURCES),$(MK_INCLUDED_JARS)))
```

in case of a JAR archive, or:

```
$(eval $(call BUILD_NATIVE_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_CFLAGS),$(MK_LDFLAGS),$(MK_JAVAH_CLASSES)))
```

in case of a native library.

Those macros are defined, respectively, in the "Java components" and
"Native components" parts of the `Makefile`.
The arguments to the macros define properties of the component, namely:

* `MK_NAME` is the name of the component
* `MK_VERSION` is the version of the component -- can be empty
* `MK_DIR` is the relative path to the component's subdirectory (the
  directory containing the `build.mk` file) from the project's topmost
  directory (the directory containing the `Makefile`)
* `MK_SOURCES` lists the Java or native source files of the component
* `MK_RESOURCES` lists the resources to be included in the JAR archive
* `MK_INCLUDED_JARS` lists the names of the components whose JAR
  archive or native library have to be included in this component's JAR
  archive
* `MK_CFLAGS` specifies options to be passed to the C compiler
* `MK_LDFLAGS` specifies options to be passed to the native linker
* `MK_JAVAH_CLASSES` specifies a list of Java classes whose interfaces
  have to be exported as JNI C include files

The values specified for `MK_NAME` and `MK_VERSION` are used to build
the name of the JAR archive/native library.
The name is different depending on whether `MK_VERSION` is empty or not:
if empty, the JAR archive will be named `<name>.jar` and the native
library `<name>.so`, else they will be named `<name>-<version>.jar`
and `<name>-<version>.so`.

The class names listed in the `MK_JAVAH_CLASSES` argument should be
specified in the "dot notation", i.e., `some.package.name.SomeClass`.

JNI's system include files are automatically located and added to the C
compiler command line when the native code is compiled.
However, I have only tested this on FreeBSD and Linux.
If you are using some other OS, you will need to fix the `Makefile` --
it should be as simple as giving the `ARCHITECTURE` variable the correct
value for your OS.
The `ARCHITECTURE` variable is defined at the beginning of the "Native
components" part of the `Makefile`.

File names specified in `MK_SOURCES` and `MK_RESOURCES` must be relative
to the component's directory (i.e., `MK_DIR`).

As an aid, the macros `FIND_SOURCES`, `FIND_RESOURCES` and
`FIND_NATIVE_SOURCES` are provided to fill up the `MK_SOURCES` and
`MK_RESOURCES` arguments with the names of the files found in the
directories specified by the `SOURCES_PATH`, `RESOURCES_PATH` and
`NATIVE_SOURCES_PATH` variables, respectively.

Before being added to the JAR archive the resource files are "filtered",
that is, they will be parsed looking for string formatted like
`${<varname>}`, which, when found, are replaced with the value of
variable `<varname>`.

To avoid looking for every `make` variable defined, only variables
listed in the `RESOURCE_PLACEHOLDERS` variable are looked for.
`RESOURCE_PLACEHOLDERS` is shared among all the components, thus it
should be modified only by means of the `+=` operator.

Any `make` variable can be listed in `RESOURCE_PLACEHOLDERS`, however
`RESOURCE_PLACEHOLDERS` is most useful when combined with the "library
variables".

For each external library, JAR archive or native library, the following
four "library variables" are defined:

* `<libname>.version`, containing the version number of the library
* `<libname>.basename`, containing the file name of the library,
  stripped of the path
* `<libname>.buildname`, containing the file name of the library,
  including the relative path from the project's topmost directory
* `<libname>.jarname`, containing the file name of the library,
  including the relative path from the JAR's root directory

Here `<libname>` is either the external library file name stripped of
the file extension and version number or the name of the component as
specified in the `MK_NAME` argument.

The last variable is meant to be used to reference included libraries
from inside JAR archives.
`<libname>` must be specified in the `MK_INCLUDED_JARS` argument of the
including component.

For example, in the sample project the `bar` component includes the
`foo` component, that is, `bar`'s `build.mk` defines `MK_INCLUDED_JARS
:= foo`.
When built, `bar`'s JAR archive will contain a copy of `foo`'s JAR
archive in a file named `jars/foo-1.0.1.jar` (the directory `jars` can
be changed redefining the `Makefile`'s `resources.jars` variable).

Note that the `MK_INCLUDED_JARS` variable works with external libraries
too.

Also, when defining components including other components' JAR archives
or native libraries, care must be taken in ensuring that when writing
the "Components' build.mk files" part of the `Makefile`, `build.mk`s of
the included components are included before the including components'
`build.mk`s.
If `make` fails with error "*** Missing included component(s):  foo.
Stop.", then you have misspelled `foo`'s name, forgot to include `foo`'s
`build.mk` in your `Makefile` or included it *after* a component that
lists `foo` in its `MK_INCLUDED_JARS` argument.

Both the `BUILD_MAKE_RULES` and the `BUILD_NATIVE_MAKE_RULES` macros
define several targets bound together into dependency trees whose roots
are, respectively, the JAR archive and the native library of the
component.

Those root targets are not build automatically but must be explicitly
invoked or included as prerequisite in another target, e.g., the default
target or the packaging target (see previous section).
This is the purpose of the third "library variable" -- it is much easier
to add `<libname>.buildname` among the prerequisites rather than
building the external library, JAR archive or native library name
yourself.

Also note that the "library variables" as well as the `resources.jars`
and `package.version` variables are automatically added to
`RESOURCE_PLACEHOLDERS`.
Any other variable you may want to be expanded during filtering must be
explicitly added to `RESOURCE_PLACEHOLDERS`.

Supported `make` versions
-------------------------
To improve performances, the `Makefile` makes use of the `file`
function, found in GNU `make` version 4.0 and successive.

However, if version 4.0 is not available to you, there is still hope.
The `file` function is used in rules like the following:

```
.PHONY: $(JAVAC_SOURCEPATHS_LIST)

$(JAVAC_SOURCEPATHS_LIST): | $(BUILD_DIR)
        @echo 'Building $@' \
        $(file >$@) \
        $(foreach var,$(SOURCE_DIRECTORIES),$(file >>$@,-sourcepath $(var)$(SOURCES_PATH)))
```

The are several of them.
All you need to do to fix them is to rewrite them as:

```
.PHONY: clean_javac_sourcepaths_list $(JAVAC_SOURCEPATHS_LIST)

clean_javac_sourcepaths_list: | $(BUILD_DIR)
        @: >'$(JAVAC_SOURCEPATHS_LIST)'

$(JAVAC_SOURCEPATHS_LIST): | clean_javac_sourcepaths_list
        @echo "Building $@" \
        $(foreach var,$(SOURCE_DIRECTORIES),$(shell echo '-sourcepath $(var)$(SOURCES_PATH)' >>'$@'))
```

> **NOTE**: Remember that the white space indenting the recipe is not
> SPACE characters but TAB characters.

Having done this for each rule that employ the `file` function, you
should have now a `Makefile` that work with previous versions of `make`
as old as 3.81 and maybe older.

> **NOTE**: I said *should* above, because I haven't tested it, so there
> is still a chance that after having done as told, you may stil need
> version 4.0.

License
-------

make4java - A Makefile for Java projects

Written in 2015 by Francesco Lattanzio <franz.lattanzio@gmail.com>

To the extent possible under law, the author have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software.
If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

[clone of the Mobicents jSS7]: http://github.com/fltt/mobicents-jss7
