Single vote constraint: The application relies on the database validation instead of an auth system. Currently the existance of an user on the application is not needed and doesn't provide a great advantage.
Redis cache: The data used from the countries API is cached to be able to use it across the application without making new requests. This mades the data available since the start of the application (Cache loading on startup)
Sidekiq: It was chosen due to its proven job managing and the provided UI. Used to update the countries cache.

The functional requirement is met due to the application being able to process the voting of the countries, the top leaderscore and search functionality without strugling or having errors.

The non-functional requirement is met with the application being fully tested and documented, with Rwag UI to test API.