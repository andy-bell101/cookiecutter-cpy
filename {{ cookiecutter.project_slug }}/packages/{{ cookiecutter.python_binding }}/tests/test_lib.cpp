#include "src/lib.h"
#include <gtest/gtest.h>

TEST(TEST_LIB, SimpleMultiply)
{
  EXPECT_EQ(multiply(5, 6), 30);
}
