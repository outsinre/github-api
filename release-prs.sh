#!/usr/bin/env bash

function warn () {
    >&2 printf '%s\n' "$@"
}

function die () {
    local st=$?
    case $2 in
        (*[^0-9]*|'') : ;;
        (*) st=$2 ;;
    esac
    warn "$1"
    exit "$st"
}

function clean_up () {
    local st=$?
    warn "$0 is terminated" "output dir $out_dir removed"
    rm -rf "$out_dir"
    exit $st
}

function show_help () {
    prg=$(basename "$0")
    cat <<-EOF
Version: 0.1
 Author: Zachary Hu (zhucac AT outlook.com)
 Script: Compare between two revisions (e.g. release tags) and output commits, pull requests and pull requests without changelog.
  Usage: ${prg} --org-repo kong/kong-ee --base-commit 3.4.2.0 --head-commit next/3.4.x.x [-v]

         ORG_REPO=kong/kong-ee BASE_COMMIT=3.4.2.0 HEAD_COMMIT=next/3.4.x.x $prg
EOF
}

function set_globals () {
    ORG_REPO="${ORG_REPO:-kong/kong-ee}"
    BASE_COMMIT="${BASE_COMMIT:-3.4.2.0}"
    HEAD_COMMIT="${HEAD_COMMIT:-next/3.4.x.x}"

    verbose=0
    out_dir=$(mktemp -dt output)
    commits_file="${out_dir}/commits.txt"
    prs_file="${out_dir}/prs.txt"
    prs_no_changelog_file="${out_dir}/no_changelog_prs.txt"
}

function parse_args () {
    while : ; do
        case "$1" in
            (-h|--help)
                show_help
                exit
                ;;
            (-v|--verbose)
                set -x
                verbose=$((verbose + 1))
                ;;
            (--base-commit)
                if [[ -n "$2" ]] ; then
                    BASE_COMMIT="$2"
                else
                    die 'ERROR: "--base-commit" requires a non-empty option argument.' 2
                fi
                shift
                ;;
            (--base-commit=*)
                BASE_COMMIT="${1#--base-commit=}"
                if [[ -z "$BASE_COMMIT" ]] ; then
                    die 'ERROR: "--base-commit=" requires a non-empty option argument followed immediately.' 2
                fi
                ;;
            (--head-commit)
                if [[ -n "$2" ]] ; then
                    HEAD_COMMIT="$2"
                else
                    die 'ERROR: "--head-commit" requires a non-empty option argument.' 2
                fi
                shift
                ;;
            (--head-commit=*)
                HEAD_COMMIT="${1#--base-commit=}"
                if [[ -z "$HEAD_COMMIT" ]] ; then
                    die 'ERROR: "--head-commit=" requires a non-empty option argument followed immediately.' 2
                fi
                ;;
            (--org-repo)
                if [[ -n "$2" ]] ; then
                    ORG_REPO="$2"
                else
                    die 'ERROR: "--org-repo" requires a non-empty option argument.' 2
                fi
                shift
                ;;
            (--org-repo=*)
                ORG_REPO="${1#--org-repo=}"
                if [[ -z "$ORG_REPO" ]] ; then
                    die 'ERROR: "--org-repo=" requires a non-empty option argument followed immediately.' 2
                fi
                ;;
            (--)
                shift
                break
                ;;
            (-?*)
                warn "WARNING: unknown option (ignored): $1."
                ;;
            (*)
                break
                ;;
        esac

        shift
    done
}

function prepare_args () {
    parse_args "$@"

    if [[ -z "${ORG_REPO:+x}" ]] ; then
        warn "ORG_REPO must be provided."
    fi
    if [[ -z "${BASE_COMMIT:+x}" ]] ; then
        warn "BASE_COMMIT must be provided."
    fi
    if [[ -z "${HEAD_COMMIT:+x}" ]] ; then
        warn "HEAD_COMMIT must be provided."
    fi
    if [[ -z "${GITHUB_TOKEN:+x}" ]] ; then
        warn "GITHUB_TOKEN must be provided."
    fi
    
    printf '%s\n' \
           "Org Repo: ${ORG_REPO}" \
           "Base Commit: ${BASE_COMMIT}" \
           "Head Commit: ${HEAD_COMMIT}"
}

function check_changelog () {
    local in_fd
    if [[ -f "$1" ]] ; then
        : {in_fd}<"$1"
    else
        : {in_fd}<&0
        warn "WARNING: $1 not a valid file. Read from stdin -"
    fi
    
    local changelog_pattern="changelog/unreleased/kong*/*.yml"
    local req_url
    local pr_number
    local has_changelog
    echo -e "\nPRs without changelog:"
    while read -r -u "$in_fd" ; do
        req_url="https://api.github.com/repos/${ORG_REPO}/pulls/PR_NUMBER/files"
        pr_number="${REPLY##https*/}"
        req_url="${req_url/PR_NUMBER/$pr_number}"
        mapfile -t < <( curl -sSL \
                             -H "Accept: application/vnd.github+json" \
                             -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                             -H "X-GitHub-Api-Version: 2022-11-28" \
                             "$req_url" | jq -r '.[].filename' )

        has_changelog=1
        for f in "${MAPFILE[@]}" ; do
            if [[ "$f" == ${changelog_pattern} ]] ; then has_changelog=0; break; fi
        done
        if [[ "$has_changelog" -eq 1 ]] ; then echo "$REPLY" | tee -a "$prs_no_changelog_file" ; fi
    done
    echo

    : ${in_fd}<&-
}

function main () {
    set -Eeo pipefail
    trap clean_up SIGABRT SIGQUIT SIGHUP SIGINT    # Ctrl-C

    set_globals
    prepare_args "$@"

    printf '%s\n' "Comparing between '${BASE_COMMIT}' and '${HEAD_COMMIT}'"
    mapfile -t < <( curl -sSL \
                     -H "Accept: application/vnd.github+json" \
                     -H "X-GitHub-Api-Version: 2022-11-28" \
                     -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                     "https://api.github.com/repos/${ORG_REPO}/compare/${BASE_COMMIT}...${HEAD_COMMIT}" | \
                    jq -r '.commits[].sha' )

    num_of_commits="${#MAPFILE[@]}"
    printf '%s\n' "Number of commits: ${num_of_commits}"
    printf '%s\n' "" "PR list:"

    max_per_request=17
    count=0
    BASE_Q="repo:${ORG_REPO}%20type:pr%20is:merged"
    full_q="$BASE_Q"
    for commit in "${MAPFILE[@]}" ; do
        printf '%s\n' "${commit:0:9}" >> "$commits_file"

        full_q="${full_q}%20${commit:0:9}"
        count=$((count+1))

        if ! (( count % max_per_request )) || test "$count" -eq "$num_of_commits" ; then
            curl -sSL \
                 -H "Accept: application/vnd.github+json" \
                 -H "X-GitHub-Api-Version: 2022-11-28" \
                 -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                 "https://api.github.com/search/issues?q=$full_q" | jq -r '.items[].html_url' | tee -a "$prs_file"
    
                 full_q="$BASE_Q"
        fi
    done
    sort -uo "$prs_file" "$prs_file"

    check_changelog "$prs_file"

    printf '%s\n' \
           "commits: $commits_file" \
           "pull requests: $prs_file" \
           "pull requests without changelog: $prs_no_changelog_file" \
           "" "Remeber to remove $out_dir"

    trap "" EXIT
}

if [[ "$#" -ne 0 ]] ; then main "$@" ; else show_help ; fi
