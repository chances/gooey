project('gooey', 'c', 'd',
  version : '0.1.0',
  license: 'MIT',
  default_options : ['warning_level=3']
)
project_soversion = 0

lexbor = subproject('lexbor')
lexbor_dep = lexbor.get_variable('lexbor_dep')
lexbor_static_dep = lexbor.get_variable('lexbor_static_dep')

lexbor_interop = static_library('gooey_lexbor_interop',
  'source/gooey/parsers/css.c',
  'source/gooey/parsers/html.c',
  dependencies: [lexbor_static_dep],
  install: false,
  gnu_symbol_visibility : 'hidden',
)

lib = library('gooey',
  # 'source/gooey/package.d',
  dependencies: [],
  link_with: [lexbor_interop],
  install: true,
  version: meson.project_version(),
  soversion: project_soversion
)
lib_static = static_library('gooey',
  # 'source/gooey/package.d',
  dependencies: [],
  link_with: [lexbor_interop],
  install : true,
  gnu_symbol_visibility : 'hidden',
)

pkgc = import('pkgconfig')
pkgc.generate(name: 'gooey',
  libraries: lib,
  # subdirs: 'd/gooey',
  version: meson.project_version(),
  description: 'A GUI library implementing the W3C Web Platform.'
)

# test_exe = executable('gooey-test-unittest', 'source/gooey/package.d', link_with : lib_static)
# test('gooey', test_exe)

# Make this library usable as a Meson subproject.
gooey_dep = declare_dependency(
  include_directories: include_directories('.'),
  link_with : lib
)
gooey_static_dep = declare_dependency(
  include_directories: include_directories('.'),
  link_with : lib_static
)

dlang_mod = import('dlang')
if find_program('dub', required: false).found()
  # TODO: Something special?
endif
