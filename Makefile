CHANGELOG_VERSION=3.x.y.z
CHANGELOG_FOLDER=unreleased
DEBUG=false

generate-ee:
	@rm -f changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md
	@touch changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md
	@if [ -d "changelog/$(CHANGELOG_FOLDER)/kong" ]; then \
		changelog --debug=$(DEBUG) generate \
			--repo-path . \
			--changelog-paths changelog/$(CHANGELOG_FOLDER)/kong \
			--title Kong \
			--github-issue-repo Kong/kong \
			--github-api-repo Kong/kong-ee \
			--with-jiras \
			>> changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md; \
    fi
	@if [ -d "changelog/$(CHANGELOG_FOLDER)/kong-ee" ]; then \
		changelog --debug=$(DEBUG) generate \
			--repo-path . \
			--changelog-paths changelog/$(CHANGELOG_FOLDER)/kong-ee \
			--title Kong-Enterprise \
			--github-issue-repo Kong/kong-ee \
			--github-api-repo Kong/kong-ee \
			--with-jiras \
			>> changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md; \
    fi
	@if [ -d "changelog/$(CHANGELOG_FOLDER)/kong-manager-ee" ]; then \
		changelog --debug=$(DEBUG) generate \
			--repo-path . \
			--changelog-paths changelog/$(CHANGELOG_FOLDER)/kong-manager-ee \
			--title Kong-Manager-Enterprise \
			--github-issue-repo Kong/kong-admin \
			--github-api-repo Kong/kong-ee \
			--with-jiras \
			>> changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md; \
    fi
	@if [ -d "changelog/$(CHANGELOG_FOLDER)/kong-portal" ]; then \
		changelog --debug=$(DEBUG) generate \
			--repo-path . \
			--changelog-paths changelog/$(CHANGELOG_FOLDER)/kong-portal \
			--title Kong-Portal \
			--github-issue-repo Kong/kong-portal-templates \
			--github-api-repo Kong/kong-ee \
			--with-jiras \
			>> changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md; \
    fi
	@echo "Successfully genreate changelog changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md"

generate-ce:
	@rm -f changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md
	@touch changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md
	@if [ -d "changelog/$(CHANGELOG_FOLDER)/kong" ]; then \
		changelog --debug=$(DEBUG) generate \
			--repo-path . \
			--changelog-paths changelog/$(CHANGELOG_FOLDER)/kong \
			--title Kong \
			--github-issue-repo Kong/kong \
			--github-api-repo Kong/kong \
			--with-jiras \
			>> changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md; \
    fi
	@if [ -d "changelog/$(CHANGELOG_FOLDER)/kong-manager" ]; then \
		changelog --debug=$(DEBUG) generate \
			--repo-path . \
			--changelog-paths changelog/$(CHANGELOG_FOLDER)/kong-manager \
			--title Kong-Manager \
			--github-issue-repo Kong/kong-manager \
			--github-api-repo Kong/kong \
			--with-jiras \
			>> changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md; \
    fi
	@echo "Successfully genreate changelog changelog/$(CHANGELOG_FOLDER)/$(CHANGELOG_VERSION).md"
