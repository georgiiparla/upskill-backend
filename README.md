# Upskill

Upskill is a backend application designed to foster professional development and collaboration within a team. It provides a suite of tools to encourage feedback, track progress, and recognize achievements, creating a supportive environment for continuous improvement.

## Features

* **Feedback-Driven Development:** A robust system for requesting and providing constructive feedback on various topics. Users can engage in discussions, like submissions, and control the visibility of their requests.
* **Goal-Oriented Quests:** A gamified approach to professional growth, where users can complete quests to earn points and track their progress.
* **Dynamic Dashboard:** A centralized hub for users to view their agenda, track team activity, and monitor personal and team-wide feedback statistics.
* **Recognition and Rewards:** A leaderboard to showcase top performers and a badging system to recognize achievements.
* **Seamless Integration:** Google OAuth 2.0 for secure and easy authentication.
* **Customizable Agenda:** A flexible agenda to manage tasks, meetings, and important articles, ensuring everyone stays aligned.

## Technology Stack

* **Backend:** Ruby, Sinatra
* **Database:** PostgreSQL for production, SQLite3 for development
* **Authentication:** JWT (JSON Web Tokens)
* **ORM:** ActiveRecord

## Getting Started

To get started with Upskill, you'll need to have Ruby and PostgreSQL installed.

1. **Clone the repository.**
2. **Install the required gems:** `bundle install`
3. **Set up the database:** `rake db:create && rake db:migrate`
4. **(Optional) Seed the database with sample data:** `rake db:seed`
5. **Start the server:** `rackup`

## Configuration

The application uses environment variables for configuration. You'll need to set up a `.env` file with the following:

* `FRONTEND_URL`: The URL of the frontend application.
* `DATABASE_URL`: The URL of your PostgreSQL database.
* `JWT_SECRET`: A secret key for encoding and decoding JWTs.
* `GOOGLE_CLIENT_ID`: Your Google OAuth 2.0 client ID.
* `GOOGLE_CLIENT_SECRET`: Your Google OAuth 2.0 client secret.
* `ALLOWED_DOMAIN`: The domain for authorized email addresses.
* `WHITELISTED_EMAILS`: A comma-separated list of whitelisted email addresses.
