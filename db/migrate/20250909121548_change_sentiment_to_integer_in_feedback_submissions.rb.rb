class ChangeSentimentToIntegerInFeedbackSubmissions < ActiveRecord::Migration[7.2]
  def up
    add_column :feedback_submissions, :sentiment_integer, :integer

    execute <<-SQL
      UPDATE feedback_submissions
      SET sentiment_integer = CASE sentiment
        WHEN 'Needs Improvement' THEN 1
        WHEN 'Negative' THEN 1
        WHEN 'Meets Expectations' THEN 2
        WHEN 'Neutral' THEN 2
        WHEN 'Exceeds Expectations' THEN 3
        WHEN 'Positive' THEN 3
        WHEN 'Far Exceeds Expectations' THEN 4
        ELSE 2
      END
    SQL

    remove_column :feedback_submissions, :sentiment

    rename_column :feedback_submissions, :sentiment_integer, :sentiment
  end

  def down
    add_column :feedback_submissions, :sentiment_string, :string

    execute <<-SQL
      UPDATE feedback_submissions
      SET sentiment_string = CASE sentiment
        WHEN 1 THEN 'Needs Improvement'
        WHEN 2 THEN 'Meets Expectations'
        WHEN 3 THEN 'Exceeds Expectations'
        WHEN 4 THEN 'Far Exceeds Expectations'
        ELSE 'Meets Expectations'
      END
    SQL

    remove_column :feedback_submissions, :sentiment
    rename_column :feedback_submissions, :sentiment_string, :sentiment
  end
end