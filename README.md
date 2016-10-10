A Makefile for Java projects
============================
This is about an alternative way to manage the build process of Java
projects.

If you know how to use Autoconf and GNU Make and are tired of the
slowness and clumsiness of the mainstream tools used to manage Java
projects (e.g. `maven`, `ant`, etc.), this project may help you take
full control of your own projects and drastically reduce the time
required to compile them.

> **NOTE**: The wiki contains a few pages that analyse the problem and
> the solution more extensively.

How?
----
**make4java** is not a new tool you have to learn to use, but new way to
use GNU Make to manage Java projects -- with particular emphasis on big
ones -- effectively.

A project employing the **make4java** approach will be made of:

1. a `configure.ac` and related files
2. a `Makefile.in`
3. one or more `build.mk` files
4. the source code

The `configure.ac` and the `Makefile.in` will be copies of the ones
provided here, modified to fit the project's specific requirements.

The `build.mk` files are written from scratch, one for each JAR archive,
test suite or native library.

The source code can be both Java or native C code interfaced to the JVM
through the JNI.
Also, it is possible to add resources to the JAR archives produced, as
long as they are kept separate from the source code.

To make things more tangible, a full blown sample Java project is
provided: it uses most of the features of **make4java**.

If you're lucky, you'll only need to change a few lines of the sample
`configure.ac` and `Makefile.in` to adapt them to your project.
In the worst case you will need to add more checks to the `configure.ac`
for some external program / library your project depends on or to
add / modify a few `Makefile.in`'s rules, e.g., modify the packaging
rules or add rules for deployment.
In any case the *core* of both `configure.ac` and `Makefile.in` should
need no tweak, as they address problems common to any Java project.

The sample project
------------------
A typical Java project has the following structure:

* the whole project is split into a number of "components", each one
  containing everything needed to build a JAR archive, a test suite or a
  native library, i.e., source code, resources, external Java libraries
  and even JAR archives or native libraries from some other component
* inside each component, source code and resources are both organised
  hierarchically but rooted on distinct directories
* the result of the build process is some kind of archive containing the
  JAR archives and native libraries from all or some of the project's
  components plus a bunch of miscellaneous files like scripts,
  documentation, etc.

The sample project follows the above schema:

* there are four components: `bar/java`, `foo/java`, `foo/native` and
  `foo/test`, where `bar/java`'s JAR archive will contain `foo/java`'s
  JAR archive
* testing is performed through a dedicated components, `foo/test` -- it
  will be built only when / if running the tests
* both Java and native source code are rooted on `src` and the resources
  on `resources`
* building the sample project will yield a `.tar.gz` containing
  `bar/java`'s JAR archive, `foo/native`'s native library, `bin/run.sh`
  and `doc/README`

To compile it, you need a JDK, version 1.3 or successive should do,
however I've only tested version 1.6, 1.7 and 1.8 of OpenJDK.

`configure.ac` requires Autoconf version 2.62 or successive.
To build or rebuild the `configure` script run:

```
autoreconf
```

Then, to build the TAR package run:

```
configure
make
```

And to run the tests:

```
make check
```

If you prefer not to build your project in the same directory tree of
the source code, just create a "build" directory somewhere and invoke
the `configure` script from there:

```
mkdir /path/to/build/tree
cd /path/to/build/tree
/path/to/source/tree/configure
make
```

Native code and the tests (which check the native code) are disabled by
default.
To enable them you can pass `configure` the `--enable-foo-feature`
option.
I've tested the native code only in Linux and FreeBSD, however adding
more architectures should be trivial using Autoconf.

For a list of supported options / environment variables run:

```
configure --help
```

> **NOTE**: The "installation directories" shown in the help screen are
> unused, so specifying '--prefix' has no effect.
> This is so, for I chose not to install / deploy anything but to build
> a TAR package (which is what I usually do with my Java projects).

The TAR archive will be created under the `packages` directory.
The `build` directory will contain a bunch of files and directories
required to build the package and keep the current status of the source
code.

You can unpack the package and run the `bin/run.sh` script -- it will
print some random text.
What the sample project does is not really important -- it is really
just a template project I use to write new ones.

To clean up run:

```
make clean
```

To remove `configure` generated files run:

```
make distclean
```

For more information, read the sample `configure.ac` and `Makefile.in`.

