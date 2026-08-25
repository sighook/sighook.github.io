#!/bin/sh
# Publish the generated site as an exact gh-pages branch snapshot.

set -eu

REMOTE=${1:-origin}
BRANCH=${2:-gh-pages}
MAKE_COMMAND=${3:-make}

ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

if [ -n "$(git status --porcelain --untracked-files=normal)" ]; then
	echo 'publish: source worktree is not clean' >&2
	exit 1
fi

SOURCE_REV=$(git rev-parse --short=12 HEAD)
WORKTREE=$(mktemp -d "${TMPDIR:-/tmp}/sighook-pages.XXXXXX")

cleanup()
{
	git worktree remove --force "$WORKTREE" >/dev/null 2>&1 || rm -rf "$WORKTREE"
}
trap cleanup EXIT HUP INT TERM

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
	git worktree add "$WORKTREE" "$BRANCH"
elif git show-ref --verify --quiet "refs/remotes/$REMOTE/$BRANCH"; then
	git worktree add -b "$BRANCH" "$WORKTREE" "$REMOTE/$BRANCH"
else
	git worktree add --detach "$WORKTREE" HEAD
	(
		cd "$WORKTREE"
		git checkout --orphan "$BRANCH"
		git rm -rf . >/dev/null 2>&1 || :
	)
fi

find "$WORKTREE" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} \;
"$MAKE_COMMAND" install DESTDIR="$WORKTREE" WWWDIR=
: > "$WORKTREE/.nojekyll"

(
	cd "$WORKTREE"
	git add -A
	if ! git diff --cached --quiet; then
		git commit -m "Publish source $SOURCE_REV"
	else
		echo "publish: $BRANCH already matches source $SOURCE_REV"
	fi
	git push "$REMOTE" "$BRANCH"
)

# End of file.
