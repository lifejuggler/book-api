class EnhancedWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 20, :dead => false
  def perform()
  end
end
