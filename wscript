import TaskGen
import Utils
import os
import glob

top = '.'
out = 'build'

TaskGen.declare_chain(
    name='objc',
    rule='export DEVELOPER_DIR=${XCODE_PATH}; xcrun --sdk iphoneos${SDK_VERSION} ${C_COMPILER_EXEC} -arch ${ARCHITECTURE} -c ${GLOBAL_CFLAGS} ${SRC} -o ${TGT}',
    ext_in='.m',
    ext_out='.o',
    reentrant=False,
    shell=True
)

TaskGen.declare_chain(
    name='objcpp',
    rule='export DEVELOPER_DIR=${XCODE_PATH}; xcrun --sdk iphoneos${SDK_VERSION} ${CPP_COMPILER_EXEC} -arch ${ARCHITECTURE} -c ${GLOBAL_CFLAGS} ${SRC} -o ${TGT}',
    ext_in='.mm',
    ext_out='.o',
    reentrant=False,
    shell=True
)

def _configure_derived_values(env):
  env.PLATFORM = env.XCODE_PATH+'/Platforms/iPhoneOS.platform'
  env.SDK_PATH = env.PLATFORM+'/Developer/SDKs/iPhoneOS'+env.SDK_VERSION+'.sdk'
  env.PRV_FRAMEWORKS_DIR = env.SDK_PATH+"/System/Library/PrivateFrameworks"
  env.LOCAL_LIB_DIR = "/Users/sakurina/src/_jbenv/lib"
  env.GLOBAL_CFLAGS = " -isysroot "+env.SDK_PATH+" -F"+env.PRV_FRAMEWORKS_DIR+" -I/Users/sakurina/src/_jbenv/include -Os -Wno-unused-value -miphoneos-version-min="+env.MIN_OS_VERSION
  env.GLOBAL_LDFLAGS = " -isysroot "+env.SDK_PATH+" -F"+env.PRV_FRAMEWORKS_DIR+" -L"+env.LOCAL_LIB_DIR+" -lobjc -weak-lSystem -ObjC -framework CoreFoundation -framework Foundation -miphoneos-version-min="+env.MIN_OS_VERSION
  env.SUBSTRATE_LDFLAGS = env.GLOBAL_LDFLAGS+" -dynamiclib"

def configure(conf):
  print('→ configuring global settings')
  # deb package
  conf.env.PREFIX = os.getcwd()+'/net.r-ch.iconoclasm'
  #--- start setting arm64 stuff up
  conf.setenv('arm64')
  conf.env.CPP_COMPILER_EXEC = 'clang++'
  conf.env.C_COMPILER_EXEC = 'clang'
  conf.env.ARCHITECTURE = 'arm64'
  conf.env.SDK_VERSION = '8.2'
  conf.env.MIN_OS_VERSION = '4.3'
  conf.env.XCODE_PATH = '/Applications/Xcode.app/Contents/Developer'
  # stuff below this is derived from the top
  _configure_derived_values(conf.env)
  #--- start setting armv7 stuff up
  conf.setenv('armv7')
  conf.env.CPP_COMPILER_EXEC = 'clang++'
  conf.env.C_COMPILER_EXEC = 'clang'
  conf.env.ARCHITECTURE = 'armv7'
  conf.env.SDK_VERSION = '8.2'
  conf.env.MIN_OS_VERSION = '4.3'
  conf.env.XCODE_PATH = '/Applications/Xcode.app/Contents/Developer'
  # stuff below this is derived from the top
  _configure_derived_values(conf.env)
  pass

def build(bld):
  print('→ building whole project')
  bld.recurse('Iconoclasm')
  bld.recurse('IconoclasmPrefs')

from waflib.Build import BuildContext

class armv7(BuildContext):
  cmd = 'build_armv7'
  variant = 'armv7'

class arm64(BuildContext):
  cmd = 'build_arm64'
  variant = 'arm64'

def lipo(ctx):
  print('→ strip+lipo both slices')
  ctx.recurse('Iconoclasm')
  ctx.recurse('IconoclasmPrefs')

def package(ctx):
  for file in glob.glob('net.r-ch.iconoclasm/.DS_Store'):
    os.remove(file)
  for file in glob.glob('net.r-ch.iconoclasm/*/.DS_Store'):
    os.remove(file)
  for file in glob.glob('net.r-ch.iconoclasm/*/*/.DS_Store'):
    os.remove(file)
  for file in glob.glob('net.r-ch.iconoclasm/*/*/*/.DS_Store'):
    os.remove(file)
  for file in glob.glob('net.r-ch.iconoclasm/*/*/*/*/.DS_Store'):
    os.remove(file)
  ctx.exec_command("ldid -Sentitlements.xml net.r-ch.iconoclasm/Library/MobileSubstrate/DynamicLibraries/Iconoclasm.dylib")
  ctx.exec_command("ldid -S net.r-ch.iconoclasm/System/Library/PreferenceBundles/IconoclasmPrefs.bundle/IconoclasmPrefs")
  ctx.exec_command("dpkg-deb -b net.r-ch.iconoclasm")
