module InicioHelper

  def dameNews
    issues = Hash.new

    ws = GithubService.new

    ws.getIssues.each  do |x|
      issues.merge!({x['title'] => x['body'].html_safe})
    end
    issues
  end

end
