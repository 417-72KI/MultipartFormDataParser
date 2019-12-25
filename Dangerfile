github.dismiss_out_of_range_messages
swiftlint.lint_files inline_mode: true

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

fail('Do not modify xcodeproj. This file is modified only on release.') if git.modified_files.include? "MultipartFormDataParser.xcodeproj"
fail('Do not modify LICENSE !!') if git.modified_files.include? "LICENSE"
fail('Do not delete LICENSE !!') if git.deleted_files.include? "LICENSE"
