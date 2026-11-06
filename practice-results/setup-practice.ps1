$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot
$utf8 = [System.Text.UTF8Encoding]::new($false)
function Git([string[]]$Arguments) {
    & git.exe @Arguments
    if ($LASTEXITCODE -ne 0) { throw "git failed: $Arguments" }
}
function WriteText($path, $text) { [IO.File]::WriteAllText($path, $text, $utf8) }
foreach ($name in @('iTshirt', 'hello-git', 'hello-git-copy', 'local-remotes')) {
    if ((Test-Path (Join-Path $base $name)) -and ($name -ne 'local-remotes' -or (Get-ChildItem (Join-Path $base $name) -Force))) { throw "Already exists: $name. No files overwritten." }
}
New-Item -ItemType Directory -Path "$base/local-remotes" -Force | Out-Null
Git @('init', '--initial-branch=main', "$base/iTshirt")
$repo = "$base/iTshirt"
WriteText "$repo/README.txt" '개발자 티셔츠 쇼핑몰 오픈소스'
Git @('-C', $repo, 'add', 'README.txt')
Git @('-C', $repo, 'commit', '-m', '사이트 설명 추가')
WriteText "$repo/README.txt" '개발자 티셔츠 쇼핑몰 오픈소스 짱'
Git @('-C', $repo, 'add', 'README.txt')
Git @('-C', $repo, 'commit', '-m', '설명 업데이트')
WriteText "$repo/README.txt" "개발자 티셔츠 쇼핑몰 오픈소스 짱`n`n1. 고양이`n2. 문어"
Git @('-C', $repo, 'add', 'README.txt')
Git @('-C', $repo, 'commit', '-m', '개발자 목록 추가')
WriteText "$repo/feature-list.md" "# 기능 목록`n1. 티셔츠 올리기`n2. 티셔츠 구매하기"
WriteText "$repo/tshirt-list.md" "1. GitHub 티셔츠`n2. 파이썬 티셔츠"
Git @('-C', $repo, 'add', 'feature-list.md', 'tshirt-list.md')
Git @('-C', $repo, 'commit', '-m', '티셔츠, 기능 리스트 추가')
Git @('init', '--bare', '--initial-branch=main', "$base/local-remotes/iTshirt.git")
Git @('-C', $repo, 'remote', 'add', 'origin', "$base/local-remotes/iTshirt.git")
Git @('-C', $repo, 'push', '-u', 'origin', 'main')

# Supplementary local exercise; not a verbatim reconstruction of chapter 0.
$hello = "$base/hello-git"
Git @('init', '--initial-branch=main', $hello)
WriteText "$hello/hello.txt" "안녕하세요. Git 실습입니다.`n"
Git @('-C', $hello, 'add', 'hello.txt')
Git @('-C', $hello, 'commit', '-m', '첫 번째 커밋')
$first = & git.exe -C $hello rev-parse HEAD
WriteText "$hello/hello.txt" "안녕하세요. Git 실습입니다.`n두 번째 버전을 만들었습니다.`n"
Git @('-C', $hello, 'add', 'hello.txt')
Git @('-C', $hello, 'commit', '-m', '두 번째 커밋')
Git @('-C', $hello, 'switch', '--detach', $first)
if ([IO.File]::ReadAllText("$hello/hello.txt").Replace("`r`n", "`n") -ne "안녕하세요. Git 실습입니다.`n") { throw 'Earlier version mismatch' }
Git @('-C', $hello, 'switch', 'main')
Git @('init', '--bare', '--initial-branch=main', "$base/local-remotes/hello-git.git")
Git @('-C', $hello, 'remote', 'add', 'origin', "$base/local-remotes/hello-git.git")
Git @('-C', $hello, 'push', '-u', 'origin', 'main')
Git @('clone', "$base/local-remotes/hello-git.git", "$base/hello-git-copy")
WriteText "$base/hello-git-copy/hello.txt" "안녕하세요. Git 실습입니다.`n두 번째 버전을 만들었습니다.`n복제한 저장소에서 수정했습니다.`n"
Git @('-C', "$base/hello-git-copy", 'add', 'hello.txt')
Git @('-C', "$base/hello-git-copy", 'commit', '-m', '복제한 저장소에서 내용 추가')
Git @('-C', "$base/hello-git-copy", 'push')
Git @('-C', $hello, 'pull', '--ff-only')
if ((& git.exe -C $hello rev-parse HEAD) -ne (& git.exe -C "$base/hello-git-copy" rev-parse HEAD)) { throw 'Clone/pull mismatch' }
foreach ($path in @($repo, $hello, "$base/hello-git-copy")) {
    Git @('-C', $path, 'fsck', '--full')
    if (& git.exe -C $path status --porcelain) { throw "Uncommitted files: $path" }
}
'Verified: clean working trees, repository integrity, push/clone/pull, historical checkout.'
