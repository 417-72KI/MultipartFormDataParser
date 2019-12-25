import Danger

// lint
SwiftLint.lint()

let danger = Danger()
let allSourceFiles = danger.git.modifiedFiles + danger.git.createdFiles

let changelogChanged = allSourceFiles.contains("CHANGELOG.md")
let sourceChanges = allSourceFiles.first(where: { $0.hasPrefix("Sources") })

if !changelogChanged && sourceChanges != nil {
  warn("No CHANGELOG entry added.")
}

// Make it more obvious that a PR is a work in progress and shouldn't be merged yet
if danger.github.pullRequest.title.starts(with: "[WIP]") {
    warn("PR is classed as Work in Progress")
}

// Warn when there is a big PR
if danger.git.createdFiles.count + danger.git.modifiedFiles.count - danger.git.deletedFiles.count > 500 {
    warn("Big PR")
}