A real world example
--------------------
The [clone of the Mobicents jSS7][] is a bigger, real world project
based on a previous (unreleased) version of **make4java**, where the
difference in performance between the original build system used
(`maven`) and **make4java** is clearly noticeable.

> **NOTE**: By default the `maven`-based build system will also run test
> suites on the compiled code.
> For a fair comparison you should disable them.

Sure, **make4java** requires you to *manually* download all the external
libraries, whereas `maven` downloads them automatically.
At first this may seem to be a disadvantage, but when using `maven` with
*big* projects, with tens or hundreds of dependencies it happens more
often than not to include two slightly different version of the same
library, just because they are themselves dependencies of other
libraries whose dependencies you can't control -- or maybe can, with
great effort.
If you can control which version of a library to download, then you can
choose the most suitable *single* version of that library.

Tweak instructions
------------------
Java classes are compiled in three phases:

1. first, the list of the source files to be compiled is built (if all
   the classes are up to date, the list will be empty)
2. then, if the list is not empty, all the source files collected are
   compiled with a single invocation of `javac`
3. finally, everything else left to be done is done (e.g., building
   JARs, compiling native code, etc.)

All the dependencies are tracked, that is:

1. if class A is modified, all the classes that make use of it are
   recompiled too
2. JAR archives containing class / resource / JAR files that were
   recompiled / modified / updated will be updated as well

Note that inter-class dependencies are tracked only if the `jdeps`
utility is available and enabled.
If it cannot be found or if it was explicitly disabled, then the Java
source files will be all recompiled every time just only one of them
requires recompilation -- that is, if none of them were modified, no
source files will be recompiled at all.

`jdeps` was added in JDK 1.8, however you don't need to compile your
source code with JDK 1.8 just to enjoy incremental compilation: you can
tell `configure` to use `jar`, `javac` and `javah` from, say, JDK 1.7
and `jdeps` from JDK 1.8.
All you need to do is to pass `configure` the `JAR`, `JAVAC`, `JAVAH`
and `JDEPS` variables with appropriate values.

> **NOTE**: The proper way to pass `configure` those variables is:
>
> ```
> configure JAVAC="/path/to/javac -options" JDEPS=/path/to/jdeps
> ```
>
> Do not use the following idiom:
>
> ```
> JAVAC="/path/to/javac -options" JDEPS=/path/to/jdeps configure
> ```
>
> nor:
>
> ```
> export JAVAC="/path/to/javac -options"
> export JDEPS=/path/to/jdeps
> configure
> ```

### The configure.ac ###
The main purpose of `configure.ac` is to locale the tools needed (`awk`,
`cc`, `javac`, etc.) and to enable or disable optional features, like
the `foo-feature` and the incremental compilation.

To locate the Java tools I've written specially crafted Autoconf macros,
as those I found around were not solid enough.
You'll find them in the `m4` subdirectory.

If you need some external *native* library, you should use Autoconf
macros to locate and test it.
For external *Java* libraries, use the method explained in the next
section.

For more information about Autoconf run:

```
info autoconf
```

### The Makefile.in ###
For the sake of clarity and documentation, the `Makefile.in` was split
into the following parts:

1. Tools
2. Project properties and structure
3. build.mk's variables and macros
4. External Java libraries
5. Java components
6. Native components
7. Components' build.mk files
8. Packaging
9. Standard targets

However, the parts you may need to tweak are:

1. Tools
2. Project properties and structure
3. Components' build.mk files
4. Packaging
5. Standard targets

"Tools" fill up a number of Make variables with the corresponding
variables defined in `configure.ac`.
You may need to add some extra variables for native libraries your
project depends on.

"Project properties and structure" defines some useful variables --
e.g., the current version of your project (`package.version`) -- and the
names of several directories and files -- e.g., the name of the root
directory of the Java source code tree (`SOURCES_PATH`), the name of
file containing inter-class dependencies (`JAVA_DEPENDENCIES`), etc.

For example, the sample project stores the Java source files in the
`src` subdirectory under each component's base directory.
To use another subdirectory, redefine the `SOURCES_PATH` variable.

"Components' build.mk files" contains a list of included `build.mk`
files, one for each project's component.
To make some of the components optional, you may put their include
directives inside conditional blocks (see the sample `Makefile.in` for
an example).
More on the `build.mk` files in the next section.

