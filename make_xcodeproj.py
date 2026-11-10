#!/usr/bin/env python3
import os, uuid, pathlib

root = pathlib.Path(__file__).resolve().parent
src = root / "Estereograma"

def hid():
    return uuid.uuid4().hex[:24].upper()

swift = []
assets = None
for p in src.rglob("*"):
    rel = p.relative_to(src).as_posix()
    if p.suffix == ".swift":
        swift.append(rel)
    if p.name == "Assets.xcassets":
        assets = rel
swift.sort()

ids = {name: hid() for name in [
    "project", "target", "native", "sources", "resources", "frameworks",
    "products", "main_group", "est_group", "engine", "views", "course",
    "product_ref", "assets_build", "sources_phase", "resources_phase",
    "frameworks_phase", "config_list_proj", "config_list_tgt",
    "debug_proj", "release_proj", "debug_tgt", "release_tgt",
]}
file_ids = {s: hid() for s in swift}
build_ids = {s: hid() for s in swift}
assets_id = hid()

def fileref(fid, path, typ):
    name = path.split("/")[-1]
    return f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {typ}; path = {name}; sourceTree = "<group>"; }};'

engine_files = [s for s in swift if s.startswith("Engine/")]
view_files = [s for s in swift if s.startswith("Views/")]
course_files = [s for s in swift if s.startswith("Course/")]
root_files = [s for s in swift if "/" not in s]

def children(paths, idmap):
    lines = []
    for s in paths:
        name = s.split("/")[-1]
        lines.append(f"\t\t\t\t{idmap[s]} /* {name} */,")
    return "\n".join(lines)

pbx = f'''// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
'''
for s in swift:
    name = s.split("/")[-1]
    pbx += f"\t\t{build_ids[s]} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ids[s]} /* {name} */; }};\n"
pbx += f"\t\t{ids['assets_build']} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_id} /* Assets.xcassets */; }};\n"
pbx += '''/* End PBXBuildFile section */

/* Begin PBXFileReference section */
'''
pbx += f'\t\t{ids["product_ref"]} /* Estereograma.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Estereograma.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n'
for s in swift:
    name = s.split("/")[-1]
    pbx += f'\t\t{file_ids[s]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = "<group>"; }};\n'
pbx += f'\t\t{assets_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};\n'
pbx += f'''/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{ids["frameworks_phase"]} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{ids["main_group"]} = {{
			isa = PBXGroup;
			children = (
				{ids["est_group"]} /* Estereograma */,
				{ids["products"]} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{ids["products"]} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{ids["product_ref"]} /* Estereograma.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
		{ids["est_group"]} /* Estereograma */ = {{
			isa = PBXGroup;
			children = (
{children(root_files, file_ids)}
				{ids["engine"]} /* Engine */,
				{ids["views"]} /* Views */,
				{ids["course"]} /* Course */,
				{assets_id} /* Assets.xcassets */,
			);
			path = Estereograma;
			sourceTree = "<group>";
		}};
		{ids["engine"]} /* Engine */ = {{
			isa = PBXGroup;
			children = (
{children(engine_files, file_ids)}
			);
			path = Engine;
			sourceTree = "<group>";
		}};
		{ids["views"]} /* Views */ = {{
			isa = PBXGroup;
			children = (
{children(view_files, file_ids)}
			);
			path = Views;
			sourceTree = "<group>";
		}};
		{ids["course"]} /* Course */ = {{
			isa = PBXGroup;
			children = (
{children(course_files, file_ids)}
			);
			path = Course;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{ids["target"]} /* Estereograma */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {ids["config_list_tgt"]} /* Build configuration list for PBXNativeTarget "Estereograma" */;
			buildPhases = (
				{ids["sources_phase"]} /* Sources */,
				{ids["frameworks_phase"]} /* Frameworks */,
				{ids["resources_phase"]} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Estereograma;
			productName = Estereograma;
			productReference = {ids["product_ref"]} /* Estereograma.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{ids["project"]} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
				TargetAttributes = {{
					{ids["target"]} = {{
						CreatedOnToolsVersion = 16.0;
					}};
				}};
			}};
			buildConfigurationList = {ids["config_list_proj"]} /* Build configuration list for PBXProject "Estereograma" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = es;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				es,
				Base,
			);
			mainGroup = {ids["main_group"]};
			productRefGroup = {ids["products"]} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{ids["target"]} /* Estereograma */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{ids["resources_phase"]} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{ids["assets_build"]} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{ids["sources_phase"]} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
'''
for s in swift:
    name = s.split("/")[-1]
    pbx += f"\t\t\t\t{build_ids[s]} /* {name} in Sources */,\n"
pbx += f'''			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{ids["debug_proj"]} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			}};
			name = Debug;
		}};
		{ids["release_proj"]} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 5.0;
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{ids["debug_tgt"]} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = Estereograma;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.education";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				MARKETING_VERSION = 0.1;
				PRODUCT_BUNDLE_IDENTIFIER = lavf.Estereograma;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{ids["release_tgt"]} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = Estereograma;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.education";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				MARKETING_VERSION = 0.1;
				PRODUCT_BUNDLE_IDENTIFIER = lavf.Estereograma;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{ids["config_list_proj"]} /* Build configuration list for PBXProject "Estereograma" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{ids["debug_proj"]} /* Debug */,
				{ids["release_proj"]} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{ids["config_list_tgt"]} /* Build configuration list for PBXNativeTarget "Estereograma" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{ids["debug_tgt"]} /* Debug */,
				{ids["release_tgt"]} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {ids["project"]} /* Project object */;
}}
'''

proj_dir = root / "Estereograma.xcodeproj"
proj_dir.mkdir(exist_ok=True)
(proj_dir / "project.pbxproj").write_text(pbx)

scheme_dir = proj_dir / "xcshareddata" / "xcschemes"
scheme_dir.mkdir(parents=True, exist_ok=True)
scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{ids["target"]}"
               BuildableName = "Estereograma.app"
               BlueprintName = "Estereograma"
               ReferencedContainer = "container:Estereograma.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{ids["target"]}"
            BuildableName = "Estereograma.app"
            BlueprintName = "Estereograma"
            ReferencedContainer = "container:Estereograma.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{ids["target"]}"
            BuildableName = "Estereograma.app"
            BlueprintName = "Estereograma"
            ReferencedContainer = "container:Estereograma.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
'''
(scheme_dir / "Estereograma.xcscheme").write_text(scheme)
print("wrote", proj_dir)
print("swift files:", len(swift))
for s in swift:
    print(" ", s)
