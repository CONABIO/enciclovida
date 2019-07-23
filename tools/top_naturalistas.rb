require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Gather the top 10 Naturalistas (according to most observations, species and identifications) depending on the site and given time

Usage:

  rails r tools/top_naturalistas.rb -d site_id time_start time_end
where ARGV are:
  site_id: The id of the site, this is store in the database or in config var: CONFIG.site_id (required)
  time_start: yyyy-mm-dd
  time_end: yyyy-mm-dd

*** If there are no ARGV of time, current time is taken


Example:  rails r tools/top_naturalistas.rb -d 2 2014-02-01 2015-02-01


where [options] are:
  EOS
  opt :debug, "Print debug statements", :type => :boolean, :short => "-d"
end

def most_observations(options = {})
  d_start = options[:date_start] || (Time.now - 1.year).strftime("%Y-%m-%d")
  d_end = options[:date_end] || Time.now.strftime("%Y-%m-%d")
  date_start = Date.parse(d_start)
  date_end = Date.parse(d_end)

  scope = Observation.group(:user_id)
  scope = scope.where("observed_on >= ? AND observed_on < ?", date_start, date_end)

  scope = scope.where("observations.site_id = ?", @site) if @site && @site.prefers_site_only_users?
  counts = scope.count.to_a.sort_by(&:last).reverse[0..9]
  users = User.where("id IN (?)", counts.map(&:first))
  counts.inject({}) do |memo, item|
    memo[users.detect{|u| u.id == item.first}] = item.last
    memo
  end
end

def most_species(options = {})
  d_start = options[:date_start] || (Time.now - 1.year).strftime("%Y-%m-%d")
  d_end = options[:date_end] || Time.now.strftime("%Y-%m-%d")
  date_start = Date.parse(d_start)
  date_end = Date.parse(d_end)
  date_clause = "observed_on >= '#{ date_start }' AND observed_on < '#{ date_end }'"

  site_clause = if @site && @site.prefers_site_only_users?
                  "AND o.site_id = #{@site.id}"
                end
  sql = <<-SQL
      SELECT
        o.user_id,
        count(*) AS count_all
      FROM
        (
          SELECT DISTINCT o.taxon_id, o.user_id
          FROM
            observations o
              JOIN taxa t ON o.taxon_id = t.id
          WHERE
            t.rank_level <= 10 AND
              #{date_clause}
  #{site_clause}
        ) as o
      GROUP BY o.user_id
      ORDER BY count_all desc
      LIMIT 10
  SQL

  rows = ActiveRecord::Base.connection.execute(sql)
  users = User.where("id IN (?)", rows.map{|r| r['user_id']})
  rows.inject([]) do |memo, row|
    memo << [users.detect{|u| u.id == row['user_id'].to_i}, row['count_all']]
    memo
  end
end

def most_identifications(options = {})
  d_start = options[:date_start] || (Time.now - 1.year).strftime("%Y-%m-%d")
  d_end = options[:date_end] || Time.now.strftime("%Y-%m-%d")
  date_start = Date.parse(d_start)
  date_end = Date.parse(d_end)

  scope = Identification.group("identifications.user_id").
      joins(:observation, :user).
      where("identifications.user_id != observations.user_id").
      order('count_all desc').
      limit(10)

  scope = scope.where("identifications.created_at >= ? AND identifications.created_at < ?",
                      date_start, date_end)

  scope = scope.where("users.site_id = ?", @site) if @site && @site.prefers_site_only_users?
  counts = scope.count.to_a
  users = User.where("id IN (?)", counts.map(&:first))

  counts.inject({}) do |memo, item|
    memo[users.detect{|u| u.id == item.first}] = item.last
    memo
  end
end


if ARGV.any?
  @site = Site.find_by_id(ARGV[0])

  options = {date_start: ARGV[1], date_end: ARGV[2]}
  @most_observations = most_observations(options)
  @most_species = most_species(options)
  @most_identifications = most_identifications(options)

else
  Rails.logger.debug 'The site_id is required' if OPTS[:debug]
end

Rails.logger.debug @most_observations_year.inspect if OPTS[:debug]
Rails.logger.debug @most_species_year.inspect if OPTS[:debug]
Rails.logger.debug @most_identifications_year.inspect if OPTS[:debug]