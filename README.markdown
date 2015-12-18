# Iconoclasm

*Iconoclasm* is a tweak that lets you do more with your iPhone's home screen. It was sold on the Cydia Store from 2009 to 2015, and now it is open source for others who wish to use its code in their own similar products. Please read [this page][eol] for more details on what's going on with the project.

## Building Iconoclasm

*Iconoclasm* predates Theos, which is probably the most commonly used build system in the jailbreak community today. For a variety of reasons, I rolled my own build script with *waf*, which you will need installed if you want to run the build scripts. I usually just this line in the root of my repo:

```waf distclean configure build_armv7 build_arm64 lipo package -p```

You will almost definitely need to tweak the waf file to point to the SDK you wish to use and your library/header paths, because this build script was never designed with any user other than myself in mind.

## This Is A Huge Mess

This code hasn't aged very well. I wouldn't recommend building off of the Iconoclasm project as a base, but rather using components of the Iconoclasm code or ideas within it to achieve similar or identical results in a different code base.

If you need some help understanding responsibilities in the code so you can make your way around easily:

* Layout classes (ICGridLayout, ICFreeformLayout) act as a pluggable module that encompass most of the logic for reading the right layout out of a plist, converting that into something SpringBoard can deal with, and passing raw coordinates into a…
* Scaling engine, which exists for each supported screen size, and handles upscaling to other screen sizes as a special case. Things like icon size and aspect ratio can make the scaling results look really weird (see: folder layouts), but in most cases, I still try to fiddle with the coordinates to make them look better.

## License

Copyright (c) 2009-2015 Yanik Magnan
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

### [CaptainHook][ch]

Copyright (c) 2009-2015 Ryan Petrich

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[eol]: http://r-ch.net/iconoclasm-eol.html
[ch]: https://github.com/rpetrich/CaptainHook
