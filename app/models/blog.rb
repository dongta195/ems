class Blog < ApplicationRecord
  scope :sort_by_ASC, ->{order created_at: :asc}
  scope :sort_by_DESC, ->{order created_at: :desc}
  scope :sort_by_public_time, ->{order public_time: :desc}
  after_create :check_public
  after_update :check_public

  mount_uploader :intro_image, ImageUploader
  mount_uploader :author_image, ImageUploader

  BLOG_ATTRS = [:id, :title, :category_id, :public_time, :set_public,
    :suggest_status, :intro_image, :intro_image_cache,
    :content, :author_name, :author_position, :author_age, :author_image, :author_image_cache]

  belongs_to :category
  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy

  validates :title, presence: true
  validates_length_of :title, maximum: 255
  validates :public_time, presence: true
  validates :intro_image, presence: true
  validates :author_name, presence: true
  validate :image_size_validation, if: :intro_image? || :author_image?
  validate :file_format
  validates_length_of :author_name, maximum: 32
  validates :author_position, presence: true
  validates_length_of :author_position, maximum: 32
  validates :author_age, presence: true, numericality: { only_integer: true,
                                                         greater_than: 0,
                                                         less_than: 100 }
  validates :content, presence: true
  validates_length_of :author_age, maximum: 32

  enum set_public: {forbids: Settings.blog.status.draft,
    allow: Settings.blog.status.published}

  enum public_status: {draft: Settings.blog.status.draft,
    published: Settings.blog.status.published}

  enum suggest_status: {unavailable: Settings.blog.suggest.unavailable,
    available: Settings.blog.suggest.available}

  def stop_public_blog
    update_attribute 'public_status', Blog.public_statuses[:draft]
  end

  def public_blog
    update_attribute 'public_status', Blog.public_statuses[:published]
  end

  def conditions_public_blog?
    return true if self.draft? && self.allow? && Time.now() > self.public_time
  end

  def check_public
    if self.allow? && (Time.now() >= self.public_time)
      self.public_blog
    else
      self.stop_public_blog
    end
  end

  def rate_like rate_tyle
    column = rate_tyle + "s_count"
    update_attribute "#{column}", (self.send(column)+1)
  end

  def unrate_like rate_tyle
    column = rate_tyle + "s_count"
    update_attribute "#{column}", (self.send(column)-1)
  end

  private
  def image_size_validation
    if intro_image.size > 2.megabytes
      errors.add(:intro_image, I18n.t("errors.size_image"))
    end
    if author_image.size > 2.megabytes
      errors.add(:author_image, I18n.t("errors.size_image"))
    end
  end

  def file_format
    unless valid_extension? self.intro_image.filename
      errors.add(:intro_image, I18n.t("errors.extenstion"))
    end
    unless valid_extension? self.author_image.filename
      errors.add(:author_image, I18n.t("errors.extenstion"))
    end
  end

  def valid_extension? filename
    return true if filename.nil?
    ext = File.extname(filename)
    %w(.jpg .png).include? ext.downcase
  end
end
