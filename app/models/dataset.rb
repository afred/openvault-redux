class Dataset < ActiveRecord::Base
  belongs_to :user

  has_attached_file :attachment

  def process!
    processor = nil

    case self.format
      when 'Artesia'
        processor = Artesia::Export.new(self)
    end

    processor.process!

    self.status = 'ingested'
    self.save
  end
end
