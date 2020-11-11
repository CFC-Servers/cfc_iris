repo = "CFC-Servers/cfc_iris_frontend"
repo_link = "https://github.com/#{repo}.git"
content_url = "https://github.com/#{repo}/releases/latest/download/built-site.tar.bz2"

current_frontend_version = `cat public/frontend/VERSION`
latest_frontend_version = `git ls-remote --refs --sort='version:refname' --tags #{repo_link} | cut -d/ -f3-|tail -n1`

Rails.logger.debug "Current frontend content version: '#{current_frontend_version}'"
Rails.logger.debug "Latest frontend content version: '#{latest_frontend_version}'"

if current_frontend_version != latest_frontend_version
  Rails.logger.info "Current frontend content is out of date, getting the latest..."
  `rm -rf public/frontend/*`

  `curl -L #{content_url} -o public/frontend/site.tar.bz2`
  `tar -C public/frontend/ -xjf public/frontend/site.tar.bz2`
  `rm public/frontend/site.tar.bz2`
else
  Rails.logger.info "Current frontend content is up to date"
end
