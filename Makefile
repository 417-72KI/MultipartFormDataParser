PROJECT_NAME = MultipartFormDataParser

ver = 2.3.1

.SILENT:

test:
	rm -rf test_output
	xcrun -sdk macosx xcodebuild \
		-scheme ${PROJECT_NAME} \
		-destination 'platform=macOS' \
		-enableCodeCoverage=YES \
		-resultBundlePath "test_output/test_result.xcresult" \
		test | xcpretty
	xed test_output/test_result.xcresult

release:
	@scripts/release.swift ${PROJECT_NAME} ${ver}
