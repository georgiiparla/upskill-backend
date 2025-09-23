class UserEmailAlias < ActiveRecord::Base
  belongs_to :user

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :email_does_not_exist_as_primary

  private

  def email_does_not_exist_as_primary
    if User.exists?(email: email)
      errors.add(:email, "is already in use as a primary account email.")
    end
  end
end