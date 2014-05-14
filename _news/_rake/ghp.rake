MESSAGE = "Update gh-pages"


desc "Update gh-pages branch"
task :ghp do
  `git update-index -q --refresh`

  if `git ls-files --others --exclude-standard`.chomp.length > 0
    abort("Working tree has uncommitted changes... refusing to continue.")
  end

  verbose(false) do
    sh "git diff-index --quiet --cached HEAD" do |ok, res|
      if ! ok
        abort("Index has uncommitted changes... refusing to continue.")
      end
    end
  end

  `git add -f ../news`
  `git rm -rfq --cached .`

  verbose(false) do
    sh "git diff-index --quiet --cached gh-pages" do |ok, res|
      if ok
        abort("Already up to date. There is nothing to do!")
      end
    end
  end

  tsha = `git write-tree`.chomp

  csha = `echo #{MESSAGE} | git commit-tree -p gh-pages #{tsha}`.chomp

  sh "git update-ref refs/heads/gh-pages #{csha}"

  `git reset HEAD`
end