"Packaging" is meant to contain the instructions required to build one
or more packages.
For the structure of a package may be quite complex, I chose to dedicate
it a specific section of `Makefile.in`.

For the sake of illustration, the sample `Makefile.in` contains
instructions to build a `.tar.gz` archive containing some of the
project's components, a README and a script to start the application.
You may adapt it to your needs or write your own instructions from
scratch, but, whichever path you decide to take, keep in mind that to
add dependencies between the packaging targets and the projects'
components add as many `$(<componentname>.buildname)` as required to the
target's prerequisites (more on this in the next section).

Lastly, "Standard targets" contains the targets -- plus `doc` -- any GNU
Build System compliant `Makefile` must support.
I chose them just to give `Makefile.in` some resemblance to Automake
produced `Makefile`s, but you can really use whatever targets you want.

The Standard targets are:

* `all` (also the default target): it will just build the package(s), in
  fact, it is just an alias for the package(s) target(s)
* `install` and `install-strip`: for there's nothing to install they are
  just more aliases for the package(s) target(s)
* `uninstall`: this target will do nothing, for nothing is installed
* `clean`: will remove any file built by `make` -- to keep things as
  simple as possible, the sample project stores all the generated files
  in two directories, `$(BUILD_DIR)` and `$(PACKAGE_DIR)`, making the
  `clean` target as simple as a single `rm -rf`
* `distclean`: same as `clean` but will also remove any file built by
  `configure`
* `check`: will run all the test suites -- if you only want to run a
  specific test suite, use the `check-<componentname>` target
* `installcheck`: should run a test suite against the installed files,
  but given that nothing is installed, it is just an alias for `check`
* `dist`: it will build a TAR package containing the source code and all
  the file needed to build from source
* `doc`: this is not a Standard target, but I added it to build some
  documentation in the Javadoc style

> **NOTE**: the `dist` and `doc` targets are still work in progress.

### The build.mk ###
The `Makefile.in` deals with global properties of the project, whereas
the `build.mk` deals with the properties of a single component, i.e., a
JAR archive, a test suite or a native library.

A `build.mk` should contain a single macro invocation:

```
$(eval $(call BUILD_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_RESOURCES),$(MK_INCLUDED_JARS),$(MK_ADDITIONAL_CLASSES)))
```

in case of a JAR archive:

```
$(eval $(call BUILD_TEST_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_RESOURCES),$(MK_RUNTIME_DEPENDENCIES),$(MK_MAIN_CLASS)))
```

in case of a test suite, or:

```
$(eval $(call BUILD_NATIVE_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_CFLAGS),$(MK_LDFLAGS),$(MK_JAVAH_CLASSES),$(MK_EXTERNAL_OBJECTS)))
```

in case of a native library.

Those macros are defined, respectively, in the "Java components" and
"Native components" parts of the `Makefile.in`.
The arguments to the macros define properties of the component, namely:

* `MK_NAME` is the name of the component
* `MK_VERSION` is the version of the component -- can be empty
* `MK_DIR` is the relative path to the component's subdirectory (the
  directory containing the `build.mk` file) from the project's topmost
  directory (the directory containing the `Makefile.in`)
* `MK_SOURCES` lists the Java or native source files of the component
* `MK_RESOURCES` lists the resources to be included in the JAR archive
* `MK_INCLUDED_JARS` lists the names of the components whose JAR
  archive or native library have to be included in this component's JAR
  archive
* `MK_ADDITIONAL_CLASSES` lists the names (in the
  package.subpackage.classname format) of classes, defined in other
  components, to be included in this component's JAR archive
* `MK_RUNTIME_DEPENDENCIES` lists the names of the components the test
  suite depends on -- at least the tested component should be listed
* `MK_MAIN_CLASS` is the name of the class to invoke to run the test
  suite -- it must define the `public static void main(String[])` method
  and require no arguments
* `MK_CFLAGS` specifies options to be passed to the C compiler
* `MK_LDFLAGS` specifies options to be passed to the native linker
* `MK_JAVAH_CLASSES` specifies a list of Java classes whose interfaces
  have to be exported as JNI C include files
* `MK_EXTERNAL_OBJECTS` lists the names (in the
  native-library-name/object-file-name.o format) of object files,
  defined in other native components, to be included in this component's
  native library

