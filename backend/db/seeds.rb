# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Seeds the database with sample votes for a top 10 leaderboard with varied vote counts.

# Reset Faker's unique generators to ensure fresh data
Faker::UniqueGenerator.clear

puts "Creating seed data..."

# Define countries with their desired vote counts for a varied top 10
# Format: [country_code, vote_count]
countries_with_votes = [
  ['USA', 25],      # Top country
  ['CAN', 18],      # Second
  ['MEX', 15],      # Third
  ['GBR', 12],      # Fourth
  ['FRA', 10],      # Fifth
  ['DEU', 9],       # Sixth
  ['ITA', 8],       # Seventh
  ['ESP', 7],       # Eighth
  ['JPN', 6],       # Ninth
  ['AUS', 5],       # Tenth
  ['BRA', 4],       # Just outside top 10
  ['IND', 3],       # Just outside top 10
  ['CHN', 2],       # Just outside top 10
  ['RUS', 1],       # Just outside top 10
]

countries_with_votes.each do |country_code, vote_count|
  puts "Creating #{vote_count} votes for #{country_code}..."
  
  vote_count.times do |i|
    # Generate unique user data using Faker
    name = Faker::Name.name
    email = Faker::Internet.unique.email
    
    # Create user and vote
    user = User.find_or_create_by!(email: email) do |u|
      u.name = name
    end
    
    # Create vote if user doesn't already have one
    unless Vote.exists?(user_id: user.id)
      Vote.create!(
        user: user,
        country_code: country_code
      )
    end
  end
end

puts "\nFetching country metadata..."
# Get all unique country codes that have votes
country_codes = Vote.distinct.pluck(:country_code).compact

if country_codes.any?
  # Clear cache for these countries to ensure fresh metadata
  country_codes.each do |code|
    Rails.cache.delete("country:#{code.upcase}")
  end
  
  # Perform the refresh job synchronously to ensure metadata is available
  Countries::RefreshJob.perform_now(country_codes)
  puts "Metadata fetched for #{country_codes.count} countries"
else
  puts "No countries to fetch metadata for"
end

puts "\nSeed data created successfully!"
puts "Total users: #{User.count}"
puts "Total votes: #{Vote.count}"
puts "\nTop 10 countries by vote count:"
Vote.group(:country_code).count.sort_by { |_k, v| -v }.first(10).each_with_index do |(code, count), index|
  puts "  #{index + 1}. #{code}: #{count} votes"
end
