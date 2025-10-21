# # ---- Config ----
# PROJECT=StackWise.xcodeproj
# SCHEME=StackWise
# DEST=platform=iOS Simulator,name=iPhone 15
# DERIVED=./.derived

# # install once: brew install xcodegen xcbeautify
# .PHONY: gen build test clean reset spm

# gen:
# 	xcodegen generate --spec project.yml --project $(PROJECT)

# spm:
# 	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -resolvePackageDependencies

# build:
# 	xcodebuild -project $(PROJECT) \
# 		-scheme $(SCHEME) \
# 		-configuration Debug \
# 		-destination '$(DEST)' \
# 		-derivedDataPath $(DERIVED) \
# 		build | xcbeautify

# test:
# 	xcodebuild -project $(PROJECT) \
# 		-scheme $(SCHEME) \
# 		-destination '$(DEST)' \
# 		-derivedDataPath $(DERIVED) \
# 		test | xcbeautify

# clean:
# 	rm -rf $(DERIVED)

# reset: clean
# 	rm -rf .build
# ====== Config ======
PROJECT := StackWise.xcodeproj
SCHEME  := StackWise                            # run `make print-schemes` if unsure
DEST    := platform=iOS Simulator,name=iPhone 16
DERIVED := ./.derived

# Pretty build logs (optional): brew install xcbeautify
XCBEAUTIFY := $(shell command -v xcbeautify 2>/dev/null)
ifeq ($(XCBEAUTIFY),)
PIPE := cat
else
PIPE := xcbeautify
endif

# ====== Utility ======
print-schemes:
	@xcodebuild -list -project $(PROJECT)

print-devices:
	@xcrun simctl list devices | sed -n 's/.*(Booted)/\0/p; s/.*iPhone 1[45].*/\0/p'

clean:
	rm -rf $(DERIVED)

reset: clean
	rm -rf .build

# Resolve Swift Package deps (good first step after pulling changes)
spm:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -resolvePackageDependencies

# ====== Build & Test ======
build:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Debug \
		-destination '$(DEST)' \
		-derivedDataPath $(DERIVED) \
		build | $(PIPE)

test:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEST)' \
		-derivedDataPath $(DERIVED) \
		test | $(PIPE)

# ====== CLI-run on Simulator (optional, no Xcode UI) ======
# Boots a simulator if needed, installs the built .app, and launches it.
run: build
	@xcrun simctl boot "iPhone 15" || true
	@APP_PATH=$$(find $(DERIVED)/Build/Products/Debug-iphonesimulator -name "*.app" -maxdepth 2 | head -n1); \
	if [ -z "$$APP_PATH" ]; then echo "Could not find built .app in $(DERIVED)"; exit 1; fi; \
	BUNDLE_ID=$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$$APP_PATH/Info.plist"); \
	xcrun simctl install booted "$$APP_PATH"; \
	xcrun simctl launch booted "$$BUNDLE_ID" || true