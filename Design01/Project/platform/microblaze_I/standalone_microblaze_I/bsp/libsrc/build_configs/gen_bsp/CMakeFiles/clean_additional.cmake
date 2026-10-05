# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "C:\\Users\\Lenovo\\Desktop\\Letnik3\\DN\\Project\\platform\\microblaze_I\\standalone_microblaze_I\\bsp\\include\\sleep.h"
  "C:\\Users\\Lenovo\\Desktop\\Letnik3\\DN\\Project\\platform\\microblaze_I\\standalone_microblaze_I\\bsp\\include\\xiltimer.h"
  "C:\\Users\\Lenovo\\Desktop\\Letnik3\\DN\\Project\\platform\\microblaze_I\\standalone_microblaze_I\\bsp\\include\\xtimer_config.h"
  "C:\\Users\\Lenovo\\Desktop\\Letnik3\\DN\\Project\\platform\\microblaze_I\\standalone_microblaze_I\\bsp\\lib\\libxiltimer.a"
  )
endif()
