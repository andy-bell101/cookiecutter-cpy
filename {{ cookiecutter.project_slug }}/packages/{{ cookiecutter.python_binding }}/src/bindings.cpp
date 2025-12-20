#define QUOTE(seq) "\"" #seq "\""

#include "src/lib.h"
#include <nanobind/nanobind.h>
namespace nb = nanobind;

// NOLINTNEXTLINE
NB_MODULE(_core, m)
{
  m.def("add", [](int a, int b) { return a + b; });
  m.def("multiply", multiply);
  m.attr("__version__") = QUOTE(SKBUILD_PROJECT_VERSION);
}