The values specified for `MK_NAME` and `MK_VERSION` are used to build
the name of the JAR archive / native library.
The name is different depending on whether `MK_VERSION` is empty or not:
if empty, the JAR archive will be named `<name>.jar` and the native
library `<name>.so`, else they will be named `<name>-<version>.jar`
and `<name>-<version>.so`.

The class names listed in the `MK_JAVAH_CLASSES` argument must be
specified in the "dot notation", i.e., `some.package.name.SomeClass`.

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

For each external Java library, JAR archive or native library, the
following four "library variables" are defined:

* `<libname>.version`, containing the version number of the library
* `<libname>.basename`, containing the file name of the library,
  stripped of the path
* `<libname>.buildname`, containing the file name of the library,
  including the relative path from the project's topmost directory
* `<libname>.jarname`, containing the file name of the library,
  including the relative path from the JAR's root directory

Here `<libname>` is either the external Java library file name stripped
of the file extension and version number or the name of the component as
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
be changed redefining the `Makefile.in`'s `resources.jars` variable).

Note that the `MK_INCLUDED_JARS` variable works with external Java
libraries too.

Also, when defining components including other components' JAR archives
or native libraries, care must be taken in ensuring that when writing
the "Components' build.mk files" part of the `Makefile.in`, `build.mk`s
of the included components are included before the including components'
`build.mk`s.
If `make` fails with error "*** Missing included component(s): foo.
Stop.", then you have misspelled `foo`'s name, forgot to include `foo`'s
`build.mk` in your `Makefile.in` or included it *after* a component that
lists `foo` in its `MK_INCLUDED_JARS` argument.

`MK_ADDITIONAL_CLASSES` and `MK_EXTERNAL_OBJECTS` are finer grained
versions of `MK_INCLUDED_JARS` which allow to include single class or
object files.
These are useful when your project contains components meant to be used
in different environments (e.g., client and server sides).
In many cases they will share a number of common classes but you can't
(nor wouldn't) duplicate the source files in every component sharing
them.
The solution is to include the source files in one component and then
use `MK_ADDITIONAL_CLASSES` and `MK_EXTERNAL_OBJECTS` to share them with
all the other components.

Moreover, contrary to `MK_INCLUDED_JARS`, when using
`MK_ADDITIONAL_CLASSES` and `MK_EXTERNAL_OBJECTS` you don't have to
include the components' `build.mk` files in some specific order --
`make` will figure out the dependencies between the involved components
irrespective of the order of inclusion of the `build.mk` files.

The `BUILD_MAKE_RULES`, `BUILD_TEST_MAKE_RULES` and
`BUILD_NATIVE_MAKE_RULES` macros define several targets bound together
into dependency trees whose roots are, respectively, the JAR archive,
the test suite (another JAR archive) and the native library of the
component.

Those root targets are not build automatically but must be explicitly
invoked or included as prerequisite in other targets, e.g., the
package(s) target(s) (see previous section).
This is the purpose of the third "library variable" -- it is much easier
to add `<libname>.buildname` among the prerequisites rather than
building the external Java library, JAR archive or native library name
yourself.

Also note that the first and last "library variables" as well as the
`resources.jars`, `resources.libs`, `package.name` and `package.version`
variables are automatically added to `RESOURCE_PLACEHOLDERS`.
Any other variable you may want to be expanded during filtering must be
explicitly added to `RESOURCE_PLACEHOLDERS`.

Supported GNU Make versions
---------------------------
To improve performances, the `Makefile.in` makes use of the `file`
function, found in GNU Make version 4.0 and successive.

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

> **NOTE**: Remember that the white spaces indenting the recipes are not
> SPACE characters but TAB characters.

Having done this for each rule that employ the `file` function, you
should have now a `Makefile.in` that work with previous versions of
`make` as old as 3.81 and maybe older.

> **NOTE**: I said *should* above, because I haven't tested it, so there
> is still a chance that after having done as told, you may stil need
> version 4.0.

License
-------

make4java - A Makefile for Java projects

Written in 2016 by Francesco Lattanzio <franz.lattanzio@gmail.com>

To the extent possible under law, the author have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software.
If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

[clone of the Mobicents jSS7]: http://github.com/fltt/mobicents-jss7
