# Time duration helpers for quest configuration
# Usage:
#   Quest.create!(reset_interval_seconds: 1.day)
#   Quest.create!(reset_interval_seconds: 7.days)
#   Quest.create!(reset_interval_seconds: 1.year)

class Integer
  def seconds
    self
  end

  def minutes
    self * 60
  end

  def hours
    self * 60 * 60
  end

  def days
    self * 24 * 60 * 60
  end

  def weeks
    self * 7 * 24 * 60 * 60
  end

  def months
    self * 30 * 24 * 60 * 60
  end

  def years
    self * 365 * 24 * 60 * 60
  end
end
