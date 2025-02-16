// -*- mode:c++; tab-width:2; indent-tabs-mode:nil; c-basic-offset:2 -*-
/*
 *  Exception.cpp
 *  ZXing
 *
 *  Created by Christian Brunschen on 03/06/2008.
 *  Copyright 2008-2011 ZXing authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.

 */

#include <zxing/ZXing.h>
#include <zxing/Exception.h>
#include <string.h>

using zxing::Exception;

void Exception::deleteMessage() {
  delete [] message;
}

char const* Exception::copy(char const* msg) {
  char* message = 0;
  if (msg) {
    unsigned long l = strlen(msg)+1;
    if (l) {
      message = new char[l];
      strcpy(message, msg);
    }
  }
  return message;
}
